// lib/features/sync/sync_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lstracker/data/db/sample_dao.dart';
import 'package:lstracker/data/services/dio_client.dart';
import 'package:lstracker/data/services/log_service.dart';
import 'package:lstracker/data/services/meta_sync_service.dart';
import 'package:lstracker/data/services/sync_service.dart';
import 'package:lstracker/features/sync/conflict_resolution_screen.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:lstracker/widgets/global_bottom_nav.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncScreen extends StatefulWidget {
  static const route = '/sync';
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  late final SyncService _sync;
  final SampleDao _dao = SampleDao();

  bool _busy = false;
  DateTime? _lastPull;
  int _pendingDirty = 0;
  int _pendingConflicts = 0;

  /// Snapshot du journal pour affichage; on s'abonne au stream pour le rafraîchir.
  List<LogEntry> _logs = [];
  StreamSubscription<LogEntry>? _logSub;

  @override
  void initState() {
    super.initState();
    _sync = SyncService(dio: DioClient.instance.dio);
    _logs = LogService.instance.snapshot().reversed.toList(); // plus récent en haut
    _logSub = LogService.instance.stream.listen((entry) {
      if (!mounted) return;
      setState(() {
        _logs.insert(0, entry);
        if (_logs.length > 500) _logs.removeLast();
      });
    });
    _refreshStatus();
  }

  @override
  void dispose() {
    _logSub?.cancel();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    final last = await _sync.getLastPull();
    final dirty = await _dao.countDirty();
    final conflicts = await _dao.countConflicts();
    if (!mounted) return;
    setState(() {
      _lastPull = last;
      _pendingDirty = dirty;
      _pendingConflicts = conflicts;
    });
  }

  Future<void> _syncMeta() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await MetaSyncService.refreshAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Métadonnées synchronisées')),
      );
    } catch (e) {
      LogService.instance.error('Meta', 'refreshAll a échoué', error: e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la synchronisation: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _run() async {
    setState(() => _busy = true);
    try {
      final result = await _sync.run();
      if (mounted) {
        // Feedback utilisateur : push/pull OK ? Conflits ?
        final msg = result.hasError
            ? 'Synchronisation incomplète. Voir le journal.'
            : (result.conflicts > 0
                ? 'Synchronisé. ${result.conflicts} conflit(s) à résoudre.'
                : 'Synchronisé.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      // Improbable (run() catche en interne), mais on garde le filet.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur synchronisation : $e')),
        );
      }
    }
    if (!mounted) return;
    await _refreshStatus();
    setState(() => _busy = false);
  }

  Future<void> _pullFull() async {
    setState(() => _busy = true);
    try {
      await _sync.pull(since: null);
    } catch (e) {
      // L'erreur est déjà loggée par SyncService, mais l'utilisateur ne
      // verrait rien sans feedback UI.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pull complet a échoué : $e')),
        );
      }
    }
    if (!mounted) return;
    await _refreshStatus();
    setState(() => _busy = false);
  }

  Future<void> _exportLogs() async {
    try {
      final path = await LogService.instance.exportToFile();
      LogService.instance.info('UI', 'Export logs OK ($path)');
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          subject: 'Logs TransportDNO',
          text: 'Logs TransportDNO du ${DateTime.now().toIso8601String()}',
        ),
      );
    } catch (e, st) {
      LogService.instance.error('UI', 'Export logs a échoué', error: e, stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec de l'export: $e")),
      );
    }
  }

  Future<void> _openConflicts() async {
    await Navigator.of(context).pushNamed(ConflictResolutionScreen.route);
    if (!mounted) return;
    await _refreshStatus();
  }

  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Vider le journal'),
        content: const Text('Effacer toutes les entrées affichées ici ? '
            'Les changements de données ne sont pas affectés.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Effacer')),
        ],
      ),
    );
    if (confirmed != true) return;
    LogService.instance.clear();
    setState(() => _logs = []);
  }

  String _fmtTime(DateTime d) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(d.day)}/${pad(d.month)}/${d.year} ${pad(d.hour)}:${pad(d.minute)}:${pad(d.second)}';
  }

  Color _colorFor(LogLevel l) {
    switch (l) {
      case LogLevel.debug:
        return Colors.grey;
      case LogLevel.info:
        return Colors.blue.shade700;
      case LogLevel.warn:
        return Colors.orange.shade800;
      case LogLevel.error:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Le rôle est en cache (préchargé au boot via AuthUtils.prime),
    // donc lookup synchrone — pas de FutureBuilder qui rebuild à chaque
    // setState du contenu.
    final userRole = AuthUtils.roleOrNull() ?? 'ADMIN';
    return Scaffold(
          appBar: AppBar(
            title: const Text('Synchronisation'),
            actions: [
              IconButton(
                tooltip: 'Exporter le journal',
                icon: const Icon(Icons.ios_share),
                onPressed: _exportLogs,
              ),
              IconButton(
                tooltip: 'Vider le journal',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: _clearLogs,
              ),
            ],
          ),
          bottomNavigationBar: GlobalBottomNav(
            current: BottomTab.sync,
            userRole: userRole,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Statut visuel
              Card(
                color: _pendingDirty == 0 && _pendingConflicts == 0
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        _pendingDirty == 0 && _pendingConflicts == 0
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_sync_outlined,
                        size: 32,
                        color: _pendingDirty == 0 && _pendingConflicts == 0
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pendingDirty == 0 && _pendingConflicts == 0
                                  ? 'Tout est à jour'
                                  : 'Synchronisation en attente',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            if (_pendingDirty > 0)
                              Text('$_pendingDirty élément(s) à envoyer'),
                            if (_pendingConflicts > 0)
                              InkWell(
                                onTap: _openConflicts,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Text(
                                        '$_pendingConflicts conflit(s) détecté(s)',
                                        style: TextStyle(
                                          color: Colors.red.shade800,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.chevron_right,
                                          size: 16, color: Colors.red.shade800),
                                    ],
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              'Dernier pull : '
                              '${_lastPull != null ? _fmtTime(_lastPull!.toLocal()) : "jamais"}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Bouton dédié de résolution de conflits (visible seulement
              // si au moins un conflit existe)
              if (_pendingConflicts > 0) ...[
                Material(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _openConflicts,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red.shade700, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_pendingConflicts conflit(s) à résoudre',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Choisissez entre votre version locale et la '
                                  'version serveur pour chaque échantillon en conflit.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade900.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.red.shade700),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Actions principales
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _busy ? null : _run,
                    icon: _busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: const Text('Synchroniser maintenant'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _syncMeta,
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Recharger métadonnées'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _pullFull,
                    icon: const Icon(Icons.download_for_offline_outlined),
                    label: const Text('Pull complet'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () async {
                            final sp = await SharedPreferences.getInstance();
                            await sp.remove('sync.last_pull_at');
                            await _refreshStatus();
                          },
                    icon: const Icon(Icons.restore_outlined),
                    label: const Text('Reset horodatage'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Journal
              Row(
                children: [
                  Text('Journal', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Text(
                    '${_logs.length} entrée(s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_logs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('Aucune entrée pour le moment.')),
                )
              else
                ..._logs.map(_buildLogTile),
            ],
          ),
        );
  }

  Widget _buildLogTile(LogEntry e) {
    final color = _colorFor(e.level);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 36,
            margin: const EdgeInsets.only(right: 8, top: 2),
            color: color,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      e.level.name.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('[${e.tag}]',
                        style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    const Spacer(),
                    Text(
                      _fmtTime(e.timestamp),
                      style: const TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(e.message, style: const TextStyle(fontSize: 13)),
                if (e.error != null)
                  Text(
                    'Erreur: ${e.error}',
                    style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
