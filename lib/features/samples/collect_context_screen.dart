import 'package:flutter/material.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:lstracker/widgets/global_bottom_nav.dart';

import '../../data/db/app_database.dart';

class CollectContextScreen extends StatefulWidget {
  static const route = '/samples/collect-context';
  const CollectContextScreen({super.key});

  @override
  State<CollectContextScreen> createState() => _CollectContextScreenState();
}

class _CollectContextScreenState extends State<CollectContextScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mileageCtl = TextEditingController();

  String _mode = 'select';

  List<Map<String, Object?>> _circuits = const [];
  List<Map<String, Object?>> _allSites = const [];

  int? _circuitId;
  int? _siteId;

  bool _fetching = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    setState(() {
      _fetching = true;
      _loadError = null;
    });
    try {
      final db = await AppDatabase.instance.database;
      final circuits = await db.query('circuit', orderBy: 'name ASC');
      final sites = await db.query('site', orderBy: 'name ASC');

      if (!mounted) return;
      setState(() {
        _circuits = circuits;
        _allSites = sites;
      });

      if ((_circuits.isEmpty || _allSites.isEmpty) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aucune métadonnée trouvée (circuit/site). Pense à synchroniser depuis le backend.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadError = 'Échec de chargement: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  List<DropdownMenuItem<int>> _circuitItems() => _circuits
      .map(
        (e) => DropdownMenuItem<int>(
          value: (e['id'] as int?) ?? (e['id'] as num?)?.toInt(),
          child: Text(
            (e['name'] ?? '').toString(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
      .toList();

  Future<List<Map<String, Object?>>> _sitesForCircuit(int? circuitId) async {
    if (circuitId == null) return _allSites;
    final db = await AppDatabase.instance.database;
    return db.rawQuery(
      '''
      SELECT s.*
      FROM site s
      INNER JOIN circuit_site cs ON cs.site_id = s.id
      WHERE cs.circuit_id = ?
      ORDER BY s.name ASC
    ''',
      [circuitId],
    );
  }

  List<DropdownMenuItem<int>> _siteItemsFrom(List<Map<String, Object?>> rows) {
    return rows
        .map(
          (e) => DropdownMenuItem<int>(
            value: (e['id'] as int?) ?? (e['id'] as num?)?.toInt(),
            child: Text(
              (e['name'] ?? '').toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        )
        .toList();
  }

  List<Widget> _selectedSiteBuilder(List<Map<String, Object?>> rows) {
    return rows
        .map(
          (e) => Align(
            alignment: Alignment.centerLeft,
            child: Text(
              (e['name'] ?? '').toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
            ),
          ),
        )
        .toList();
  }

  void _scanPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan non implémenté pour le moment.')),
    );
  }

  void _next() {
    if (_mode == 'scan') {
      _scanPlaceholder();
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pushNamed(
      '/samples/collect',
      arguments: {
        'circuitId': _circuitId!,
        'siteId': _siteId!,
        'mileage': int.parse(_mileageCtl.text.trim()),
      },
    );
  }

  @override
  void dispose() {
    _mileageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fetching) {
      return FutureBuilder<String?>(
        future: AuthUtils.getUserRole(),
        builder: (context, snapshot) {
          final userRole = snapshot.data ?? 'ADMIN';
          return Scaffold(
            appBar: AppBar(title: const Text('Définir le site & kilométrage')),
            bottomNavigationBar: GlobalBottomNav(
              current: BottomTab.collect,
              userRole: userRole,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    final hasMeta = _circuits.isNotEmpty && _allSites.isNotEmpty;
    return FutureBuilder<String?>(
      future: AuthUtils.getUserRole(),
      builder: (context, snapshot) {
        final userRole = snapshot.data ?? 'ADMIN';
        return Scaffold(
          appBar: AppBar(title: const Text('Définir le site & kilométrage')),
          bottomNavigationBar: GlobalBottomNav(
            current: BottomTab.collect,
            userRole: userRole,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_loadError != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: ListTile(
                    leading: const Icon(Icons.error_outline),
                    title: const Text(
                      'Erreur de chargement',
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _loadError!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: 'Réessayer',
                      onPressed: _loadMeta,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                ),
              if (!hasMeta)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text(
                      'Métadonnées absentes',
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: const Text(
                      'Aucun circuit ou site disponible. Synchronise tes métadonnées puis réessaie.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: 'Recharger',
                      onPressed: _loadMeta,
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                ),

              // SegmentedButton avec scroll horizontal pour éviter overflow
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'select', label: Text('Sélectionner')),
                    ButtonSegment(value: 'scan', label: Text('Scanner')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
              ),
              const SizedBox(height: 16),

              if (_mode == 'scan') ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Scanner le code du site'),
                    subtitle: const Text('Bientôt disponible'),
                    onTap: _scanPlaceholder,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mileageCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kilométrage',
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else ...[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        value: _circuitId,
                        items: _circuitItems(),
                        decoration: const InputDecoration(
                          labelText: 'Circuit',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: hasMeta
                            ? (v) => setState(() {
                                _circuitId = v;
                                _siteId = null; // reset
                              })
                            : null,
                        validator: (v) =>
                            v == null ? 'Choisissez un circuit' : null,
                      ),
                      const SizedBox(height: 12),

                      FutureBuilder<List<Map<String, Object?>>>(
                        future: _sitesForCircuit(_circuitId),
                        builder: (context, snapshot) {
                          final rows =
                              snapshot.data ?? const <Map<String, Object?>>[];
                          final items = _siteItemsFrom(rows);
                          final selectedWidgets = _selectedSiteBuilder(rows);

                          return DropdownButtonFormField<int>(
                            value: _siteId,
                            items: items,
                            isExpanded: true, // important
                            selectedItemBuilder: (ctx) => selectedWidgets,
                            decoration: const InputDecoration(
                              labelText: 'Site',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onChanged: hasMeta
                                ? (v) => setState(() => _siteId = v)
                                : null,
                            validator: (v) =>
                                v == null ? 'Choisissez un site' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _mileageCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Kilométrage (arrivée site)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Saisissez le kilométrage';
                          if (int.tryParse(v.trim()) == null)
                            return 'Kilométrage invalide';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continuer'),
                  onPressed: (_mode == 'select' && !hasMeta) ? null : _next,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
