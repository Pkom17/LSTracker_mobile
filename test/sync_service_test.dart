import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lstracker/data/db/sample_dao.dart';
import 'package:lstracker/data/models/sample.dart';
import 'package:lstracker/data/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/test_db.dart';

/// Adapter Dio synthétique : un closure répond à chaque requête en
/// fonction du chemin / méthode. Permet de simuler push OK/KO et pull
/// avec n'importe quel payload, sans toucher au réseau.
class _FakeDioAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (responder == null) {
      throw StateError('No responder configured for ${options.path}');
    }
    return responder!(options);
  }

  @override
  void close({bool force = false}) {}
}

/// Construit une `ResponseBody` JSON à partir d'un Map.
ResponseBody _jsonResponse(Map<String, dynamic> body, {int status = 200}) {
  final bytes = Uint8List.fromList(utf8.encode(jsonEncode(body)));
  return ResponseBody.fromBytes(
    bytes,
    status,
    headers: {
      'content-type': ['application/json; charset=utf-8'],
    },
  );
}

void main() {
  group('SyncService.run() — orchestration push → pull', () {
    late SampleDao dao;
    late SyncService sync;
    late Dio dio;
    late _FakeDioAdapter adapter;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await setUpTestDb();
      dao = SampleDao();

      dio = Dio();
      adapter = _FakeDioAdapter();
      dio.httpClientAdapter = adapter;

      sync = SyncService(dio: dio, sampleDao: dao);
    });

    tearDown(() async {
      await tearDownTestDb();
    });

    test('push OK + pull OK → pushOk=true, pullOk=true, pas de conflits',
        () async {
      // Un dirty en attente
      await dao.insertSample(Sample(
        uuid: 'uuid-push-1',
        sampleType: 'CV',
        sampleStatus: SampleStatus.onTransit,
        createdAt: '2026-05-21',
        lastupdatedAt: '2026-05-21',
        dirty: 1,
      ));

      adapter.responder = (req) {
        if (req.path.contains('push')) {
          return _jsonResponse({
            'mapped': [
              {'uuid': 'uuid-push-1', 'external_id': 'ext-1'},
            ],
          });
        }
        if (req.path.contains('pull')) {
          return _jsonResponse({'samples': []});
        }
        return _jsonResponse({}, status: 404);
      };

      final result = await sync.run();
      expect(result.pushOk, isTrue);
      expect(result.pullOk, isTrue);
      expect(result.pushed, 1);
      expect(result.pulled, 0);
      expect(result.conflicts, 0);
      expect(result.hasError, isFalse);
    });

    test('pull ABORTED si push échoue (ordre push → pull strict)', () async {
      await dao.insertSample(Sample(
        uuid: 'uuid-fail-1',
        sampleType: 'CV',
        sampleStatus: SampleStatus.onTransit,
        createdAt: '2026-05-21',
        lastupdatedAt: '2026-05-21',
        dirty: 1,
      ));

      var pullCalled = false;
      adapter.responder = (req) {
        if (req.path.contains('push')) {
          return _jsonResponse({'error': 'boom'}, status: 500);
        }
        if (req.path.contains('pull')) {
          pullCalled = true;
          return _jsonResponse({'samples': []});
        }
        return _jsonResponse({}, status: 404);
      };

      final result = await sync.run();
      expect(result.pushOk, isFalse,
          reason: 'push 500 → pushOk doit être false');
      expect(result.pullOk, isFalse,
          reason: 'pull aborté → pullOk false aussi');
      expect(pullCalled, isFalse,
          reason: 'le pull NE DOIT PAS être appelé après un push KO');
      expect(result.hasError, isTrue);
    });

    test('pull récupère et applique des samples du serveur', () async {
      adapter.responder = (req) {
        if (req.path.contains('pull')) {
          return _jsonResponse({
            'samples': [
              {
                'external_id': 'ext-pull-1',
                'uuid': 'uuid-pull-1',
                'sample_type': 'CV',
                'sample_status': SampleStatus.receivedAtDistrictLab,
                'version': 1,
              }
            ],
          });
        }
        return _jsonResponse({}, status: 404);
      };

      final result = await sync.run();
      expect(result.pushed, 0, reason: 'rien à push, pas de dirty');
      expect(result.pulled, 1);
      expect(result.pullOk, isTrue);

      final s = await dao.findByUuid('uuid-pull-1');
      expect(s, isNotNull);
      expect(s!.externalId, 'ext-pull-1');
    });

    test('conflits remontés dans le SyncResult', () async {
      // Row local dirty
      await dao.insertSample(Sample(
        uuid: 'uuid-conf-1',
        sampleIdentifier: 'LOCAL',
        sampleType: 'CV',
        sampleStatus: SampleStatus.onTransit,
        createdAt: '2026-05-21',
        lastupdatedAt: '2026-05-21',
        dirty: 1,
      ));

      adapter.responder = (req) {
        if (req.path.contains('push')) {
          // Push : le serveur n'acquitte pas (mapped vide). Le row reste
          // dirty mais ne déclenche pas d'erreur (HTTP 200 / pas de
          // DioException). Le pull pourra continuer.
          return _jsonResponse({'mapped': []});
        }
        if (req.path.contains('pull')) {
          // Le serveur renvoie SA version concurrente du même uuid.
          return _jsonResponse({
            'samples': [
              {
                'external_id': 'ext-conf-1',
                'uuid': 'uuid-conf-1',
                'sample_identifier': 'SERVER',
                'sample_type': 'CV',
                'sample_status': SampleStatus.acceptedAtDistrictLab,
                'version': 9,
              }
            ],
          });
        }
        return _jsonResponse({}, status: 404);
      };

      final result = await sync.run();
      expect(result.conflicts, 1,
          reason: 'le pull a détecté un conflit sur le row dirty');
      expect(result.pullOk, isTrue);

      // Le local n'a pas été écrasé : la sample_identifier "LOCAL"
      // doit rester en place (cf. dirty-protection dans upsertFromServer).
      final s = await dao.findByUuid('uuid-conf-1');
      expect(s!.sampleIdentifier, 'LOCAL');
    });
  });
}
