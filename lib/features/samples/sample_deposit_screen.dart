import 'package:flutter/material.dart';
import 'package:lstracker/data/services/auto_sync_manager.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:lstracker/widgets/global_bottom_nav.dart';

import '../../data/db/app_database.dart';
import '../../data/db/sample_dao.dart';

class SampleDepositScreen extends StatefulWidget {
  static const route = '/samples/deposit';
  const SampleDepositScreen({super.key});

  @override
  State<SampleDepositScreen> createState() => _SampleDepositScreenState();
}

class _SampleDepositScreenState extends State<SampleDepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kmCtl = TextEditingController();
  final _dateCtl = TextEditingController();
  final _timeCtl = TextEditingController();

  final dao = SampleDao();

  // Bootstrap unique
  Set<int> _ids = {};
  bool _bootstrapped = false;

  // Meta
  List<Map<String, Object?>> _labs = const [];
  bool _loading = true;

  // Champs
  int? _labId;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  String _mode = 'select'; // 'select' | 'scan'

  @override
  void dispose() {
    _kmCtl.dispose();
    _dateCtl.dispose();
    _timeCtl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final idsArg =
        (args?['ids'] as List?)?.cast<int>() ??
        (args?['idsSet'] as Set<int>?) ??
        const <int>{};

    _ids = idsArg.toSet();

    _updateDateTimeControllers();
    _init();
  }

  void _updateDateTimeControllers() {
    String two(int n) => n.toString().padLeft(2, '0');
    _dateCtl.text = '${_date.year}-${two(_date.month)}-${two(_date.day)}';
    _timeCtl.text = '${two(_time.hour)}:${two(_time.minute)}';
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      final db = await AppDatabase.instance.database;

      // 1) Charger la liste des labos
      final labs = await db.query('lab', orderBy: 'name ASC');

      // 2) Tenter de pré-sélectionner le labo de destination d’un des échantillons sélectionnés
      int? preferredLabId;
      if (_ids.isNotEmpty) {
        final placeholders = List.filled(_ids.length, '?').join(',');
        final rs = await db.rawQuery('''
          SELECT destination_lab_id AS labId
          FROM sample
          WHERE id IN ($placeholders) AND destination_lab_id IS NOT NULL
          LIMIT 1
          ''', _ids.toList());
        if (rs.isNotEmpty) {
          preferredLabId =
              (rs.first['labId'] as int?) ??
              (rs.first['labId'] as num?)?.toInt();
        }
      }

      if (!mounted) return;
      setState(() {
        _labs = labs;

        // Si on a un preferredLabId et qu’il existe dans la liste, on l’utilise
        if (preferredLabId != null &&
            labs.any(
              (e) =>
                  ((e['id'] as int?) ?? (e['id'] as num?)?.toInt()) ==
                  preferredLabId,
            )) {
          _labId = preferredLabId;
        } else if (_labId == null && labs.isNotEmpty) {
          // Sinon, fallback sur le premier labo
          _labId =
              ((labs.first['id'] as int?) ??
              (labs.first['id'] as num?)?.toInt());
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<DropdownMenuItem<int>> _labItems() => _labs
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

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        _date = d;
        _updateDateTimeControllers();
      });
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) {
      setState(() {
        _time = t;
        _updateDateTimeControllers();
      });
    }
  }

  void _scanPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan labo non implémenté pour le moment.')),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_labId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez un laboratoire.')),
      );
      return;
    }
    if (_ids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun échantillon sélectionné.')),
      );
      return;
    }

    // Compose date+heure → ISO
    final dt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final deliveredIso = dt.toIso8601String();
    final endKm = _kmCtl.text.trim().isEmpty
        ? null
        : int.tryParse(_kmCtl.text.trim());

    try {
      final updated = await dao.depositToLabMany(
        _ids,
        labId: _labId!,
        deliveredDateIso: deliveredIso,
        endMileage: endKm,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Déposé au labo: $updated / ${_ids.length}')),
      );
      // Push en arrière-plan (fire-and-forget)
      AutoSyncManager.instance.pushNow();
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _ids.length;
    return FutureBuilder<String?>(
      future: AuthUtils.getUserRole(),
      builder: (context, snapshot) {
        final userRole = snapshot.data ?? 'ADMIN';
        return Scaffold(
          appBar: AppBar(title: Text('Dépôt au labo — $count sélection(s)')),
          bottomNavigationBar: GlobalBottomNav(
            current: BottomTab.accept,
            userRole: userRole,
          ),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Mode
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'select',
                            label: Text('Sélectionner'),
                          ),
                          ButtonSegment(value: 'scan', label: Text('Scanner')),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (s) =>
                            setState(() => _mode = s.first),
                      ),
                      const SizedBox(height: 12),

                      if (_mode == 'scan') ...[
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.qr_code_scanner),
                            title: const Text('Scanner le code du labo'),
                            subtitle: const Text('Bientôt disponible'),
                            onTap: _scanPlaceholder,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Labo
                      DropdownButtonFormField<int>(
                        value: _labId,
                        isExpanded: true,
                        items: _labItems(),
                        decoration: const InputDecoration(
                          labelText: 'Laboratoire de livraison',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => _labId = v),
                        validator: (v) =>
                            v == null ? 'Choisissez un laboratoire' : null,
                      ),
                      const SizedBox(height: 12),

                      // Date / Heure
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateCtl,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Date de dépôt',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                  onPressed: _pickDate,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _timeCtl,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Heure de dépôt',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.access_time),
                                  onPressed: _pickTime,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Km fin
                      TextFormField(
                        controller: _kmCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Kilométrage d’arrivée (fin collecte)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Saisissez le kilométrage';
                          if (int.tryParse(v.trim()) == null)
                            return 'Kilométrage invalide';
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.biotech_outlined),
                          label: const Text('Déposer'),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
