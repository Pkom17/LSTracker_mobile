import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lstracker/features/samples/sample_analysis_fail_screen.dart';
import 'package:lstracker/features/samples/sample_result_ready_screen.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:lstracker/utils/custom_date_utils.dart';
import 'package:lstracker/widgets/global_bottom_nav.dart';

import '../../data/db/sample_dao.dart';
import '../../data/models/sample.dart';
import 'sample_accept_screen.dart';
import 'sample_deposit_edit_screen.dart';
import 'sample_deposit_screen.dart';
import 'sample_detail_screen.dart';
import 'sample_edit_screen.dart';
import 'sample_reject_screen.dart';
import 'sample_result_collect_screen.dart';

class SampleListScreen extends StatefulWidget {
  static const route = '/samples/list';
  const SampleListScreen({super.key});

  @override
  State<SampleListScreen> createState() => _SampleListScreenState();
}

class _SampleListScreenState extends State<SampleListScreen> {
  final dao = SampleDao();
  String? status;
  List<String>? statuses;
  String type = 'Autre';

  final _searchCtl = TextEditingController();
  Timer? _debounce;

  bool loading = true;
  List<Sample> items = const [];

  // Sélection
  bool selectMode = false;
  final Set<int> selectedIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    statuses = (args?['statuses'] as List?)?.map((e) => e.toString()).toList();
    status = (args?['status'] as String?) ?? (statuses?.first);
    type = (args?['type'] as String?) ?? type;
    _load();
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final data = await dao.listByTypeAndStatus(
      type: type,
      status: status!,
      statuses: statuses,
      query: _searchCtl.text.trim().isEmpty ? null : _searchCtl.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      items = data;
      loading = false;
      // si des éléments ont disparu, nettoie la sélection
      selectedIds.removeWhere((id) => items.indexWhere((s) => s.id == id) < 0);
      if (selectedIds.isEmpty) selectMode = false;
    });
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
  }

  // --- Sélection ---
  void _enterSelectModeWith(Sample s) {
    if (s.id == null) return;
    setState(() {
      selectMode = true;
      selectedIds
        ..clear()
        ..add(s.id!);
    });
  }

  void _toggleSelection(Sample s) {
    if (s.id == null) return;
    setState(() {
      if (selectedIds.contains(s.id)) {
        selectedIds.remove(s.id);
        if (selectedIds.isEmpty) selectMode = false;
      } else {
        selectedIds.add(s.id!);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      selectedIds.clear();
      selectMode = false;
    });
  }

  bool get _isCollected => status == SampleStatus.onTransit;
  bool get _isDelivered =>
      (status == SampleStatus.receivedAtDistrictLab ||
      status == SampleStatus.receivedAtHub ||
      status == SampleStatus.receivedAtReferenceLab ||
      status == SampleStatus.receivedAtTbLab);
  bool get _isAccepted =>
      (status == SampleStatus.acceptedAtDistrictLab ||
      status == SampleStatus.acceptedAtHub ||
      status == SampleStatus.acceptedAtReferenceLab ||
      status == SampleStatus.acceptedAtTbLab);
  bool get _canEditOne => selectedIds.length == 1;
  bool get _canDeleteOne => selectedIds.length == 1;
  bool get _canDepositMany => selectedIds.isNotEmpty;

  void _actionDepositMany() async {
    final ids = selectedIds.toList();
    final changed = await Navigator.of(
      context,
    ).pushNamed(SampleDepositScreen.route, arguments: {'ids': ids});
    _clearSelection();
    if (changed == true) {
      await _load();
    }
  }

  void _actionEditOne() async {
    final id = selectedIds.first;
    final changed = await Navigator.of(
      context,
    ).pushNamed(SampleEditScreen.route, arguments: {'id': id});
    _clearSelection();
    if (changed == true) {
      await _load();
    }
  }

  void _actionDeleteOne() async {
    final id = selectedIds.first;
    final sample = items.firstWhere((s) => s.id == id);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text(
          'Supprimer cet échantillon ?\n${sample.sampleIdentifier ?? sample.uuid}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => loading = true);
    try {
      final n = await dao.deleteById(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            n == 1 ? 'Échantillon supprimé' : 'Aucune ligne supprimée',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      _clearSelection();
      await _load();
    }
  }

  // Modifier le dépôt (sélection unique)
  void _actionEditDepositOne() async {
    if (selectedIds.length != 1) return;
    final id = selectedIds.first;
    final changed = await Navigator.of(
      context,
    ).pushNamed(SampleDepositEditScreen.route, arguments: {'id': id});
    _clearSelection();
    if (changed == true) await _load();
  }

  // Accepter (sélection unique)
  void _actionAcceptOne() async {
    if (selectedIds.length != 1) return;
    final id = selectedIds.first;
    final changed = await Navigator.of(
      context,
    ).pushNamed(SampleAcceptScreen.route, arguments: {'id': id});
    _clearSelection();
    if (changed == true) await _load();
  }

  // Rejeter (sélection multiple OK)
  void _actionRejectMany() async {
    if (selectedIds.isEmpty) return;
    final ids = selectedIds.toList();
    final changed = await Navigator.of(
      context,
    ).pushNamed(SampleRejectScreen.route, arguments: {'ids': ids});
    _clearSelection();
    if (changed == true) await _load();
  }

  void _actionResultReadyOne() async {
    if (selectedIds.length != 1) return;
    final id = selectedIds.first;
    final changed = await Navigator.of(
      context,
    ).pushNamed(SampleResultReadyScreen.route, arguments: {'id': id});
    _clearSelection();
    if (changed == true) await _load();
  }

  void _actionAnalysisFailedMany() async {
    if (selectedIds.isEmpty) return;
    final changed = await Navigator.of(context).pushNamed(
      SampleAnalysisFailScreen.route,
      arguments: {'ids': selectedIds.toList()},
    );
    _clearSelection();
    if (changed == true) await _load();
  }

  void _actionCollectResultsMany() async {
    if (selectedIds.isEmpty) return;
    final changed = await Navigator.of(context).pushNamed(
      SampleResultCollectScreen.route,
      arguments: {'ids': selectedIds.toList()},
    );
    _clearSelection();
    if (changed == true) await _load(); // recharger la liste
  }

  String _statusLabel(String s) {
    switch (s.toUpperCase()) {
      case 'COLLECTED':
        return 'ÉCHANTILLONS COLLECTÉS';
      case 'DELIVERED':
        return 'ÉCHANTILLONS DÉPOSÉS AU LABO';
      case 'RECEIVED':
        return 'ÉCHANTILLONS REÇUS AU LABO';
      case 'RESULT_READY':
        return 'RÉSULTATS PRÊTS';
      case 'RESULT_COLLECTED':
        return 'RÉSULTATS RÉCUPÉRÉS';
      case 'RESULT_DELIVERED':
        return 'RÉSULTATS DÉPOSÉS SUR SITE';
      case 'REJECTED':
        return 'ÉCHANTILLONS REJETÉS';
      default:
        return s.toUpperCase();
    }
  }

  PreferredSizeWidget _buildAppBar() {
    /* if (!selectMode) {
      final title = 'Liste échantillons $type';
      final statusText = _statusLabel(status ?? 'STATUT INCONNU');
      return AppBar(
        title: Text(title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            alignment: Alignment.centerLeft,
           child: Row(
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    statusText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }*/

    final n = selectedIds.length;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _clearSelection,
        tooltip: 'Annuler',
      ),
      title: Text('$n sélectionné${n > 1 ? 's' : ''}'),
      actions: [
        if (_isCollected) ...[
          IconButton(
            tooltip: 'Déposer au labo',
            onPressed: _canDepositMany ? _actionDepositMany : null,
            icon: const Icon(Icons.biotech_outlined),
          ),
          IconButton(
            tooltip: 'Modifier',
            onPressed: _canEditOne ? _actionEditOne : null,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Supprimer',
            onPressed: _canDeleteOne ? _actionDeleteOne : null,
            icon: const Icon(Icons.delete_outline),
          ),
        ] else if (_isAccepted) ...[
          IconButton(
            tooltip: 'Résultat prêt',
            onPressed: _canEditOne ? _actionResultReadyOne : null,
            icon: const Icon(Icons.assignment_turned_in_outlined),
          ),
          IconButton(
            tooltip: 'Analyses échouées',
            onPressed: selectedIds.isNotEmpty
                ? _actionAnalysisFailedMany
                : null,
            icon: const Icon(Icons.report_problem_outlined),
          ),
        ] else if (_isDelivered) ...[
          IconButton(
            tooltip: 'Accepter',
            onPressed: _canEditOne ? _actionAcceptOne : null,
            icon: const Icon(Icons.verified_outlined),
          ),
          IconButton(
            tooltip: 'Rejeter',
            onPressed: selectedIds.isNotEmpty ? _actionRejectMany : null,
            icon: const Icon(Icons.block_outlined),
          ),
          IconButton(
            tooltip: 'Modifier le dépôt',
            onPressed: _canEditOne ? _actionEditDepositOne : null,
            icon: const Icon(Icons.edit_outlined),
          ),
        ] else if (status == SampleStatus.analysisDone) ...[
          IconButton(
            tooltip: 'Collecter résultats',
            onPressed: selectedIds.isNotEmpty
                ? _actionCollectResultsMany
                : null,
            icon: const Icon(Icons.assignment_turned_in_outlined),
          ),
        ],
      ],
    );
  }

  Widget _tileFor(Sample s) {
    final title = s.sampleIdentifier?.isNotEmpty == true
        ? s.sampleIdentifier!
        : (s.uuid ?? '—');

    final subtitleParts = <String>[];
    if (s.patientIdentifier?.isNotEmpty == true) {
      subtitleParts.add('Patient: ${s.patientIdentifier}');
    }
    if (s.collectionDate?.isNotEmpty == true) {
      subtitleParts.add('Prélèvement: ${CustomDateUtils.toHumanReadable(s.collectionDate)}');
    }
    if (s.sampleNature?.isNotEmpty == true) {
      subtitleParts.add('Nature: ${s.sampleNature}');
    }
    if (s.labNumber?.isNotEmpty == true) {
      subtitleParts.add('Numéro Labo: ${s.labNumber}');
    }
    if (s.fromSiteName != null && s.fromSiteName!.isNotEmpty) {
      subtitleParts.add('Site: ${s.fromSiteName}');
    }
    final subtitle = subtitleParts.join('\n');

    final isChecked = s.id != null && selectedIds.contains(s.id);
    final isDirty = (s.dirty) == 1;

    // Icône synchronisation
    final syncIcon = Tooltip(
      message: isDirty ? 'Non synchronisé' : 'Synchronisé avec le serveur',
      child: Icon(
        isDirty ? Icons.cloud_upload : Icons.cloud_done,
        color: isDirty ? Colors.orange : Colors.green,
      ),
    );

    if (selectMode) {
      // Mode sélection : case à cocher
      return Card(
        elevation: 0.7,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: CheckboxListTile(
          value: isChecked,
          onChanged: (_) => _toggleSelection(s),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            subtitle,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          secondary: syncIcon,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      );
    }

    // Mode normal
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.biotech_outlined),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 5, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            syncIcon,
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          if (selectMode) return; // en mode sélection, on n’ouvre pas
          if (s.id == null) return;
          Navigator.of(
            context,
          ).pushNamed(SampleDetailScreen.route, arguments: {'id': s.id});
        },
        onLongPress: () => _enterSelectModeWith(s),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthUtils.getUserRole(),
      builder: (context, snapshot) {
        final userRole = snapshot.data ?? 'ADMIN';
        return Scaffold(
          appBar: _buildAppBar(),
          bottomNavigationBar: GlobalBottomNav(
            current: BottomTab.collect,
            userRole: userRole,
          ),
          body: Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: TextField(
                  controller: _searchCtl,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Rechercher (patient, échantillon)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ),
              ),

              // Liste
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : items.isEmpty
                      ? const Center(child: Text('Aucun échantillon trouvé.'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, i) => _tileFor(items[i]),
                        ),
                ),
              ),
            ],
          ),

          // Action flottante qui bascule la sélection même sans long-press
          floatingActionButton: loading || items.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      if (selectMode) {
                        _clearSelection();
                      } else {
                        selectMode = true;
                      }
                    });
                  },
                  icon: Icon(
                    selectMode ? Icons.close : Icons.checklist_outlined,
                  ),
                  label: Text(selectMode ? 'Annuler' : 'Sélectionner'),
                ),
        );
      },
    );
  }
}
