import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app_config/app_config.dart';
import '../stores/auth_store.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;
  final AuthStore auth;

  TokenInterceptor(this.dio, this.auth);

  bool _refreshing = false;
  final List<_Pending> _queue = [];

  /// Dio “nu” pour le refresh (pas d’intercepteurs, pas de boucles)
  late final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBase,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Injecte le token pour chaque requête (si présent)
      final access = await auth.accessToken;
      if (access != null && access.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $access';
      } else {
        options.headers.remove('Authorization');
      }
    } catch (e) {
      // Si BAD_DECRYPT au moment de lire -> on laisse sans Authorization.
      debugPrint('onRequest token read error: $e');
      options.headers.remove('Authorization');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode ?? 0;
    final path = err.requestOptions.path;
    final isLogin = path.endsWith(AppConfig.loginPath);
    final isRefresh = path.endsWith(AppConfig.refreshPath);
    final isAuthCall = isLogin || isRefresh;

    // On ne tente pas de refresh si :
    // - pas 401
    // - c'est un call d'auth
    // - la requête a déjà été retentée (flag)
    final alreadyRetried = (err.requestOptions.extra['retried'] == true);

    if (status != 401 || isAuthCall || alreadyRetried) {
      return handler.next(err);
    }

    // Met la requête en file d’attente pendant qu’on refresh
    _queue.add(_Pending(err.requestOptions, handler));
    if (_refreshing) return; // d’autres 401 attendent

    _refreshing = true;
    try {
      // 🔒 Lecture refresh token depuis secure storage (protégée)
      String? rt;
      try {
        rt = await auth.refreshToken;
      } catch (e) {
        // BAD_DECRYPT probable → purge et échec global (redirection login côté UI)
        await _purgeOnCryptoError(e);
        _failQueue(err);
        return;
      }

      if (rt == null || rt.isEmpty) {
        _failQueue(err);
        return;
      }

      // ⚠️ Refresh via Dio dédié, sans Authorization
      final res = await _refreshDio.post(
        AppConfig.refreshPath,
        data: {'refresh_token': rt},
        options: Options(headers: {'Authorization': null}),
      );

      if (res.statusCode != 200 || res.data is! Map) {
        _failQueue(err);
        return;
      }

      final data = (res.data as Map);
      final newAccess = (data['access_token'] ?? '').toString();
      final newRefresh = (data['refresh_token'] ?? rt).toString();

      if (newAccess.isEmpty) {
        _failQueue(err);
        return;
      }

      // 📝 Écrit uniquement en secure storage via AuthStore
      try {
        // conserve role/userId actuels (si utilisés ailleurs)
        await auth.writeTokens(accessToken: newAccess, refreshToken: newRefresh);
      } catch (e) {
        await _purgeOnCryptoError(e);
        _failQueue(err);
        return;
      }

      // Met à jour l’en-tête par défaut du Dio principal
      dio.options.headers['Authorization'] = 'Bearer $newAccess';

      // ✅ Relance toutes les requêtes en attente
      _retryQueue();
    } catch (e) {
      _failQueue(err);
    } finally {
      _refreshing = false;
    }
  }

  void _retryQueue() {
    for (final p in _queue) {
      final ro = p.req;

      // Marque la requête comme déjà retentée pour éviter boucles infinies
      ro.extra['retried'] = true;

      // Injecte le nouvel access token sur la requête relancée
      final headers = Map<String, dynamic>.from(ro.headers);
      final authHeader = dio.options.headers['Authorization'];
      if (authHeader != null) {
        headers['Authorization'] = authHeader;
      } else {
        headers.remove('Authorization');
      }

      final opts = Options(
        method: ro.method,
        headers: headers,
        responseType: ro.responseType,
        contentType: ro.contentType,
        sendTimeout: ro.sendTimeout,
        receiveTimeout: ro.receiveTimeout,
        extra: ro.extra,
        followRedirects: ro.followRedirects,
        listFormat: ro.listFormat,
        validateStatus: ro.validateStatus,
      );

      dio
          .request<dynamic>(
            ro.path,
            data: ro.data,
            queryParameters: ro.queryParameters,
            options: opts,
            cancelToken: ro.cancelToken,
            onReceiveProgress: ro.onReceiveProgress,
            onSendProgress: ro.onSendProgress,
          )
          .then(p.h.resolve)
          .catchError((Object e) {
            // catchError donne un Object, mais reject attend un DioException.
            // Si l'erreur n'est pas un DioException (rare), on la wrappe.
            final dioErr = e is DioException
                ? e
                : DioException(requestOptions: ro, error: e);
            p.h.reject(dioErr);
          });
    }
    _queue.clear();
  }

  void _failQueue(DioException original) {
    for (final p in _queue) {
      p.h.next(original);
    }
    _queue.clear();
  }

  Future<void> _purgeOnCryptoError(Object e) async {
    final msg = e.toString().toLowerCase();
    final looksLikeBadDecrypt = msg.contains('bad_decrypt') ||
        msg.contains('badpaddingexception') ||
        msg.contains('cipher');
    if (looksLikeBadDecrypt) {
      try {
        await auth.purgeAll();
      } catch (_) {
        // Volontaire : si même la purge échoue, on n'a plus de recours
        // côté process (l'utilisateur devra réinstaller). Re-throw ne
        // ferait que masquer l'erreur de décryptage initiale.
      }
    }
  }
}

class _Pending {
  final RequestOptions req;
  final ErrorInterceptorHandler h;
  _Pending(this.req, this.h);
}