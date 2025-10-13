import 'package:flutter/material.dart';
import 'package:lstracker/data/services/auto_sync_manager.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:lstracker/widgets/global_bottom_nav.dart';

import '../../data/db/sample_dao.dart';

class ResultsDepositFormScreen extends StatefulWidget {
  static const route = '/results-collected/deposit-form';
  const ResultsDepositFormScreen({super.key});

  @override
  State<ResultsDepositFormScreen> createState() =>
      _ResultsDepositFormScreenState();
}

class _ResultsDepositFormScreenState extends State<ResultsDepositFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kmCtl = TextEditingController();
  final _dateCtl = TextEditingController();
  final _timeCtl = TextEditingController();

  final dao = SampleDao();

  Set<int> _ids = {};
  String _siteLabel = 'Site';
  bool _bootstrapped = false;

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

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
    final idsArg = (args?['ids'] as List?)?.cast<int>() ?? const <int>[];
    _ids = idsArg.toSet();
    _siteLabel = (args?['siteLabel'] as String?) ?? 'Site';

    _syncDT();
  }

  void _syncDT() {
    String two(int n) => n.toString().padLeft(2, '0');
    _dateCtl.text = '${_date.year}-${two(_date.month)}-${two(_date.day)}';
    _timeCtl.text = '${two(_time.hour)}:${two(_time.minute)}';
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
        _syncDT();
      });
    }
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) {
      setState(() {
        _time = t;
        _syncDT();
      });
    }
  }

  Future<void> _submit() async {
    if (_ids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun échantillon sélectionné.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final dt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final iso = dt.toIso8601String();

    final endKm = int.tryParse(_kmCtl.text.trim());

    try {
      final n = await dao.depositResultsMany(
        _ids,
        deliveredDateIso: iso,
        endMileage: endKm,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Résultats déposés: $n / ${_ids.length}')),
      );
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
          appBar: AppBar(
            title: Text('Déposer résultats — $_siteLabel ($count)'),
          ),
          bottomNavigationBar: GlobalBottomNav(
            current: BottomTab.collect,
            userRole: userRole,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _kmCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Kilométrage arrivé (dépôt résultats)',
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
                const SizedBox(height: 12),
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
                            icon: const Icon(Icons.calendar_month_outlined),
                            onPressed: _pickDate,
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Choisissez la date'
                            : null,
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
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Choisissez l’heure'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.assignment_turned_in_outlined),
                    label: const Text('Enregistrer le dépôt'),
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
