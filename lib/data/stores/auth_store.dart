import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
