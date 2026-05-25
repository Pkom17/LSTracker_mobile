import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:lstracker/data/services/log_service.dart';

/// Service global exposant l'état réseau au reste de l'app.
///
/// Concrètement, on transforme le stream de [connectivity_plus] en un
/// [ValueListenable<bool>] (`isOnline`) que n'importe quel widget peut
/// observer avec un `ValueListenableBuilder`. Le widget [OfflineBanner]
/// l'utilise pour afficher une bannière persistante quand l'appareil
/// n'a aucune connectivité.
///
/// NB : "online" signifie ici "au moins une interface réseau active"
/// (wifi / mobile / ethernet). Il ne garantit pas que le serveur API
/// est joignable — la vraie source de vérité d'erreur reste le log
/// SyncService.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  static const _tag = 'Connectivity';

  final ValueNotifier<bool> _isOnline = ValueNotifier<bool>(true);
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _started = false;

  /// État actuel du réseau, écoutable depuis l'UI.
  ValueListenable<bool> get isOnline => _isOnline;

  /// Démarre l'observation. Idempotent.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      final initial = await Connectivity().checkConnectivity();
      _update(initial, reason: 'initial');
    } catch (e) {
      LogService.instance.warn(_tag, 'checkConnectivity initial a échoué: $e');
    }

    _sub = Connectivity().onConnectivityChanged.listen(
      (results) => _update(results, reason: 'change'),
      onError: (e) =>
          LogService.instance.warn(_tag, 'onConnectivityChanged error: $e'),
    );
  }

  /// Arrête l'observation (à appeler au logout).
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _started = false;
  }

  void _update(List<ConnectivityResult> results, {required String reason}) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (_isOnline.value == online) return;
    _isOnline.value = online;
    LogService.instance.info(
      _tag,
      online ? 'en ligne ($reason)' : 'hors ligne ($reason)',
    );
  }
}
