import 'package:dio/dio.dart';
import 'package:lstracker/data/services/auto_sync_manager.dart';
import 'package:lstracker/data/services/dio_client.dart';
import 'package:lstracker/data/services/log_service.dart';
import 'package:lstracker/features/dashboard/_dashboard_sections.dart'
    show DashboardInfoNote;
import 'package:lstracker/utils/auth_utils.dart';

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

    // Si le nouvel utilisateur est DIFFÉRENT du dernier connecté, on purge la
    // BD locale pour éviter que le compte B voie les samples du compte A.
    // Si c'est le même utilisateur (re-login après expiration de session),
    // on conserve la BD locale et les samples dirty éventuels.
    final previousUserId = await _authStore.userId;
    if (previousUserId != null && previousUserId != userId) {
      LogService.instance.info(
        'Auth',
        'login: changement d\'utilisateur ($previousUserId → $userId), purge de la BD locale',
      );
      await _authStore.purgeLocalDataForLogout(keepUsername: true);
      // Réaffiche le bandeau d'aide des dashboards pour le nouvel utilisateur.
      DashboardInfoNote.resetForNewSession();
    }

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

  /// Termine la session utilisateur :
  ///  - arrête l'auto-sync (timer + listener réseau)
  ///  - notifie le serveur (révocation du refresh token)
  ///  - purge toutes les données locales (tokens + BD locale)
  ///  - retire le header Authorization du Dio singleton
  ///
  /// `purgeLocalData`: si false, on garde la BD locale (utile pour les
  /// scénarios de re-login imminent du même utilisateur). Par défaut true
  /// pour éviter la fuite inter-comptes.
  Future<void> logout({bool purgeLocalData = true}) async {
    LogService.instance.info('Auth', 'logout déclenché (purge=$purgeLocalData)');
    AutoSyncManager.instance.stop();
    try {
      final rt = await _authStore.refreshToken;
      if (rt != null) {
        await _dio.post(
          AppConfig.refreshPath.replaceAll('/refresh', '/logout'),
          data: {'refresh_token': rt},
        );
      }
    } catch (e) {
      // Pas grave si le serveur ne répond pas : on poursuit le logout local.
      LogService.instance.warn('Auth', 'logout: serveur injoignable, on continue', error: e);
    } finally {
      _dio.options.headers.remove('Authorization');
      if (purgeLocalData) {
        await _authStore.purgeLocalDataForLogout();
      } else {
        await _authStore.clearSession();
      }
      // Vide le cache rôle/userId pour que la prochaine session ne
      // réutilise pas les valeurs du compte précédent.
      AuthUtils.clearCache();
      // Réaffiche le bandeau d'aide des dashboards à la prochaine session.
      DashboardInfoNote.resetForNewSession();
    }
  }
}
