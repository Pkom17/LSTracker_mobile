import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lstracker/data/db/metadata_dao.dart';
import 'package:lstracker/data/db/sample_dao.dart';
import 'package:lstracker/data/services/auth_service.dart';
import 'package:lstracker/data/services/dio_client.dart';
import 'package:lstracker/data/services/sync_service.dart';
import 'package:lstracker/data/stores/auth_store.dart';

class AccountMenuButton extends StatefulWidget {
  const AccountMenuButton({super.key});

  @override
  State<AccountMenuButton> createState() => _AccountMenuButtonState();
}

class _AccountMenuButtonState extends State<AccountMenuButton> {
  bool _busy = false;

  /// Logout sécurisé :
  /// 1. Compte les modifications locales non synchronisées (dirty = 1).
  /// 2. Si dirty > 0 : propose 3 options (Synchroniser / Forcer / Annuler).
  /// 3. Délègue à AuthService.logout() qui purge tokens + BD locale.
  /// 4. Retour à l'écran de login.
  Future<void> _logout() async {
    final dirtyCount = await SampleDao().countDirty();

    bool? confirm;
    if (dirtyCount > 0) {
      confirm = await _confirmWithDirty(dirtyCount);
      if (confirm == null) return; // annulé
      if (confirm) {
        // L'utilisateur a choisi "Synchroniser d'abord"
        setState(() => _busy = true);
        final pushed = await _pushDirtyBeforeLogout();
        if (!mounted) return;
        setState(() => _busy = false);
        if (pushed == null) {
          // échec de sync : on demande à nouveau si on force ou pas
          final force = await _confirmForceAfterFailedSync();
          if (force != true) return;
        }
      }
    } else {
      // Pas de dirty : confirmation simple
      final ok = await _confirmSimple();
      if (ok != true) return;
    }

    setState(() => _busy = true);
    try {
      final authService = AuthService(
        DioClient.instance.dio,
        AuthStore(),
        MetadataDao(),
      );
      // purge tokens + BD locale (samples + metadata) + cache role/userId
      await authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de déconnexion: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirmSimple() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?\n\n'
          'Toutes les données locales seront supprimées de cet appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  /// Retourne true = "Synchroniser d'abord", false = "Forcer", null = "Annuler".
  Future<bool?> _confirmWithDirty(int count) {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Modifications non synchronisées'),
        content: Text(
          '$count modification(s) locale(s) ne sont pas encore envoyées au serveur.\n\n'
          'Si vous vous déconnectez maintenant, ces modifications seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Forcer (perte de données)'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Synchroniser d\'abord'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmForceAfterFailedSync() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Synchronisation échouée'),
        content: const Text(
          'Impossible d\'envoyer les modifications au serveur (hors-ligne ou erreur réseau).\n\n'
          'Voulez-vous forcer la déconnexion ? Les modifications locales seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade900,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Forcer la déconnexion'),
          ),
        ],
      ),
    );
  }

  /// Renvoie le nombre poussé en cas de succès, null en cas d'échec.
  Future<int?> _pushDirtyBeforeLogout() async {
    try {
      final sync = SyncService(dio: DioClient.instance.dio);
      return await sync.pushDirty();
    } catch (_) {
      return null;
    }
  }

  void _exitApp() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quitter l’application'),
        content: const Text('Voulez-vous fermer l’application ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
    if (ok == true) {
      SystemNavigator.pop(); // ferme l’app proprement
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Mon compte',
      enabled: !_busy,
      icon: _busy
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.account_circle_outlined),
      onSelected: (v) {
        if (v == 'logout') {
          _logout();
        } else if (v == 'exit') {
          _exitApp();
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Se déconnecter'),
          ),
        ),
        const PopupMenuItem(
          value: 'exit',
          child: ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Quitter l’application'),
          ),
        ),
      ],
    );
  }
}
