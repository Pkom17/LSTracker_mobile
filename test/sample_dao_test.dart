import 'package:flutter_test/flutter_test.dart';
import 'package:lstracker/data/db/app_database.dart';
import 'package:lstracker/data/db/sample_dao.dart';
import 'package:lstracker/data/models/sample.dart';

import 'helpers/test_db.dart';

/// Lit `has_conflict` brut depuis SQLite (pas exposé par le modèle Sample).
Future<int> _hasConflict(String uuid) async {
  final db = await AppDatabase.instance.database;
  final rows = await db.query('sample',
      columns: ['has_conflict'],
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1);
  if (rows.isEmpty) return -1;
  return (rows.first['has_conflict'] as int?) ?? 0;
}

/// Construit un échantillon "local" minimum pour les tests.
Sample _mkLocal({
  required String uuid,
  String? sampleIdentifier,
  String? patientIdentifier,
  String? sampleStatus,
  int dirty = 1,
}) {
  return Sample(
    externalId: null,
    uuid: uuid,
    sampleIdentifier: sampleIdentifier ?? 'LOC-$uuid',
    patientIdentifier: patientIdentifier ?? 'PAT-$uuid',
    sampleType: 'CV',
    sampleNature: 'PLASMA',
    sampleStatus: sampleStatus ?? SampleStatus.onTransit,
    collectionDate: '2026-05-21T10:00',
    pickupDate: '2026-05-21 10:30',
    createdAt: '2026-05-21 10:00',
    lastupdatedAt: '2026-05-21 10:00',
    dirty: dirty,
  );
}

/// Payload "serveur" pour upsertFromServer.
Map<String, dynamic> _serverPayload({
  required String externalId,
  required String uuid,
  String? sampleIdentifier,
  String? sampleStatus,
  int version = 1,
}) =>
    {
      'external_id': externalId,
      'uuid': uuid,
      'sample_identifier': sampleIdentifier ?? 'SRV-$externalId',
      'patient_identifier': 'PAT-SRV-$externalId',
      'sample_type': 'CV',
      'sample_nature': 'PLASMA',
      'sample_status': sampleStatus ?? SampleStatus.receivedAtDistrictLab,
      'collection_date': '2026-05-21T08:00',
      'version': version,
    };

