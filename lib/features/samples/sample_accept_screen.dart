import 'package:flutter/material.dart';
import 'package:lstracker/data/services/auto_sync_manager.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:lstracker/widgets/global_bottom_nav.dart';

import '../../data/db/app_database.dart';
import '../../data/db/sample_dao.dart';
import '../../data/models/sample.dart';

class SampleAcceptScreen extends StatefulWidget {
  static const route = '/samples/accept';
  const SampleAcceptScreen({super.key});

  @override
  State<SampleAcceptScreen> createState() => _SampleAcceptScreenState();
}

class _SampleAcceptScreenState extends State<SampleAcceptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labNumberCtl = TextEditingController();
  final _patientCodeCtl = TextEditingController();
  final _dateCtl = TextEditingController();
  final _timeCtl = TextEditingController();

  final dao = SampleDao();

  Sample? _sample;
  String _destLabDisplay = '—';
  bool _loading = true;

  // Empêche le reboot sur ouverture clavier
  bool _bootstrapped = false;

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  @override
  void dispose() {
    _labNumberCtl.dispose();
    _patientCodeCtl.dispose();
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
    final id = (args?['id'] as int?) ?? (args?['sampleId'] as int?);
    if (id == null) {
      Navigator.of(context).pop();
      return;
    }
    _init(id);
  }

  void _updateDT() {
    String two(int n) => n.toString().padLeft(2, '0');
    _dateCtl.text = '${_date.year}-${two(_date.month)}-${two(_date.day)}';
    _timeCtl.text = '${two(_time.hour)}:${two(_time.minute)}';
  }

  Future<void> _init(int id) async {
    setState(() => _loading = true);
    final db = await AppDatabase.instance.database;
    try {
      final s = await dao.findById(id);
      String labText = '—';
      if (s?.destinationLabId != null) {
        final rows = await db.query(
          'lab',
          where: 'id = ?',
          whereArgs: [s!.destinationLabId],
          limit: 1,
        );
        if (rows.isNotEmpty) {
          labText = (rows.first['name'] ?? 'Labo #${s.destinationLabId}')
              .toString();
        } else {
          labText = 'Labo #${s!.destinationLabId}';
        }
      }
      if (!mounted) return;
      setState(() {
        _sample = s;
        _destLabDisplay = labText;
        _patientCodeCtl.text = s?.patientIdentifier ?? '';
      });
      _updateDT();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
        _updateDT();
      });
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) {
      setState(() {
        _time = t;
        _updateDT();
      });
    }
  }

  Future<void> _submit() async {
    if (_sample?.id == null) return;
    if (!_formKey.currentState!.validate()) return;

    final dt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final acceptedIso = dt.toIso8601String();

    try {
      final n = await dao.acceptOne(
        id: _sample!.id!,
        labNumber: _labNumberCtl.text.trim(),
        patientCode: _patientCodeCtl.text.trim(),
        acceptedDateIso: acceptedIso,
      );
      if (!mounted) return;
      if (n == 1) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Échantillon accepté.')));
        // Push en arrière-plan (fire-and-forget)
        AutoSyncManager.instance.pushNow();
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Aucune modification.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: AuthUtils.getUserRole(),
      builder: (context, snapshot) {
        final userRole = snapshot.data ?? 'ADMIN';
        return Scaffold(
          appBar: AppBar(title: const Text('Accepter l’échantillon')),
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
                      TextFormField(
                        readOnly: true,
                        initialValue: _destLabDisplay,
                        decoration: const InputDecoration(
                          labelText: 'Labo de destination',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _patientCodeCtl,
                        decoration: const InputDecoration(
                          labelText: 'Code patient',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Code du patient'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _labNumberCtl,
                        decoration: const InputDecoration(
                          labelText: 'Numéro labo attribué',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Saisissez un numéro labo'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateCtl,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Date d’acceptation',
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
                                labelText: 'Heure d’acceptation',
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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.verified_outlined),
                          label: const Text('Accepter'),
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
