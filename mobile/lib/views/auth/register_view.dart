import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  final VoidCallback onGoToLogin;
  const RegisterView({super.key, required this.onGoToLogin});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _paisCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _ciudadCtrl.dispose();
    _paisCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthController>().register(
          _nombreCtrl.text,
          _emailCtrl.text,
          _passCtrl.text,
          ciudad: _ciudadCtrl.text.isEmpty ? null : _ciudadCtrl.text,
          pais: _paisCtrl.text.isEmpty ? null : _paisCtrl.text,
        );
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  // ── Logo ─────────────────────────────────────────────
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A227),
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFC9A227)
                              .withValues(alpha: 0.35),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person_add,
                        size: 36, color: Color(0xFF0D1B2A)),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Crear cuenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Únete y empieza tu colección',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Form Card ────────────────────────────────────────
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
                            'Datos de registro',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1B2A),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nombreCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nombre completo',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Requerido'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) =>
                                (v == null || !v.contains('@'))
                                    ? 'Email inválido'
                                    : null,
                          ),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 16),
                          const _SectionDivider(label: 'Opcional'),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _ciudadCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Ciudad',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _paisCtrl,
                            decoration: const InputDecoration(
                              labelText: 'País',
                              prefixIcon: Icon(Icons.flag_outlined),
                            ),
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
                                    color: const Color(0xFFEF9A9A)),
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
                                  : const Text('Crear cuenta'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: widget.onGoToLogin,
                    child: RichText(
                      text: TextSpan(
                        text: '¿Ya tienes cuenta? ',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13),
                        children: const [
                          TextSpan(
                            text: 'Iniciar sesión',
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

class _SectionDivider extends StatelessWidget {
  final String label;
  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }
}
