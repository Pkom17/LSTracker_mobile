import 'package:lstracker/data/stores/auth_store.dart';

/// Utilitaires d'authentification (rôle, etc.)
class AuthUtils {
  /// Récupère le rôle de l'utilisateur courant.
  /// Exemple de valeurs: 'ADMIN', 'CONVOYEUR', 'BIOLOGISTE'
  static Future<String?> getUserRole() async {
    final store = AuthStore();
    return await store.role;
  }

  static Future<int> getUserId() async {
    final store = AuthStore();
    return await store.userId ?? 0;
  }

  /// Vérifie rapidement un rôle
  static Future<bool> isAdmin() async =>
      (await getUserRole())?.toUpperCase() == 'ADMIN';

  static Future<bool> isConvoyeur() async =>
      (await getUserRole())?.toUpperCase() == 'CONVOYEUR';

  static Future<bool> isBiologiste() async =>
      (await getUserRole())?.toUpperCase() == 'BIOLOGISTE';
}
