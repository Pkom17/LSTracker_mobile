import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lstracker/data/db/app_database.dart';
import 'package:lstracker/data/services/log_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStore {
  static const _secure = FlutterSecureStorage();
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kRole = 'role';
  static const _kUserId = 'user_id';
  static const _kSavedUsername = 'saved_username';

  Future<void> saveSession({
    required String accessToken,
    required String role,
    required int userId,
  }) async {
    await _secure.write(key: _kAccessToken, value: accessToken);
    await _secure.write(key: _kRole, value: role);
    await _secure.write(key: _kUserId, value: userId.toString());
  }

  Future<void> saveRefreshToken(String token) async {
    await _secure.write(key: _kRefreshToken, value: token);
  }

  Future<void> clearSession() async {
    await _secure.delete(key: _kAccessToken);
    await _secure.delete(key: _kRefreshToken);
    await _secure.delete(key: _kRole);
    await _secure.delete(key: _kUserId);
  }

  /// Nettoyage complet à appeler au logout pour empêcher la fuite de
  /// données entre utilisateurs (un autre user qui se connecte ne doit
  /// pas voir les samples / metadata de l'utilisateur précédent).
  ///
  /// Supprime :
  ///  - secure storage (tokens / role / userId)
  ///  - SharedPreferences sync.last_pull_at (force pull complet au prochain login)
  ///  - toutes les rows de la table sample (incluant les dirty=1 — donc à
  ///    n'appeler qu'après que l'utilisateur a poussé ses changements, ou
  ///    en cas de logout forcé après confirmation utilisateur)
  ///  - tables metadata (lab, circuit, site, rejection_type, circuit_site)
  Future<void> purgeLocalDataForLogout({bool keepUsername = true}) async {
    LogService.instance.info('Auth', 'logout: purge des données locales');
    await clearSession();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('sync.last_pull_at');
      if (!keepUsername) {
        await prefs.remove(_kSavedUsername);
      }
    } catch (e, st) {
      LogService.instance.warn('Auth', 'logout: purge prefs partielle',
          error: e, stackTrace: st);
    }
    try {
      final db = await AppDatabase.instance.database;
      // Ordre des deletes : tables dépendantes d'abord (FK virtuel)
      await db.delete('sample');
      await db.delete('circuit_site');
      await db.delete('site');
      await db.delete('lab');
      await db.delete('circuit');
      await db.delete('rejection_type');
      LogService.instance.info('Auth', 'logout: tables locales vidées');
    } catch (e, st) {
      LogService.instance.error('Auth', 'logout: purge BD a échoué',
          error: e, stackTrace: st);
    }
  }

  Future<String?> get accessToken async =>
      await _secure.read(key: _kAccessToken);
  Future<String?> get refreshToken async =>
      await _secure.read(key: _kRefreshToken);
  Future<String?> get role async => await _secure.read(key: _kRole);
  Future<int?> get userId async {
    final v = await _secure.read(key: _kUserId);
    return v == null ? null : int.tryParse(v);
  }

  Future<void> rememberUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSavedUsername, username);
  }

  Future<String?> get savedUsername async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSavedUsername);
  }

  Future<void> setAccessToken(String token) async {
    await _secure.write(key: _kAccessToken, value: token);
  }

  Future<void> writeTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _secure.write(key: _kAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _secure.write(key: _kRefreshToken, value: refreshToken);
    }
  }

  /// Purge totale si décryptage impossible (clé perdue)
  Future<void> purgeAll() async {
    await const FlutterSecureStorage().deleteAll();
  }
}
