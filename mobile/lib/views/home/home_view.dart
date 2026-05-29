import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/coleccion_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ColeccionController>().cargarProgreso();
    });

    // Inicializar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animations = [
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
        ),
      ),
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
        ),
      ),
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
        ),
      ),
    ];

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final coleccion = context.watch<ColeccionController>();
    final progreso = coleccion.progreso;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        centerTitle: false,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => coleccion.cargarProgreso(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Saludo mejorado
            FadeTransition(
              opacity: _animations[0],
              child: _GreetingCard(
                userName: auth.user?.nombre ?? '',
              ),
            ),
            const SizedBox(height: 24),

            // Progreso general
            FadeTransition(
              opacity: _animations[1],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu progreso',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  if (coleccion.loading && progreso == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    _StatCard(
                      icon: Icons.collections_bookmark_outlined,
                      label: 'Láminas obtenidas',
                      value: progreso != null
                          ? '${progreso.laminasObtenidas} / ${progreso.totalLaminas}'
                          : '—',
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _StatCard(
                      icon: Icons.percent_rounded,
                      label: 'Porcentaje completado',
                      value: progreso != null ? '${progreso.porcentaje}%' : '—',
                      color: AppTheme.secondaryColor,
                      child: progreso != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progreso.porcentaje / 100,
                                  minHeight: 10,
                                  backgroundColor:
                                      AppTheme.primaryColor.withOpacity(0.1),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Por país
            if (progreso != null && progreso.porPais.isNotEmpty)
              FadeTransition(
                opacity: _animations[2],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Por país',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ...progreso.porPais.take(6).map((p) {
                              final index =
                                  progreso.porPais.indexOf(p);
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index < 5 ? 12 : 0,
                                ),
                                child: _PaisProgressTile(pais: p),
                              );
                            }),
                            if (progreso.porPais.length > 6) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Divider(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '+ ${progreso.porPais.length - 6} países más',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Tarjeta de saludo mejorada
class _GreetingCard extends StatelessWidget {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ColeccionController>().cargarProgreso();
    });

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppTheme.darkPrimaryColor.withValues(alpha: 0.8),
                  AppTheme.darkSecondaryColor.withValues(alpha: 0.6),
                ]
              : [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor.withValues(alpha: 0.8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  userName.characters.first.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $userName!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tu álbum te espera',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.sports_soccer,
              size: 32,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// Tarjeta estadística mejorada
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }
}

// Tile de progreso por país
class _PaisProgressTile extends StatelessWidget {
  final Map<String, dynamic> pais;

  const _PaisProgressTile({required this.pais});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final obtenidas = pais['laminas_obtenidas'] as int? ?? 0;
    final total = pais['total_laminas'] as int? ?? 0;
    final porcentaje = pais['porcentaje'] as double? ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                pais['pais'] as String? ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$obtenidas/$total',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: porcentaje / 100,
            minHeight: 8,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.accentColor,
            ),
          ),
        ),
      ],
    );
  }
}
