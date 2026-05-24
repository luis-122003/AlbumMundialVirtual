import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/coleccion_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ColeccionController>().cargarProgreso();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final coleccion = context.watch<ColeccionController>();
    final cs = Theme.of(context).colorScheme;
    final progreso = coleccion.progreso;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => coleccion.cargarProgreso(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Saludo
            Card(
              color: cs.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: cs.primary,
                      radius: 28,
                      child: Text(
                        auth.user?.nombre.characters.first.toUpperCase() ?? '?',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, ${auth.user?.nombre ?? ''}!',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onPrimaryContainer,
                                ),
                          ),
                          Text(
                            'Tu álbum te espera',
                            style: TextStyle(color: cs.onPrimaryContainer),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.sports_soccer,
                        size: 36, color: cs.onPrimaryContainer),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Progreso general
            Text(
              'Tu progreso',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (coleccion.loading && progreso == null)
              const Center(child: CircularProgressIndicator())
            else ...[
              _StatCard(
                icon: Icons.collections_bookmark_outlined,
                label: 'Láminas obtenidas',
                value: progreso != null
                    ? '${progreso.laminasObtenidas} / ${progreso.totalLaminas}'
                    : '—',
                color: cs.primary,
              ),
              const SizedBox(height: 10),
              _StatCard(
                icon: Icons.percent_rounded,
                label: 'Porcentaje completado',
                value: progreso != null ? '${progreso.porcentaje}%' : '—',
                color: cs.secondary,
                child: progreso != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progreso.porcentaje / 100,
                            minHeight: 8,
                            backgroundColor: cs.secondaryContainer,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(cs.secondary),
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 10),
              if (progreso != null && progreso.porPais.isNotEmpty) ...[
                Text(
                  'Por país',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...progreso.porPais.take(6).map((p) => _PaisProgressTile(pais: p)),
                if (progreso.porPais.length > 6)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+ ${progreso.porPais.length - 6} países más',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                    ),
                  ),
              ],
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Widget? child;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Text(label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}

class _PaisProgressTile extends StatelessWidget {
  final Map<String, dynamic> pais;
  const _PaisProgressTile({required this.pais});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final obtenidas = pais['laminas_obtenidas'] as int? ?? 0;
    final total = pais['total_laminas'] as int? ?? 0;
    final porcentaje = pais['porcentaje'] as double? ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              pais['pais'] as String? ?? '',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: porcentaje / 100,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$obtenidas/$total',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
