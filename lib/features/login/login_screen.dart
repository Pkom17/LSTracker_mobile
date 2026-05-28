import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lstracker/utils/auth_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/services/auth_service.dart';
import '../../data/stores/auth_store.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _remember = true;
  bool _loading = false;
  bool _showPassword = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    AuthStore().savedUsername.then((v) {
      if (v != null && mounted) _usernameCtl.text = v;
    });
  }

  @override
  void dispose() {
    _usernameCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Requis' : null;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        setState(() {
          _error = 'Impossible d\'ouvrir le lien: $url';
        });
      }
    }
  }

  void _launchCGU() {
    _launchURL('https://lstracker.org/legal/terms');
  }

  void _launchPrivacyPolicy() {
    _launchURL('https://lstracker.org/legal/privacy');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await widget.authService.login(
        username: _usernameCtl.text.trim(),
        password: _passwordCtl.text,
        rememberUsername: _remember,
      );
      // Réchauffe le cache AuthUtils avec la nouvelle session avant
      // de naviguer vers le dashboard (sinon roleOrNull() = null au
      // premier build et les écrans retombent sur le FutureBuilder).
      await AuthUtils.prime();
      if (!mounted) return;
      final role = r['role'] as String;
      Navigator.of(
        context,
      ).pushReplacementNamed('/dashboard', arguments: {'role': role});
    } on DioException catch (e) {
      // Détail technique uniquement en logs (jamais à l'écran) pour le debug.
      debugPrint('Login DioException: ${e.requestOptions.method} '
          '${e.requestOptions.uri} → HTTP ${e.response?.statusCode} ; '
          'message=${e.message} ; data=${e.response?.data}');

      // Message convivial selon le type d'erreur. On ne renvoie JAMAIS la
      // réponse brute du backend (peut contenir une stacktrace).
      final status = e.response?.statusCode;
      String userMsg;
      if (status == 401 || status == 403) {
        userMsg = 'Identifiant ou mot de passe incorrect.';
      } else if (status == 400) {
        userMsg = 'Requête invalide. Vérifiez vos informations de connexion.';
      } else if (status != null && status >= 500) {
        userMsg = 'Le serveur a rencontré un problème. Réessayez plus tard.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        userMsg = 'Connexion au serveur impossible. Vérifiez votre réseau.';
      } else {
        userMsg = 'Échec de la connexion. Réessayez.';
      }

      setState(() {
        _error = userMsg;
      });
    } catch (e) {
      debugPrint('Login unexpected error: $e');
      setState(() {
        _error = 'Une erreur inattendue est survenue. Réessayez.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 720;

    final theme = Theme.of(context);
    final linkStyle = TextStyle(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        reverse: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 920 : 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(width: 8),
                      Text(
                        'Bienvenue sur LSTracker',
                        style: TextStyle(
                          color: Color.fromARGB(255, 12, 12, 12),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: Image(image: AssetImage("assets/ls_bann.png")),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Login Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _usernameCtl,
                              decoration: const InputDecoration(
                                labelText: 'Identifiant',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: _required,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordCtl,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                    () => _showPassword = !_showPassword,
                                  ),
                                ),
                              ),
                              obscureText: !_showPassword,
                              validator: _required,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Checkbox(
                                  value: _remember,
                                  onChanged: (v) =>
                                      setState(() => _remember = v ?? true),
                                ),
                                const Text("Mémoriser l'identifiant"),
                                const Spacer(),
                              ],
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 48,
                              child: FilledButton(
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Se connecter'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8.0, // Espace horizontal
                              runSpacing: 4.0, // Espace vertical si wrapping
                              children: [
                                // Utilisation de InkWell pour un style
                                // plus personnalisable que TextButton
                                InkWell(
                                  onTap: _launchCGU,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                      vertical: 2.0,
                                    ),
                                    child: Text('CGU', style: linkStyle),
                                  ),
                                ),
                                Text(
                                  '|',
                                  style: TextStyle(color: theme.disabledColor),
                                ),
                                InkWell(
                                  onTap: _launchPrivacyPolicy,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                      vertical: 2.0,
                                    ),
                                    child: Text(
                                      'Politique de confidentialité',
                                      style: linkStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'v2.0',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
