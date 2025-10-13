import 'package:flutter/material.dart';
import 'package:lstracker/data/services/auto_sync_manager.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:lstracker/widgets/global_bottom_nav.dart';

import '../../data/db/app_database.dart';
import '../../data/db/sample_dao.dart';

class SampleRejectScreen extends StatefulWidget {
  static const route = '/samples/reject';
  const SampleRejectScreen({super.key});

  @override
  State<SampleRejectScreen> createState() => _SampleRejectScreenState();
}

class _SampleRejectScreenState extends State<SampleRejectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentCtl = TextEditingController();
  final _dateCtl = TextEditingController();
  final _timeCtl = TextEditingController();

  final dao = SampleDao();

  Set<int> _ids = {};
  bool _loading = true;

  // Empêche les resets quand MediaQuery change (clavier)
  bool _bootstrapped = false;

  // meta
  List<Map<String, Object?>> _rejectionTypes = const [];
  int? _rejectionTypeId;

  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();

  @override
  void dispose() {
    _commentCtl.dispose();
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

    _updateDT();
    _init();
  }

  void _updateDT() {
    String two(int n) => n.toString().padLeft(2, '0');
    _dateCtl.text = '${_date.year}-${two(_date.month)}-${two(_date.day)}';
    _timeCtl.text = '${two(_time.hour)}:${two(_time.minute)}';
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      final db = await AppDatabase.instance.database;
      final rt = await db.query('rejection_type', orderBy: 'name ASC');
      if (!mounted) return;
      setState(() {
        _rejectionTypes = rt;
        if (rt.isNotEmpty) {
          _rejectionTypeId =
              (rt.first['id'] as int?) ?? (rt.first['id'] as num?)?.toInt();
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<DropdownMenuItem<int>> _rtItems() => _rejectionTypes
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
    if (_ids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun échantillon sélectionné.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_rejectionTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez un motif de rejet.')),
      );
      return;
    }

    final dt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final iso = dt.toIso8601String();

    try {
      final n = await dao.rejectMany(
        ids: _ids,
        rejectionTypeId: _rejectionTypeId!,
        comment: _commentCtl.text.trim().isEmpty
            ? null
            : _commentCtl.text.trim(),
        rejectionDateIso: iso,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Rejeté: $n / ${_ids.length}')));
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
          appBar: AppBar(title: Text('Rejeter — $count sélection(s)')),
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
                      DropdownButtonFormField<int>(
                        value: _rejectionTypeId,
                        isExpanded: true,
                        items: _rtItems(),
                        decoration: const InputDecoration(
                          labelText: 'Motif de rejet',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => _rejectionTypeId = v),
                        validator: (v) =>
                            v == null ? 'Choisissez un motif' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _commentCtl,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Commentaire (optionnel)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateCtl,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Date de rejet',
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
                                labelText: 'Heure de rejet',
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
                          icon: const Icon(Icons.block),
                          label: const Text('Rejeter'),
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
