import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lstracker/data/services/auto_sync_manager.dart';
import 'package:lstracker/data/services/dio_client.dart';
import 'package:lstracker/data/stores/auth_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountMenuButton extends StatefulWidget {
  const AccountMenuButton({super.key});

  @override
  State<AccountMenuButton> createState() => _AccountMenuButtonState();
}

class _AccountMenuButtonState extends State<AccountMenuButton> {
  bool _busy = false;

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => {
              AuthStore().clearSession(),
              AutoSyncManager.instance.stop(),
              Navigator.pop(context, true),
            },
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      // Nettoie les infos d’auth stockées
      final sp = await SharedPreferences.getInstance();
      await sp.remove('auth.access_token');
      await sp.remove('auth.refresh_token');
      await sp.remove('auth.role');
      await sp.remove('auth.user_id');

      // Optionnel : si tu as d’autres états liés à l’utilisateur, nettoie-les ici.

      // Met à jour le Dio pour retirer l’Authorization
      final store = AuthStore();
      await DioClient.instance.initWithAuth(store);

      if (!mounted) return;
      // Retour à l’écran de login
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de déconnexion: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
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
