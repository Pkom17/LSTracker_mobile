import 'package:dio/dio.dart';
import 'package:lstracker/data/services/dio_client.dart';

import '../../../app_config/app_config.dart';
import '../db/app_database.dart';
import '../db/metadata_dao.dart';
import '../stores/auth_store.dart';

class AuthService {
  final Dio _dio;
  final AuthStore _authStore;
  final MetadataDao _metadataDao;

  AuthService(this._dio, this._authStore, this._metadataDao) {
    _dio.options.baseUrl = AppConfig.apiBase;
    _dio.options.connectTimeout = const Duration(seconds: 20);
    _dio.options.receiveTimeout = const Duration(seconds: 20);
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    bool rememberUsername = true,
  }) async {
    final res = await _dio.post(
      AppConfig.loginPath,
      data: {'username': username, 'password': password},
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception("Réponse inattendue du serveur: ${data.toString()}");
    }

    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final role = (data['role'] as String).toUpperCase();
    final userId = (data['user_id'] as int?) ?? 0;

    await _authStore.saveSession(
      accessToken: accessToken,
      role: role,
      userId: userId,
    );
    await _authStore.saveRefreshToken(refreshToken);
    if (rememberUsername) {
      await _authStore.rememberUsername(username);
    }

    await DioClient.instance.initWithAuth(_authStore);

    _dio.options.headers['Authorization'] = 'Bearer $accessToken';

    await ensureMetadataSchema();
    final metaRes = await _dio.get(AppConfig.metaFullPath);
    await _metadataDao.replaceAllFromServerPayload(
      metaRes.data as Map<String, dynamic>,
    );

    return {'role': role, 'userId': userId};
  }

  Future<void> logout() async {
    try {
      final rt = await _authStore.refreshToken;
      if (rt != null) {
        await _dio.post(
          AppConfig.refreshPath.replaceAll('/refresh', '/logout'),
          data: {'refresh_token': rt},
        );
      }
    } catch (_) {
    } finally {
      await _authStore.clearSession();
      _dio.options.headers.remove('Authorization');
    }
  }
}
