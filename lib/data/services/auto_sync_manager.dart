import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:lstracker/data/services/dio_client.dart';
import 'package:lstracker/data/services/sync_service.dart';

/// Gère le push/pull automatique tant que l’app est ouverte.
/// - intervalle périodique
/// - déclenchement sur reprise d’app
/// - déclenchement à la reconnexion réseau
class AutoSyncManager with WidgetsBindingObserver {
  AutoSyncManager._();
  static final AutoSyncManager instance = AutoSyncManager._();

  final _sync = SyncService(dio: DioClient.instance.dio);
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _running = false;
  DateTime? _lastRun;

  /// Démarre le mécanisme auto-sync.
  /// [interval] : période entre deux sync (par défaut 15 minutes).
  void start({Duration interval = const Duration(minutes: 15)}) {
    // Évite les doubles démarrages
    if (_timer != null || _connSub != null) return;

    // Observe cycle de vie
    WidgetsBinding.instance.addObserver(this);

    // Périodique
    _timer = Timer.periodic(interval, (_) => _runIfNeeded(reason: 'timer'));

    // Réseau
    _connSub = Connectivity().onConnectivityChanged.listen((results) {
      // results est une List<ConnectivityResult>
      final hasNetwork = results.any((r) => r != ConnectivityResult.none);
      if (hasNetwork) {
        _runIfNeeded(reason: 'network');
      }
    });

    // Premier run léger (avec petit délai pour laisser l’UI se poser)
    Future.delayed(
      const Duration(seconds: 5),
      () => _runIfNeeded(reason: 'initial'),
    );
  }

  /// Arrête le mécanisme auto-sync (à appeler au logout).
  void stop() {
    _timer?.cancel();
    _timer = null;
    _connSub?.cancel();
    _connSub = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Appelé quand l’app revient au premier plan.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runIfNeeded(reason: 'resume');
    }
  }

  /// Déclenche un push+pull si pas déjà en cours, avec une
  /// petite logique d’espacement (throttle) de 60s.
  Future<void> _runIfNeeded({required String reason}) async {
    if (_running) return;
    if (_lastRun != null &&
        DateTime.now().difference(_lastRun!) < const Duration(seconds: 60)) {
      return;
    }
    _running = true;
    try {
      await _sync.run();
      _lastRun = DateTime.now();
      // Tu peux brancher ici un petit bus d’événements/Logs si besoin
      // ex: debugPrint('[AutoSync] completed ($reason)');
    } catch (_) {
      // silencieux pour ne pas gêner l’UI
    } finally {
      _running = false;
    }
  }

  /// À appeler juste après une nouvelle soumission locale (collecte, dépôt, etc.).
  void pushNow() {
    // On ne fait qu’un PUSH ici pour être rapide,
    // le PULL viendra via le périodique / reprise / reconnexion.
    unawaited(_safePush());
  }

  Future<void> _safePush() async {
    if (_running) return;
    _running = true;
    try {
      await _sync.pushDirty();
      _lastRun = DateTime.now();
    } catch (_) {
      // silencieux
    } finally {
      _running = false;
    }
  }
}
