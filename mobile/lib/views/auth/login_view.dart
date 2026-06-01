import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  final VoidCallback onGoToRegister;
  const LoginView({super.key, required this.onGoToRegister});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthController>().login(_emailCtrl.text, _passCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1B2A), Color(0xFF1E3A5F), Color(0xFF0A1628)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // ── Logo ───────────────────────────────────────────────
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A227),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC9A227).withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 44,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Panini Mundial 2026',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tu álbum digital de colección',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Form Card ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1B2A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ingresa tus credenciales para continuar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 22),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) => (v == null || !v.contains('@'))
                                ? 'Email inválido'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Mínimo 6 caracteres'
                                : null,
                          ),
                          if (auth.error != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFEF9A9A),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: Color(0xFFD32F2F), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      auth.error!,
                                      style: const TextStyle(
                                        color: Color(0xFFB71C1C),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton(
                              onPressed: auth.loading ? null : _submit,
                              child: auth.loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Iniciar sesión'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: widget.onGoToRegister,
                    child: RichText(
                      text: TextSpan(
                        text: '¿No tienes cuenta? ',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13),
                        children: const [
                          TextSpan(
                            text: 'Regístrate',
                            style: TextStyle(
                              color: Color(0xFFC9A227),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
