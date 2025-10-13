// lib/features/sync/sync_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lstracker/app_config/app_config.dart';
import 'package:lstracker/data/db/app_database.dart';
import 'package:lstracker/data/db/metadata_dao.dart';
import 'package:lstracker/data/services/dio_client.dart';
import 'package:lstracker/data/services/meta_sync_service.dart';
import 'package:lstracker/data/services/sync_service.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:lstracker/widgets/global_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncScreen extends StatefulWidget {
  static const route = '/sync';
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  late final SyncService _sync;
  final _metaDao = MetadataDao();

  bool _busy = false;
  String? _lastPullIso;
  final _logs = <String>[];

  @override
  void initState() {
    super.initState();
    _sync = SyncService(dio: DioClient.instance.dio);
    _loadLastPull();
  }

  Future<void> _loadLastPull() async {
    final t = await _sync.getLastPull();
    setState(() => _lastPullIso = t?.toIso8601String());
  }

  void _append(String msg) {
    setState(
      () => _logs.insert(0, '[${DateTime.now().toIso8601String()}] $msg'),
    );
  }

  Future<void> _reloadMeta() async {
    setState(() => _busy = true);
    try {
      final n = await _metaDao.refreshFromServer(dio: DioClient.instance.dio);
      _append('META: rechargées ($n enregistrements).');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Métadonnées rechargées ($n).')));
      }
    } catch (e) {
      _append('META: erreur — $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec rechargement métadonnées: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la synchronisation: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _push() async {
    setState(() => _busy = true);
    try {
      final n = await _sync.pushDirty();
      _append('PUSH terminé — $n envoyé(s).');
    } catch (e) {
      _append('PUSH erreur — $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _pull({bool full = false}) async {
    setState(() => _busy = true);
    try {
      final n = await _sync.pull(
        since: full ? null : await _sync.getLastPull(),
      );
      _append('PULL ${full ? "(full)" : ""} terminé — $n reçu(s).');
      await _loadLastPull();
    } catch (e) {
      _append('PULL erreur — $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _run() async {
    setState(() => _busy = true);
    final res = await _sync.run();
    for (final m in res.messages.reversed) {
      _append(m);
    }
    await _loadLastPull();
    setState(() => _busy = false);
  }

  /// Recharge les métadonnées (lab, circuit, site, circuit_site, rejection_type)
  /// depuis l’API /api/meta/full puis remplace les tables locales.
  Future<void> _refreshMetadata() async {
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      final dio = DioClient.instance.dio;
      final Response r = await dio.get(AppConfig.metaFullPath);

      final data = (r.data is Map)
          ? Map<String, dynamic>.from(r.data)
          : <String, dynamic>{};
      final labs = (data['labs'] as List?) ?? const [];
      final circuits = (data['circuits'] as List?) ?? const [];
      final sites = (data['sites'] as List?) ?? const [];
      // supporte deux conventions: "circuitSites" (camel) ou "circuit_site" (snake)
      final circuitSites =
          (data['circuitSites'] as List?) ??
          (data['circuit_site'] as List?) ??
          const [];
      final rejections =
          (data['rejectionTypes'] as List?) ??
          (data['rejection_types'] as List?) ??
          const [];

      final db = await AppDatabase.instance.database;
      final batch = db.batch();

      // Vider avant d'insérer (idempotent & évite les conflits d’unicité)
      batch.delete('lab');
      batch.delete('circuit');
      batch.delete('site');
      // Si la table n’existe pas dans ton schéma, ignore/retire ces lignes
      batch.delete('circuit_site');
      batch.delete('rejection_type');

      // Insert labs
      for (final it in labs) {
        final m = Map<String, dynamic>.from(it as Map);
        batch.insert('lab', {
          'id': (m['id'] as int?) ?? (m['id'] as num?)?.toInt(),
          'name': (m['name'] ?? '').toString(),
          'lab_type': (m['labType'] ?? m['lab_type'] ?? '').toString(),
        });
      }

      // Insert circuits
      for (final it in circuits) {
        final m = Map<String, dynamic>.from(it as Map);
        batch.insert('circuit', {
          'id': (m['id'] as int?) ?? (m['id'] as num?)?.toInt(),
          'name': (m['name'] ?? '').toString(),
        });
      }

      // Insert sites
      for (final it in sites) {
        final m = Map<String, dynamic>.from(it as Map);
        batch.insert('site', {
          'id': (m['id'] as int?) ?? (m['id'] as num?)?.toInt(),
          'name': (m['name'] ?? '').toString(),
          'dhis_code': (m['dhisCode'] ?? m['dhis_code'] ?? '').toString(),
          // on laisse circuit_id nullable ici (relation n-n gérée par circuit_site)
          'circuit_id':
              (m['circuitId'] as int?) ??
              (m['circuit_id'] as int?) ??
              (m['circuitId'] as num?)?.toInt() ??
              (m['circuit_id'] as num?)?.toInt(),
        });
      }

      // Insert circuit_site (n-n)
      for (final it in circuitSites) {
        final m = Map<String, dynamic>.from(it as Map);
        final circuitId =
            (m['circuitId'] as int?) ??
            (m['circuit_id'] as int?) ??
            (m['circuitId'] as num?)?.toInt() ??
            (m['circuit_id'] as num?)?.toInt();
        final siteId =
            (m['siteId'] as int?) ??
            (m['site_id'] as int?) ??
            (m['siteId'] as num?)?.toInt() ??
            (m['site_id'] as num?)?.toInt();
        if (circuitId != null && siteId != null) {
          batch.insert('circuit_site', {
            'circuit_id': circuitId,
            'site_id': siteId,
          });
        }
      }

      // Insert rejection types
      for (final it in rejections) {
        final m = Map<String, dynamic>.from(it as Map);
        batch.insert('rejection_type', {
          'id': (m['id'] as int?) ?? (m['id'] as num?)?.toInt(),
          'name': (m['name'] ?? '').toString(),
        });
      }

      await batch.commit(noResult: true);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Métadonnées rechargées')));
      _append(
        'Métadonnées: ${labs.length} lab(s), ${circuits.length} circuit(s), ${sites.length} site(s), ${circuitSites.length} liaisons circuit-site, ${rejections.length} motif(s) de rejet.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Échec métadonnées: $e')));
      _append('META erreur — $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastPull = _lastPullIso ?? '—';
    return FutureBuilder<String?>(
      future: AuthUtils.getUserRole(),
      builder: (context, snapshot) {
        final userRole = snapshot.data ?? 'ADMIN';
        return Scaffold(
          appBar: AppBar(title: const Text('Synchronisation')),
          bottomNavigationBar: GlobalBottomNav(
            current: BottomTab.sync,
            userRole: userRole,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _syncMeta,
                    icon: const Icon(Icons.refresh_outlined),
                    label: const Text('Recharger métadonnées'),
                  ),
                ],
              ),
              Divider(),
              Divider(),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Dernier pull (serveur → mobile)'),
                  subtitle: Text(lastPull),
                  trailing: IconButton(
                    tooltip: 'Reset horodatage',
                    icon: const Icon(Icons.restore),
                    onPressed: _busy
                        ? null
                        : () async {
                            final sp = await SharedPreferences.getInstance();
                            await sp.remove('sync.last_pull_at');
                            await _loadLastPull();
                            _append('Horodatage de dernier pull réinitialisé.');
                          },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Divider(),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _busy ? null : _push,
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text('PUSH (dirty)'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _pull(full: false),
                        icon: const Icon(Icons.cloud_download_outlined),
                        label: const Text('PULL (incr.)'),
                      ),
                      Spacer(),
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _pull(full: true),
                        icon: const Icon(Icons.download_for_offline_outlined),
                        label: const Text('PULL (complet)'),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _run,
                        icon: const Icon(Icons.sync),
                        label: const Text('SYNC (Push+Pull)'),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
              const SizedBox(height: 12),
              Text('Journal', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_logs.isEmpty)
                const Text('Aucun message pour le moment.')
              else
                ..._logs.map(
                  (l) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(l),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
