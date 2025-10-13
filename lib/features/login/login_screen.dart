import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
      if (!mounted) return;
      final role = r['role'] as String;
      Navigator.of(
        context,
      ).pushReplacementNamed('/dashboard', arguments: {'role': role});
    } on DioException catch (e) {
      // Récupère un maximum d’infos utiles
      final status = e.response?.statusCode;
      final method = e.requestOptions.method;
      final uri = e.requestOptions.uri;

      // Essaie d’extraire un message du backend (JSON: message/error/detail)
      String backendMsg = '';
      final data = e.response?.data;
      if (data is Map) {
        backendMsg = (data['message'] ?? data['error'] ?? data['detail'] ?? '')
            .toString();
      } else if (data != null) {
        backendMsg = data.toString();
      }

      setState(() {
        _error = [
          if (status != null) 'HTTP $status',
          '$method $uri',
          if (backendMsg.isNotEmpty) backendMsg,
          if (e.message != null &&
              (backendMsg.isEmpty || !backendMsg.contains('${e.message}')))
            '${e.message}',
        ].where((s) => s != null && s.toString().trim().isNotEmpty).join('\n');
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur inattendue: $e';
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

    return Scaffold(
      body: SingleChildScrollView(
       /* decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 188, 200, 218),
              Color.fromARGB(255, 142, 171, 169),
            ],
          ),
        ),*/
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
