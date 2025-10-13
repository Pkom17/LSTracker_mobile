// lib/services/sync_service.dart
import 'package:dio/dio.dart';
import 'package:lstracker/app_config/app_config.dart';
import 'package:lstracker/data/db/sample_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dio_client.dart';

class SyncResult {
  final int pushed;
  final int pulled;
  final DateTime endedAt;
  final List<String> messages;

  SyncResult({
    required this.pushed,
    required this.pulled,
    required this.endedAt,
    required this.messages,
  });
}

class SyncService {
  SyncService({Dio? dio, SampleDao? sampleDao})
    : _dio = dio ?? DioClient.instance.dio,
      dao = sampleDao ?? SampleDao();

  final Dio _dio;
  final SampleDao dao;

  static const _kLastPullKey = 'sync.last_pull_at'; // ISO-8601

  Future<DateTime?> getLastPull() async {
    final sp = await SharedPreferences.getInstance();
    final v = sp.getString(_kLastPullKey);
    if (v == null || v.isEmpty) return null;
    return DateTime.tryParse(v);
  }

  Future<void> _setLastPull(DateTime t) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kLastPullKey, t.toIso8601String());
  }

  Future<int> pushDirty() async {
    final dirty = await dao.listDirty();
    if (dirty.isEmpty) return 0;

    final payload = {'samples': dirty.map((s) => s.toServerMap()).toList()};

    try {
      final res = await _dio.post(
        AppConfig.samplesPushPath,
        data: payload,
        options: Options(contentType: 'application/json'),
      );

      final data = (res.data is Map) ? res.data as Map : {};
      final List mapped = (data['mapped'] as List?) ?? const [];

      final Map<String, String> uuidToExternalId = {};
      for (final m in mapped) {
        final mm = m as Map;
        final uuid = (mm['uuid'] ?? '').toString();
        final ext = (mm['external_id'] ?? '').toString();
        if (uuid.isNotEmpty && ext.isNotEmpty) {
          uuidToExternalId[uuid] = ext;
        }
      }

      await dao.markPushed(uuidToExternalId);
      return dirty.length;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final body = e.response?.data;
      throw 'pushDirty: HTTP $code — ${body ?? e.message}';
    }
  }

  Future<int> pull({DateTime? since}) async {
    final last = since ?? await getLastPull();

    try {
      final res = await _dio.get(
        AppConfig.samplesPullPath,
        queryParameters: last != null
            ? {'since': last.toUtc().toIso8601String()}
            : null,
      );

      final data = (res.data is Map) ? res.data as Map : {};
      final List remote = (data['samples'] as List?) ?? const [];

      for (final item in remote) {
        await dao.upsertFromServer(Map<String, dynamic>.from(item as Map));
      }

      await _setLastPull(DateTime.now().toUtc());
      return remote.length;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final body = e.response?.data;
      throw 'pull: HTTP $code — ${body ?? e.message}';
    }
  }

  Future<SyncResult> run() async {
    final messages = <String>[];
    int pushed = 0;
    int pulled = 0;

    try {
      pushed = await pushDirty();
      messages.add('PUSH: $pushed élément(s) envoyé(s).');
    } catch (e) {
      messages.add('PUSH: erreur — $e');
    }

    try {
      pulled = await pull();
      messages.add('PULL: $pulled élément(s) reçu(s).');
    } catch (e) {
      messages.add('PULL: erreur — $e');
    }

    return SyncResult(
      pushed: pushed,
      pulled: pulled,
      endedAt: DateTime.now(),
      messages: messages,
    );
  }
}
