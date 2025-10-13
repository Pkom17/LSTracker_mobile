import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lstracker/data/services/auto_sync_manager.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:lstracker/widgets/global_bottom_nav.dart';
import 'package:uuid/uuid.dart';

import '../../data/db/app_database.dart';
import '../../data/db/sample_dao.dart';
import '../../data/models/sample.dart';

class CollectSampleScreen extends StatefulWidget {
  static const route = '/samples/collect';
  const CollectSampleScreen({super.key});

  @override
  State<CollectSampleScreen> createState() => _CollectSampleScreenState();
}

class _CollectSampleScreenState extends State<CollectSampleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mileageCtl = TextEditingController();
  final _patientCtl = TextEditingController();
  final _sampleIdCtl = TextEditingController();
  final _collectionDateCtl = TextEditingController();
  final _collectionTimeCtl = TextEditingController();
  final _pickupDateCtl = TextEditingController();

  // Sélections
  int? _circuitId;
  int? _siteId;
  String _circuitName = '';
  String _siteName = '';

  int? _labId;
  String? _sampleType; // CV, EID, HPV, TB, BI, BS, Autre
  String? _sampleNature; // sang total, plasma, etc.

  // Données de référence
  List<Map<String, Object?>> _labs = const [];

  // UI
  bool _saving = false;
  bool _keepSiteAndMileage = true;

  final _dao = SampleDao();

  @override
  void initState() {
    super.initState();
    //_loadMetadata();
    _prefillDefaults();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    _circuitId = (args?['circuitId'] as int?);
    _siteId = (args?['siteId'] as int?);
    final mileage = (args?['mileage'] as int?);
    if (mileage != null) _mileageCtl.text = mileage.toString();
    _loadFixedNames();
    _loadLabs();
  }

  Future<void> _loadFixedNames() async {
    if (_circuitId == null || _siteId == null) return;
    final db = await AppDatabase.instance.database;
    final c = await db.query(
      'circuit',
      where: 'id=?',
      whereArgs: [_circuitId],
      limit: 1,
    );
    final s = await db.query(
      'site',
      where: 'id=?',
      whereArgs: [_siteId],
      limit: 1,
    );
    if (!mounted) return;
    setState(() {
      _circuitName = (c.isNotEmpty ? (c.first['name'] ?? '') : '').toString();
      _siteName = (s.isNotEmpty ? (s.first['name'] ?? '') : '').toString();
    });
  }

  Future<void> _loadLabs() async {
    final db = await AppDatabase.instance.database;
    final labs = await db.query('lab', orderBy: 'name ASC');
    if (!mounted) return;
    setState(() => _labs = labs);
  }

  /// Pré-remplit la date/heure de prélèvement (aujourd’hui), et pickupDate à maintenant.
  void _prefillDefaults() {
    final now = DateTime.now();
    final d = DateFormat('yyyy-MM-dd').format(now);
    final t = DateFormat('HH:mm').format(now);
    _collectionDateCtl.text = d;
    _collectionTimeCtl.text = t;
    _pickupDateCtl.text = DateFormat('yyyy-MM-dd HH:mm').format(now);
  }

  @override
  void dispose() {
    _mileageCtl.dispose();
    _patientCtl.dispose();
    _sampleIdCtl.dispose();
    _collectionDateCtl.dispose();
    _collectionTimeCtl.dispose();
    _pickupDateCtl.dispose();
    super.dispose();
  }

  // Utilitaires de choix date/heure
  Future<void> _pickDate(TextEditingController ctl) async {
    final init = DateTime.tryParse(ctl.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 1, 1),
    );
    if (picked != null) {
      ctl.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _pickTime(TextEditingController ctl) async {
    final parts = ctl.text.split(':');
    final init = TimeOfDay(
      hour: int.tryParse(parts.firstOrNull ?? '') ?? TimeOfDay.now().hour,
      minute:
          int.tryParse(parts.elementAtOrNull(1) ?? '') ??
          TimeOfDay.now().minute,
    );
    final picked = await showTimePicker(context: context, initialTime: init);
    if (picked != null) {
      ctl.text = picked.format(context);
      // normaliser en HH:mm 24h
      final dt = DateTime(0, 1, 1, picked.hour, picked.minute);
      ctl.text = DateFormat('HH:mm').format(dt);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      // Construit les timestamps ISO simples
      final collectionDate = _collectionDateCtl.text.trim();
      final collectionTime = _collectionTimeCtl.text.trim();
      String? collectionDateTimeIso;
      if (collectionDate.isNotEmpty && collectionTime.isNotEmpty) {
        // concat en local time (on garde en TEXT dans SQLite comme ton schéma)
        collectionDateTimeIso = '${collectionDate}T$collectionTime';
      }

      final uuid = _makeUuid();

      // Crée l’objet Sample local
      final sample = Sample(
        // id: autoincr par SQLite
        externalId: null,
        uuid: uuid,
        sampleConveyor: await AuthUtils.getUserId(),
        referringSampleId: null,
        startMileage: int.tryParse(_mileageCtl.text.trim()),
        fromSiteCode: null,
        fromSiteName: _siteName,
        fromSiteId: _siteId,
        sampleType: _sampleType,
        sampleNature: _sampleNature,
        destinationLabId: _labId,
        sampleIdentifier: _sampleIdCtl.text.trim().isEmpty
            ? null
            : _sampleIdCtl.text.trim(),
        patientIdentifier: _patientCtl.text.trim().isEmpty
            ? null
            : _patientCtl.text.trim(),
        collectionDate: collectionDateTimeIso, // "yyyy-MM-ddTHH:mm"
        pickupDate: _pickupDateCtl.text.trim().isEmpty
            ? null
            : _pickupDateCtl.text.trim(),
        labNumber: null,
        endMileage: null,
        sampleStatus: SampleStatus.onTransit, // COLLECTED
        deliveredDate: null,
        deliveredLabId: null,
        acceptedDate: null,
        analysisStartedDate: null,
        analysisCompletedDate: null,
        analysisReleasedDate: null,
        resultCollectionDate: null,
        resultDeliveredDate: null,
        resultCollector: null,
        rejectionTypeId: null,
        rejectionComment: null,
        rejectionDate: null,
        resultStartMileage: null,
        resultEndMileage: null,
        createdAt: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        lastupdatedAt: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        dirty: 1,
      );

      // Insère en base (local)
      await _dao.insertSample(sample);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échantillon enregistré localement.')),
      );

      // 3) Push en arrière-plan (fire-and-forget)
      AutoSyncManager.instance.pushNow();

      // Après succès : conserver site + kilométrage si souhaité
      if (_keepSiteAndMileage) {
        _patientCtl.clear();
        _sampleIdCtl.clear();
        _prefillDefaults(); // régénère dates
        // ne pas effacer site/mileage
      } else {
        _formKey.currentState!.reset();
        _mileageCtl.clear();
        _patientCtl.clear();
        _sampleIdCtl.clear();
        _collectionDateCtl.clear();
        _collectionTimeCtl.clear();
        _pickupDateCtl.clear();
        setState(() {
          _circuitId = null;
          _siteId = null;
          _labId = null;
          _sampleType = null;
          _sampleNature = null;
        });
        _prefillDefaults();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’enregistrement : $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _makeUuid() {
    var uuid = Uuid();
    return uuid.v4();
  }

  List<DropdownMenuItem<int>> _labItems() => _labs
      .map(
        (e) => DropdownMenuItem<int>(
          value: (e['id'] as int?) ?? (e['id'] as num?)?.toInt(),
          child: Text((e['name'] ?? '').toString()),
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final pad = EdgeInsets.symmetric(vertical: 8);
    return FutureBuilder<String?>(
      future: AuthUtils.getUserRole(),
      builder: (context, snapshot) {
        final userRole = snapshot.data ?? 'ADMIN';
        return Scaffold(
          appBar: AppBar(title: const Text('Collecter un échantillon')),
          bottomNavigationBar: GlobalBottomNav(
            current: BottomTab.collect,
            userRole: userRole,
          ),
          body: _labs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Circuit
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(
                            _siteName.isEmpty ? 'Site #$_siteId' : _siteName,
                          ),
                          subtitle: Text(
                            'Circuit : ${_circuitName.isEmpty ? '#$_circuitId' : _circuitName}',
                          ),
                          trailing: SizedBox(
                            width: 120,
                            child: TextFormField(
                              controller: _mileageCtl,
                              enabled: false, // fixé
                              decoration: const InputDecoration(
                                labelText: 'Km',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Type d’échantillon
                      Padding(
                        padding: pad,
                        child: DropdownButtonFormField<String>(
                          value: _sampleType,
                          items: const [
                            DropdownMenuItem(value: 'BI', child: Text('BI')),
                            DropdownMenuItem(value: 'BS', child: Text('BS')),
                            DropdownMenuItem(value: 'CV', child: Text('CV')),
                            DropdownMenuItem(value: 'EID', child: Text('EID')),
                            DropdownMenuItem(
                              value: 'PrEP',
                              child: Text('PrEP'),
                            ),
                            DropdownMenuItem(
                              value: 'IVSA',
                              child: Text('IVSA'),
                            ),
                            DropdownMenuItem(value: 'TB', child: Text('TB')),
                            DropdownMenuItem(value: 'HPV', child: Text('HPV')),
                            DropdownMenuItem(
                              value: 'Autre',
                              child: Text('Autre'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Nature du bilan démandé',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => setState(() => _sampleType = v),
                          validator: (v) =>
                              v == null ? 'Sélectionnez un type' : null,
                        ),
                      ),

                      // Nature du prélèvement
                      Padding(
                        padding: pad,
                        child: DropdownButtonFormField<String>(
                          value: _sampleNature,
                          items: const [
                            DropdownMenuItem(value: 'DBS', child: Text('DBS')),
                            DropdownMenuItem(
                              value: 'SANG TOTAL',
                              child: Text('SANG TOTAL'),
                            ),
                            DropdownMenuItem(
                              value: 'PLASMA',
                              child: Text('PLASMA'),
                            ),
                            DropdownMenuItem(value: 'PSC', child: Text('PSC')),
                            DropdownMenuItem(
                              value: 'CRACHAT',
                              child: Text('CRACHAT'),
                            ),
                            DropdownMenuItem(value: 'LCR', child: Text('LCR')),
                            DropdownMenuItem(
                              value: 'SELLES',
                              child: Text('SELLES'),
                            ),
                            DropdownMenuItem(value: 'PV', child: Text('PV')),
                            DropdownMenuItem(
                              value: 'Autre',
                              child: Text('Autre'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Nature du prélèvement',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => setState(() => _sampleNature = v),
                          validator: (v) =>
                              v == null ? 'Sélectionnez la nature' : null,
                        ),
                      ),

                      // Identifiant patient
                      Padding(
                        padding: pad,
                        child: TextFormField(
                          controller: _patientCtl,
                          decoration: const InputDecoration(
                            labelText: 'Code patient',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Saisissez le code patient'
                              : null,
                        ),
                      ),

                      // Identifiant échantillon (optionnel)
                      Padding(
                        padding: pad,
                        child: TextFormField(
                          controller: _sampleIdCtl,
                          decoration: const InputDecoration(
                            labelText: 'Identifiant échantillon (si dispo)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                      // Date/heure de prélèvement
                      Padding(
                        padding: pad,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _collectionDateCtl,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Date de prélèvement',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                    onPressed: () =>
                                        _pickDate(_collectionDateCtl),
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Choisissez la date'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _collectionTimeCtl,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Heure de prélèvement',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.schedule_outlined),
                                    onPressed: () =>
                                        _pickTime(_collectionTimeCtl),
                                  ),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Choisissez l’heure'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Date/heure de collecte (pickup)
                      Padding(
                        padding: pad,
                        child: TextFormField(
                          controller: _pickupDateCtl,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Date/Heure de collecte',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_month_outlined),
                              onPressed: () async {
                                // Choix date/heure rapide
                                await _pickDate(_pickupDateCtl);
                                final date = _pickupDateCtl.text
                                    .split(' ')
                                    .first;
                                final timeCtl = TextEditingController(
                                  text: DateFormat(
                                    'HH:mm',
                                  ).format(DateTime.now()),
                                );
                                await _pickTime(timeCtl);
                                _pickupDateCtl.text = '$date ${timeCtl.text}';
                              },
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Choisissez la date/heure'
                              : null,
                        ),
                      ),

                      // Labo destination
                      Padding(
                        padding: pad,
                        child: DropdownButtonFormField<int>(
                          value: _labId,
                          items: _labItems(),
                          decoration: const InputDecoration(
                            labelText: 'Laboratoire de destination',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => setState(() => _labId = v),
                          validator: (v) =>
                              v == null ? 'Sélectionnez un laboratoire' : null,
                        ),
                      ),

                      // Garder site + kilométrage
                      Padding(
                        padding: pad,
                        child: CheckboxListTile(
                          value: _keepSiteAndMileage,
                          onChanged: (v) =>
                              setState(() => _keepSiteAndMileage = v ?? true),
                          title: const Text(
                            'Conserver site et kilométrage pour la prochaine saisie',
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Padding(
                        padding: pad,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _submit,
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check),
                            label: Text(
                              _saving ? 'Enregistrement...' : 'Valider',
                            ),
                          ),
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

extension _ListSafe<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? elementAtOrNull(int index) =>
      (index < 0 || index >= length) ? null : this[index];
}
