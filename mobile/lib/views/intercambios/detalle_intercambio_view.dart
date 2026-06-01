import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/intercambio_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/intercambio.dart';

class DetalleIntercambioView extends StatelessWidget {
  final Intercambio intercambio;
  const DetalleIntercambioView({super.key, required this.intercambio});

  @override
  Widget build(BuildContext context) {
    final myId = context.read<AuthController>().user?.id;
    final soyEmisor = intercambio.usuarioEmisorId == myId;
    final otroNombre = soyEmisor
        ? (intercambio.receptorNombre ?? 'Usuario')
        : (intercambio.emisorNombre ?? 'Usuario');

    return Scaffold(
      appBar: AppBar(
        title: Text('Intercambio #${intercambio.id}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _EstadoCard(intercambio: intercambio),
          const SizedBox(height: 16),
          _InfoCard(
            title: soyEmisor ? 'Tú propusiste a' : 'Propuesto por',
            name: otroNombre,
            tipo: intercambio.tipo,
            fecha: intercambio.createdAt,
          ),
          const SizedBox(height: 16),
          _LaminasSection(
            titulo: 'Láminas que ofreces',
            laminas: intercambio.laminas
                    ?.where((l) => l.direccion == (soyEmisor ? 'emisor' : 'receptor'))
                    .toList() ??
                [],
            color: Colors.blue.shade50,
          ),
          const SizedBox(height: 12),
          _LaminasSection(
            titulo: 'Láminas que recibes',
            laminas: intercambio.laminas
                    ?.where((l) => l.direccion == (soyEmisor ? 'receptor' : 'emisor'))
                    .toList() ??
                [],
            color: Colors.green.shade50,
          ),
          if (intercambio.puntoEncuentroDesc != null ||
              intercambio.fechaEncuentro != null) ...[
            const SizedBox(height: 16),
            _EncuentroCard(intercambio: intercambio),
          ],
          const SizedBox(height: 24),
          _AccionesSection(intercambio: intercambio, soyEmisor: soyEmisor),
        ],
      ),
    );
  }
}

class _EstadoCard extends StatelessWidget {
  final Intercambio intercambio;
  const _EstadoCard({required this.intercambio});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _estadoInfo(intercambio.estado);
    return Card(
      color: color.withAlpha(30),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 16)),
        subtitle: Text(
          '${intercambio.tipo == 'presencial' ? 'Presencial' : 'Virtual'} · '
          'Actualizado ${_fechaRelativa(intercambio.updatedAt ?? intercambio.createdAt)}',
        ),
      ),
    );
  }

  (Color, IconData, String) _estadoInfo(String estado) {
    switch (estado) {
      case 'pendiente':
        return (Colors.orange, Icons.hourglass_empty, 'Esperando respuesta');
      case 'aceptado':
        return (Colors.blue, Icons.check_circle_outline, 'Aceptado — pendiente de encuentro');
      case 'completado':
        return (Colors.green, Icons.check_circle, 'Completado');
      case 'rechazado':
        return (Colors.red, Icons.cancel, 'Rechazado');
      case 'cancelado':
        return (Colors.grey, Icons.block, 'Cancelado');
      default:
        return (Colors.grey, Icons.help, estado);
    }
  }

  String _fechaRelativa(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return 'hace ${diff.inDays}d';
    if (diff.inHours > 0) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inMinutes}min';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String name;
  final String tipo;
  final DateTime fecha;
  const _InfoCard(
      {required this.title,
      required this.name,
      required this.tipo,
      required this.fecha});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(name[0].toUpperCase(),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold)),
        ),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: Icon(
          tipo == 'presencial' ? Icons.handshake : Icons.swap_horiz,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _LaminasSection extends StatelessWidget {
  final String titulo;
  final List<IntercambioLamina> laminas;
  final Color color;
  const _LaminasSection(
      {required this.titulo, required this.laminas, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(titulo,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
        if (laminas.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Sin láminas', style: TextStyle(color: Colors.grey)),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: laminas
                  .map((l) => ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 16,
                          child: Text(l.laminaId,
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(l.nombreSticker ?? l.laminaId,
                            style: const TextStyle(fontSize: 13)),
                        subtitle: Text(
                          [if (l.posicion != null) l.posicion!, if (l.iso3 != null) l.iso3!].join(' · '),
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: l.esEspecial == true
                            ? const Icon(Icons.star, color: Colors.amber, size: 16)
                            : null,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _EncuentroCard extends StatelessWidget {
  final Intercambio intercambio;
  const _EncuentroCard({required this.intercambio});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Punto de encuentro',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            if (intercambio.metodoEnvio == 'correo')
              const ListTile(
                dense: true,
                leading: Icon(Icons.mail_outline),
                title: Text('Por correo físico'),
              )
            else ...[
              if (intercambio.puntoEncuentroDesc != null)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(intercambio.puntoEncuentroDesc!),
                ),
              if (intercambio.fechaEncuentro != null)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(_formatFecha(intercambio.fechaEncuentro!)),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatFecha(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _AccionesSection extends StatelessWidget {
  final Intercambio intercambio;
  final bool soyEmisor;
  const _AccionesSection({required this.intercambio, required this.soyEmisor});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<IntercambioController>();
    final estado = intercambio.estado;

    if (estado == 'completado' || estado == 'rechazado' || estado == 'cancelado') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (estado == 'pendiente' && !soyEmisor) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Aceptar intercambio'),
              onPressed: () => _confirmar(
                context,
                '¿Aceptar este intercambio?',
                () => ctrl.aceptarIntercambio(intercambio.id),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (estado == 'aceptado' && (soyEmisor || !soyEmisor))
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.done_all),
              label: const Text('Confirmar recepción (Completar)'),
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => _confirmar(
                context,
                '¿Confirmar que recibiste las láminas? Esto completará el intercambio.',
                () => ctrl.completarIntercambio(intercambio.id),
              ),
            ),
          ),
        const SizedBox(height: 8),
        if (['pendiente', 'aceptado'].contains(estado))
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar / Rechazar'),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => _confirmar(
                context,
                '¿Rechazar este intercambio?',
                () => ctrl.rechazarIntercambio(intercambio.id),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmar(
    BuildContext context,
    String mensaje,
    Future<bool> Function() accion,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final result = await accion();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ? 'Operación exitosa' : 'Error al procesar'),
            backgroundColor: result ? Colors.green : Colors.red,
          ),
        );
        if (result) Navigator.pop(context);
      }
    }
  }
}