void main() {
  group('SampleDao — upsertFromServer dirty protection', () {
    late SampleDao dao;

    setUp(() async {
      await setUpTestDb();
      dao = SampleDao();
    });

    tearDown(() async {
      await tearDownTestDb();
    });

    test('insère un row neuf quand rien n\'existe en local', () async {
      final accepted = await dao.upsertFromServer(
        _serverPayload(externalId: 'ext-1', uuid: 'uuid-1'),
      );

      expect(accepted, isTrue,
          reason: 'le serveur a été accepté car aucun conflit local');
      final s = await dao.findByUuid('uuid-1');
      expect(s, isNotNull);
      expect(s!.externalId, 'ext-1');
      expect(s.dirty, 0);
      expect(await _hasConflict('uuid-1'), 0);
      expect(s.sampleStatus, SampleStatus.receivedAtDistrictLab);
    });

    test('écrase un row local clean (dirty=0)', () async {
      // Pré-insert : row local non modifié (simulant un pull antérieur).
      await dao.insertSample(_mkLocal(uuid: 'uuid-2', dirty: 0));
      // Lien external_id ajouté manuellement comme l'aurait fait un push précédent.
      // On simule via un nouveau upsertFromServer avec ext+v1.
      await dao.upsertFromServer(
        _serverPayload(externalId: 'ext-2', uuid: 'uuid-2'),
      );

      // 2nd push serveur : nouvelle version, statut changé.
      final accepted = await dao.upsertFromServer(
        _serverPayload(
          externalId: 'ext-2',
          uuid: 'uuid-2',
          sampleStatus: SampleStatus.acceptedAtDistrictLab,
          version: 2,
        ),
      );

      expect(accepted, isTrue);
      final s = await dao.findByUuid('uuid-2');
      expect(s!.sampleStatus, SampleStatus.acceptedAtDistrictLab,
          reason: 'le row clean accepte la mise à jour serveur');
      expect(await _hasConflict('uuid-2'), 0);
    });

    test(
        '⚠️ DIRTY PROTECTION : ne touche PAS aux champs métier d\'un row dirty=1, marque has_conflict=1',
        () async {
      // 1) L'utilisateur a saisi une collecte localement (dirty=1, pas
      //    encore push)
      await dao.insertSample(_mkLocal(
        uuid: 'uuid-3',
        sampleIdentifier: 'LOCAL-EDIT',
        sampleStatus: SampleStatus.onTransit,
        dirty: 1,
      ));

      // 2) Pendant ce temps, le serveur a une version concurrente (peut
      //    arriver si un autre user édite via web, ou si le pull arrive
      //    avant le push)
      final accepted = await dao.upsertFromServer(_serverPayload(
        externalId: 'ext-3',
        uuid: 'uuid-3',
        sampleIdentifier: 'SERVER-VERSION',
        sampleStatus: SampleStatus.acceptedAtDistrictLab,
        version: 5,
      ));

      // 3) Vérifie le comportement attendu :
      //    - returns false (serveur non appliqué)
      //    - la version locale est INTACTE
      //    - has_conflict = 1 → l'UI conflict resolution prendra la main
      //    - external_id + server_version mis à jour (pour le retry plus tard)
      expect(accepted, isFalse,
          reason: 'le serveur a été rejeté car local dirty=1');

      final s = await dao.findByUuid('uuid-3');
      expect(s, isNotNull);
      expect(s!.sampleIdentifier, 'LOCAL-EDIT',
          reason: 'les champs métier locaux NE doivent PAS être écrasés');
      expect(s.sampleStatus, SampleStatus.onTransit,
          reason: 'le statut local reste inchangé');
      expect(s.dirty, 1, reason: 'reste dirty pour push ultérieur');
      expect(await _hasConflict('uuid-3'), 1,
          reason: 'flag remonté à l\'UI pour résolution manuelle');
      expect(s.externalId, 'ext-3',
          reason: 'external_id lié pour retry');
    });

    test('listConflicts renvoie uniquement les rows has_conflict=1', () async {
      // Row 1 : conflit
      await dao.insertSample(_mkLocal(uuid: 'uuid-a', dirty: 1));
      await dao.upsertFromServer(_serverPayload(
        externalId: 'ext-a',
        uuid: 'uuid-a',
      ));

      // Row 2 : clean (sera écrasé proprement)
      await dao.insertSample(_mkLocal(uuid: 'uuid-b', dirty: 0));
      await dao.upsertFromServer(_serverPayload(
        externalId: 'ext-b',
        uuid: 'uuid-b',
      ));

      // Row 3 : dirty seul (pas encore push, pas de conflit)
      await dao.insertSample(_mkLocal(uuid: 'uuid-c', dirty: 1));

      final conflicts = await dao.listConflicts();
      final dirty = await dao.countDirty();
      final cnt = await dao.countConflicts();

      expect(conflicts.length, 1);
      expect(conflicts.first.uuid, 'uuid-a');
      expect(cnt, 1);
      expect(dirty, 2,
          reason: 'uuid-a (toujours dirty malgré conflit) + uuid-c');
    });

    test('resolveConflictKeepLocal lève has_conflict, garde dirty=1',
        () async {
      await dao.insertSample(_mkLocal(uuid: 'uuid-k', dirty: 1));
      await dao.upsertFromServer(_serverPayload(
        externalId: 'ext-k',
        uuid: 'uuid-k',
      ));
      expect(await _hasConflict('uuid-k'), 1);

      await dao.resolveConflictKeepLocal('uuid-k');
      final s = await dao.findByUuid('uuid-k');
      expect(await _hasConflict('uuid-k'), 0,
          reason: 'le conflit a été clos côté local');
      expect(s!.dirty, 1,
          reason: 'reste dirty → sera re-push et écrasera le serveur');
    });

    test('resolveConflictDiscardLocal supprime le row local en conflit',
        () async {
      await dao.insertSample(_mkLocal(uuid: 'uuid-d', dirty: 1));
      await dao.upsertFromServer(_serverPayload(
        externalId: 'ext-d',
        uuid: 'uuid-d',
      ));

      await dao.resolveConflictDiscardLocal('uuid-d');

      final s = await dao.findByUuid('uuid-d');
      expect(s, isNull,
          reason: 'le row est supprimé : le prochain pull le re-téléchargera "propre"');
    });

    test(
        'resolveConflictDiscardLocal ne supprime PAS un row sans conflit (whereArgs strict)',
        () async {
      await dao.insertSample(_mkLocal(uuid: 'uuid-safe', dirty: 1));
      // Pas de conflit créé

      await dao.resolveConflictDiscardLocal('uuid-safe');

      final s = await dao.findByUuid('uuid-safe');
      expect(s, isNotNull,
          reason: 'sans has_conflict=1, on ne supprime pas');
    });
  });
}
