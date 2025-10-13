import 'package:flutter/material.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:lstracker/widgets/global_bottom_nav.dart';

import '../../data/db/sample_dao.dart';
import '../../data/models/sample.dart';
import 'results_deposit_form_screen.dart';

class ResultsCollectedListScreen extends StatefulWidget {
  static const route = '/results-collected/list';
  const ResultsCollectedListScreen({super.key});

  @override
  State<ResultsCollectedListScreen> createState() =>
      _ResultsCollectedListScreenState();
}

class _ResultsCollectedListScreenState
    extends State<ResultsCollectedListScreen> {
  final dao = SampleDao();

  bool _bootstrapped = false;
  bool _loading = true;
  String? _error;

  late int _siteId;
  late String _siteLabel;
  late String _siteName;

  final _searchCtl = TextEditingController();
  List<Sample> _items = const [];
  final Set<int> _selected = {};

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    _siteId = (args?['siteId'] as int?) ?? 0;
    _siteName = (args?['siteName'] as String?) ?? '';
    _siteLabel = (args?['siteLabel'] as String?) ?? 'Site';
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await dao.listCollectedBySite(
        siteId: _siteId,
        siteName: _siteName,
        query: _searchCtl.text.trim().isEmpty ? null : _searchCtl.text.trim(),
        limit: 500,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _selected.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggle(int id, bool v) {
    setState(() {
      if (v) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
  }

  Future<void> _openDeposit({required Set<int> ids}) async {
    if (ids.isEmpty) return;
    final changed = await Navigator.of(context).pushNamed(
      ResultsDepositFormScreen.route,
      arguments: {
        'ids': ids.toList(),
        'siteId': _siteId,
        'siteLabel': _siteLabel,
      },
    );
    if (changed == true) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dépôt enregistré.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDeposit = _selected.isNotEmpty;
    return FutureBuilder<String?>(
      future: AuthUtils.getUserRole(),
      builder: (context, snapshot) {
        final userRole = snapshot.data ?? 'ADMIN';
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Résultats récupérés'),
                Text(_siteLabel, style: const TextStyle(fontSize: 12)),
              ],
            ),
            actions: [
              if (_items.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _openDeposit(
                    ids: _items
                        .where((e) => e.id != null)
                        .map((e) => e.id!)
                        .toSet(),
                  ),
                  icon: const Icon(
                    Icons.done_all,
                    color: Color.fromARGB(255, 54, 1, 52),
                  ),
                  label: const Text(
                    'Tout déposer',
                    style: TextStyle(color: Color.fromARGB(255, 13, 13, 13)),
                  ),
                ),
            ],
          ),
          floatingActionButton: canDeposit
              ? FloatingActionButton.extended(
                  icon: const Icon(Icons.assignment_turned_in_outlined),
                  label: const Text('Déposer sélection'),
                  onPressed: () => _openDeposit(ids: _selected),
                )
              : null,
          bottomNavigationBar: GlobalBottomNav(
            current: BottomTab.collect,
            userRole: userRole,
          ),

          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : _items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucun résultat récupéré pour ce site.\n'
                          'Rien à déposer pour le moment.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final s = _items[i];
                      final id = s.id!;
                      final subtitle = [
                        if ((s.patientIdentifier ?? '').isNotEmpty)
                          'Patient: ${s.patientIdentifier}',
                        if ((s.sampleIdentifier ?? '').isNotEmpty)
                          'ID: ${s.sampleIdentifier}',
                        if ((s.sampleNature ?? '').isNotEmpty)
                          'Nature échantillon: ${s.sampleNature}',
                        if ((s.labNumber ?? '').isNotEmpty)
                          'Numéro Labo: ${s.labNumber}',
                        if ((s.collectionDate ?? '').isNotEmpty)
                          'Prélèvement: ${s.collectionDate}',
                        if ((s.analysisReleasedDate ?? '').isNotEmpty)
                          'Date de Validation: ${s.analysisReleasedDate}',
                      ].join('\n');

                      return Card(
                        child: CheckboxListTile(
                          value: _selected.contains(id),
                          onChanged: (v) => _toggle(id, v ?? false),
                          title: Text(
                            s.sampleIdentifier?.isNotEmpty == true
                                ? s.sampleIdentifier!
                                : (s.uuid ?? '—'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: subtitle.isEmpty ? null : Text(subtitle),
                        ),
                      );
                    },
                  ),
                ),
        );
      },
    );
  }
}
