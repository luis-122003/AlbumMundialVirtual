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
    final progreso = coleccion.progreso;
    final nombre = auth.user?.nombre ?? '';
    final initial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => coleccion.cargarProgreso(),
        child: CustomScrollView(
          slivers: [
            // ── Hero SliverAppBar ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color(0xFF0D1B2A),
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
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC9A227),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: Color(0xFF0D1B2A),
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¡Hola, $nombre!',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'FIFA World Cup 2026',
                                      style: TextStyle(
                                        color: Color(0xFFC9A227),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.sports_soccer,
                                color: Colors.white24,
                                size: 32,
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (progreso != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${progreso.laminasObtenidas} / ${progreso.totalLaminas} láminas',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${progreso.porcentaje.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Color(0xFFC9A227),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progreso.porcentaje / 100,
                                minHeight: 8,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFC9A227)),
                              ),
                            ),
                          ] else if (coleccion.loading)
                            const LinearProgressIndicator(
                              backgroundColor: Colors.white12,
                              color: Color(0xFFC9A227),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                title: const Text(
                  'Inicio',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                titlePadding:
                    const EdgeInsets.only(left: 16, bottom: 12),
                collapseMode: CollapseMode.parallax,
              ),
            ),

            // ── Contenido ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row
                    if (progreso != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.collections_bookmark,
                              label: 'Obtenidas',
                              value:
                                  '${progreso.laminasObtenidas}',
                              sub: 'de ${progreso.totalLaminas}',
                              color: const Color(0xFF0D1B2A),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.pending_actions,
                              label: 'Faltantes',
                              value:
                                  '${progreso.totalLaminas - progreso.laminasObtenidas}',
                              sub: 'por conseguir',
                              color: const Color(0xFFC9A227),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Country progress
                    if (progreso != null &&
                        progreso.porPais.isNotEmpty) ...[
                      const Text(
                        'Progreso por selección',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...progreso.porPais
                          .map((p) => _PaisProgressTile(pais: p)),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(color: Color(0xFF90A4AE), fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF546E7A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── País Progress Tile ──────────────────────────────────────────────────────

class _PaisProgressTile extends StatelessWidget {
  final Map<String, dynamic> pais;
  const _PaisProgressTile({required this.pais});

  @override
  Widget build(BuildContext context) {
    final obtenidas = pais['laminas_obtenidas'] as int? ?? 0;
    final total = pais['total_laminas'] as int? ?? 0;
    final porcentaje = (pais['porcentaje'] as num?)?.toDouble() ?? 0.0;
    final nombre = pais['pais'] as String? ?? '';
    final completado = obtenidas == total && total > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: completado
            ? Border.all(
                color: const Color(0xFFC9A227).withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (completado)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.check_circle, color: Color(0xFFC9A227), size: 16),
            ),
          SizedBox(
            width: completado ? 88 : 96,
            child: Text(
              nombre,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D1B2A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total > 0 ? porcentaje / 100 : 0,
                minHeight: 6,
                backgroundColor: const Color(0xFFE2EAF4),
                valueColor: AlwaysStoppedAnimation<Color>(
                  completado
                      ? const Color(0xFFC9A227)
                      : const Color(0xFF1E3A5F),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(
              '$obtenidas/$total',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF546E7A),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
