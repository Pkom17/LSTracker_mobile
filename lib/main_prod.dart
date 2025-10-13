import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lstracker/app_config/app_config.dart';
import 'package:lstracker/data/services/auto_sync_manager.dart';
import 'package:lstracker/data/services/dio_client.dart';
import 'package:lstracker/features/dashboard/dashboard_screen.dart';
import 'package:lstracker/features/results_deposit/results_collected_list_screen.dart';
import 'package:lstracker/features/results_deposit/results_collected_sites_screen.dart';
import 'package:lstracker/features/results_deposit/results_deposit_form_screen.dart';
import 'package:lstracker/features/results_ready/results_ready_labs_screen.dart';
import 'package:lstracker/features/results_ready/results_ready_list_screen.dart';
import 'package:lstracker/features/results_ready/results_ready_types_screen.dart';
import 'package:lstracker/features/samples/collect_context_screen.dart';
import 'package:lstracker/features/samples/collect_sample_screen.dart';
import 'package:lstracker/features/samples/sample_accept_screen.dart';
import 'package:lstracker/features/samples/sample_analysis_fail_screen.dart';
import 'package:lstracker/features/samples/sample_deposit_edit_screen.dart';
import 'package:lstracker/features/samples/sample_deposit_screen.dart';
import 'package:lstracker/features/samples/sample_detail_screen.dart';
import 'package:lstracker/features/samples/sample_edit_screen.dart';
import 'package:lstracker/features/samples/sample_list_screen.dart';
import 'package:lstracker/features/samples/sample_reject_screen.dart';
import 'package:lstracker/features/samples/sample_result_collect_screen.dart';
import 'package:lstracker/features/samples/sample_result_ready_screen.dart';
import 'package:lstracker/features/samples/sample_types_screen.dart';
import 'package:lstracker/features/sync/sync_screen.dart';

import 'data/db/app_database.dart';
import 'data/db/metadata_dao.dart';
import 'data/services/auth_service.dart';
import 'data/stores/auth_store.dart';
import 'features/login/login_screen.dart';

Future<({bool isLoggedIn, String? role})> bootstrap(AuthStore authStore) async {
  try {
    await DioClient.instance.initWithAuth(authStore);

    final token =
        await authStore.accessToken; // peut throw si keystore mismatch
    final role = await authStore.role;

    return (isLoggedIn: (token?.isNotEmpty ?? false), role: role);
  } catch (e, st) {
    final msg = e.toString().toLowerCase();
    final looksLikeBadDecrypt =
        msg.contains('bad_decrypt') ||
        msg.contains('badpaddingexception') ||
        msg.contains('cipher');

    if (looksLikeBadDecrypt) {
      try {
        const storage = FlutterSecureStorage();
        await storage.deleteAll();
      } catch (_) {}
      return (isLoggedIn: false, role: null);
    }

    debugPrint('bootstrap error: $e\n$st');
    return (isLoggedIn: false, role: null);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught (root) error: $error');
    return true; // évite le kill en release
  };

  await AppDatabase.instance.database;
  await ensureMetadataSchema();

  // Basculer l’API sur l’environnement PROD
  AppConfig.overrideBase('https://lstracker.org');

  final authStore = AuthStore();
  final boot = await bootstrap(authStore);

  runApp(
    MyApp(
      authService: AuthService(
        DioClient.instance.dio,
        authStore,
        MetadataDao(),
      ),
      userRole: boot.role,
      isLoggedIn: boot.isLoggedIn,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final String? userRole;
  final bool isLoggedIn;
  const MyApp({
    super.key,
    required this.authService,
    required this.isLoggedIn,
    this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      // Démarre (idempotent)
      AutoSyncManager.instance.start();
    }
    return MaterialApp(
      title: 'Lab Sample Tracker',
      theme:
          ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 35, 2, 146),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ).copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 4.0,
            ),
          ),
      home: isLoggedIn
          ? DashboardScreen(userRole: userRole!)
          : LoginScreen(authService: authService),
      routes: {
        '/login': (context) => LoginScreen(authService: authService),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          String? role;
          if (args is Map) {
            role = args['role'] as String?;
          } else {
            role = userRole;
          }
          if (role != null) {
            return DashboardScreen(userRole: role);
          }
          return LoginScreen(authService: authService);
        },
        '/sync': (ctx) => const SyncScreen(),
        CollectSampleScreen.route: (_) => CollectSampleScreen(),
        CollectContextScreen.route: (_) => const CollectContextScreen(),
        SampleTypesScreen.route: (_) => const SampleTypesScreen(),
        SampleListScreen.route: (_) => const SampleListScreen(),
        SampleEditScreen.route: (_) => const SampleEditScreen(),
        SampleDetailScreen.route: (_) => const SampleDetailScreen(),
        SampleDepositScreen.route: (_) => const SampleDepositScreen(),
        SampleDepositEditScreen.route: (_) => const SampleDepositEditScreen(),
        SampleAcceptScreen.route: (_) => const SampleAcceptScreen(),
        SampleRejectScreen.route: (_) => const SampleRejectScreen(),
        SampleResultCollectScreen.route: (_) =>
            const SampleResultCollectScreen(),
        ResultsReadyLabsScreen.route: (_) => const ResultsReadyLabsScreen(),
        ResultsReadyTypesScreen.route: (_) => const ResultsReadyTypesScreen(),
        ResultsReadyListScreen.route: (_) => const ResultsReadyListScreen(),
        ResultsCollectedSitesScreen.route: (_) =>
            const ResultsCollectedSitesScreen(),
        ResultsCollectedListScreen.route: (_) =>
            const ResultsCollectedListScreen(),
        ResultsDepositFormScreen.route: (_) => const ResultsDepositFormScreen(),
        SampleResultReadyScreen.route: (_) => const SampleResultReadyScreen(),
        SampleAnalysisFailScreen.route: (_) => const SampleAnalysisFailScreen(),
      },
    );
  }
}
