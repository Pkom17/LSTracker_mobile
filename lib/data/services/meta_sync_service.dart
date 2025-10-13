import 'package:dio/dio.dart';

import '../../app_config/app_config.dart';
import '../db/metadata_dao.dart';
import '../stores/auth_store.dart';

/// Service simple pour rafraîchir les métadonnées depuis le backend
class MetaSyncService {
  static Future<void> refreshAll() async {
    final auth = AuthStore();
    final token = await auth.accessToken;

    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBase,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
      ),
    );

    final res = await dio.get(AppConfig.metaFullPath);
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Réponse inattendue du serveur: ${data.toString()}');
    }

    final dao = MetadataDao();
    await dao.replaceAllFromServerPayload(data);
  }
}
