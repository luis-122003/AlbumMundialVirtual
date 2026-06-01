import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/coleccion_controller.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  bool _editando = false;
  late TextEditingController _nombreCtrl;
  late TextEditingController _ciudadCtrl;
  late TextEditingController _paisCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user;
    _nombreCtrl = TextEditingController(text: user?.nombre ?? '');
    _ciudadCtrl = TextEditingController(text: user?.ciudad ?? '');
    _paisCtrl = TextEditingController(text: user?.pais ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _ciudadCtrl.dispose();
    _paisCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final auth = context.read<AuthController>();
    final ok = await auth.updateProfile({
      'nombre': _nombreCtrl.text.trim(),
      'ciudad': _ciudadCtrl.text.trim(),
      'pais': _paisCtrl.text.trim(),
    });
    if (!mounted) return;
    if (ok) {
      setState(() => _editando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  }

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              minimumSize: const Size(0, 40),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      context.read<ColeccionController>().reset();
      await context.read<AuthController>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final nombre = user?.nombre ?? '';
    final initial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header Banner ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0D1B2A),
            actions: [
              if (!_editando)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar perfil',
                  onPressed: () => setState(() => _editando = true),
                )
              else
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Cancelar',
                  onPressed: () => setState(() => _editando = false),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0D1B2A), Color(0xFF1E3A5F)],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9A227),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC9A227)
                                    .withValues(alpha: 0.35),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Color(0xFF0D1B2A),
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text(
                'Mi Perfil',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
              collapseMode: CollapseMode.parallax,
            ),
          ),

          // ── Cuerpo ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_editando) ...[
                    const _SectionLabel(label: 'Editar información'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      const SizedBox(height: 10),
                      Text(auth.error!,
                          style: const TextStyle(
                              color: Color(0xFFD32F2F), fontSize: 13),
                          textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: auth.loading ? null : _guardar,
                        icon: auth.loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check, size: 20),
                        label: const Text('Guardar cambios'),
                      ),
                    ),
                  ] else ...[
                    const _SectionLabel(label: 'Información'),
                    const SizedBox(height: 12),
                    _InfoCard(children: [
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Nombre',
                        value: user?.nombre ?? '—',
                      ),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Correo',
                        value: user?.email ?? '—',
                      ),
                      _InfoRow(
                        icon: Icons.location_city_outlined,
                        label: 'Ciudad',
                        value: user?.ciudad ?? '—',
                        isLast: user?.pais == null || user!.pais!.isEmpty,
                      ),
                      if (user?.pais != null && user!.pais!.isNotEmpty)
                        _InfoRow(
                          icon: Icons.flag_outlined,
                          label: 'País',
                          value: user.pais!,
                          isLast: true,
                        ),
                    ]),
                    const SizedBox(height: 16),
                    const _SectionLabel(label: 'Cuenta'),
                    const SizedBox(height: 12),
                    _InfoCard(children: [
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Miembro desde',
                        value: user != null
                            ? '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                            : '—',
                        isLast: true,
                      ),
                    ]),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _cerrarSesion,
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Cerrar sesión'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD32F2F),
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF546E7A),
        letterSpacing: 0.4,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF1E3A5F)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF90A4AE),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 48, endIndent: 16),
      ],
    );
  }
}
