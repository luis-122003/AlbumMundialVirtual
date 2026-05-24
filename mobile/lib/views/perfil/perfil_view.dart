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
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cerrar sesión')),
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          if (!_editando)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _editando = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _editando = false),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: cs.primaryContainer,
              child: Text(
                user?.nombre.characters.first.toUpperCase() ?? '?',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              user?.email ?? '',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
          if (_editando) ...[
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _ciudadCtrl,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                prefixIcon: Icon(Icons.location_city_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _paisCtrl,
              decoration: const InputDecoration(
                labelText: 'País',
                prefixIcon: Icon(Icons.flag_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 10),
              Text(auth.error!,
                  style: TextStyle(color: cs.error), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: auth.loading ? null : _guardar,
                child: auth.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar cambios'),
              ),
            ),
          ] else ...[
            _InfoTile(icon: Icons.person_outline, label: 'Nombre', value: user?.nombre ?? '—'),
            _InfoTile(icon: Icons.location_city_outlined, label: 'Ciudad', value: user?.ciudad ?? '—'),
            _InfoTile(icon: Icons.flag_outlined, label: 'País', value: user?.pais ?? '—'),
            _InfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Miembro desde',
              value: user != null
                  ? '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                  : '—',
            ),
          ],
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.error,
              side: BorderSide(color: cs.error),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
