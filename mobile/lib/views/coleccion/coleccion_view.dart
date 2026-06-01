import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/coleccion_controller.dart';
import '../../controllers/lamina_controller.dart';
import '../../models/coleccion_item.dart';
import '../../models/lamina.dart';
import '../../models/pais.dart';

class ColeccionView extends StatefulWidget {
  const ColeccionView({super.key});

  @override
  State<ColeccionView> createState() => _ColeccionViewState();
}

class _ColeccionViewState extends State<ColeccionView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  Future<void> _refreshAll() async {
    final coleccion = context.read<ColeccionController>();
    final laminas = context.read<LaminaController>();
    await Future.wait([
      coleccion.cargarResumen(),
      laminas.cargarPaises(),
      laminas.cargarLaminas(),
    ]);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coleccion = context.watch<ColeccionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Coleccion'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabs: [
            const Tab(icon: Icon(Icons.auto_stories_outlined), text: 'Album'),
            const Tab(icon: Icon(Icons.bar_chart), text: 'Stats'),
            Tab(
              icon: const Icon(Icons.repeat),
              text: 'Repetidas (${coleccion.repetidas.length})',
            ),
            Tab(
              icon: const Icon(Icons.inventory_2_outlined),
              text: 'Faltan (${coleccion.faltantes.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _AlbumOverview(onRefresh: _refreshAll),
          _StatsDashboard(onRefresh: _refreshAll),
          _RepetidasTab(onRefresh: _refreshAll),
          _FaltantesTab(onRefresh: _refreshAll),
        ],
      ),
    );
  }
}

class _AlbumOverview extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _AlbumOverview({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final coleccion = context.watch<ColeccionController>();
    final laminasCtrl = context.watch<LaminaController>();
    final progreso = coleccion.progreso;
    final paises = _orderedPaises(laminasCtrl.paises, progreso);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 3
              : constraints.maxWidth >= 560
                  ? 2
                  : 1;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _GlobalProgressHeader(progreso: progreso),
              const SizedBox(height: 16),
              if (coleccion.loading && progreso == null)
                const Center(child: CircularProgressIndicator())
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: paises.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: columns == 1 ? 3.25 : 2.85,
                  ),
                  itemBuilder: (_, i) {
                    final pais = paises[i];
                    final stats = _statsForPais(
                      pais.iso3,
                      coleccion,
                      laminasCtrl.laminas,
                      progreso,
                    );
                    return _PaisAlbumCard(
                      pais: pais,
                      obtenidas: stats.obtenidas,
                      total: stats.total,
                      porcentaje: stats.porcentaje,
                      onTap: () => Navigator.of(context).push(
                        PageRouteBuilder<void>(
                          pageBuilder: (_, animation, __) =>
                              EquipoAlbumView(initialIso3: pais.iso3),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.04, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _GlobalProgressHeader extends StatelessWidget {
  final ProgresoData? progreso;

  const _GlobalProgressHeader({required this.progreso});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percent = (progreso?.porcentaje ?? 0) / 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: _unit(percent),
                  strokeWidth: 8,
                  backgroundColor: cs.surface.withValues(alpha: 0.45),
                  color: cs.primary,
                ),
                Center(
                  child: Text(
                    '${progreso?.porcentaje.toStringAsFixed(1) ?? '0'}%',
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Album Mundial 2026',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${progreso?.laminasObtenidas ?? 0} / ${progreso?.totalLaminas ?? 0} laminas pegadas',
                  style: TextStyle(color: cs.onPrimaryContainer),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _unit(percent),
                    minHeight: 8,
                    backgroundColor: cs.surface.withValues(alpha: 0.42),
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaisAlbumCard extends StatelessWidget {
  final Pais pais;
  final int obtenidas;
  final int total;
  final double porcentaje;
  final VoidCallback onTap;

  const _PaisAlbumCard({
    required this.pais,
    required this.obtenidas,
    required this.total,
    required this.porcentaje,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final complete = total > 0 && obtenidas >= total;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor:
                    complete ? Colors.amber.shade200 : cs.primaryContainer,
                child: Text(
                  pais.iso3,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: complete
                        ? Colors.amber.shade900
                        : cs.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pais.pais,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (complete)
                          Icon(Icons.emoji_events,
                              color: Colors.amber.shade700, size: 18),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Grupo ${pais.grupo}  ·  $obtenidas/$total',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _unit(porcentaje / 100),
                        minHeight: 7,
                        backgroundColor: cs.surfaceContainerHighest,
                        color: complete ? Colors.amber.shade700 : cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class EquipoAlbumView extends StatefulWidget {
  final String initialIso3;

  const EquipoAlbumView({super.key, required this.initialIso3});

  @override
  State<EquipoAlbumView> createState() => _EquipoAlbumViewState();
}

class _EquipoAlbumViewState extends State<EquipoAlbumView> {
  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializePageController();
  }

  void _initializePageController() {
    final paises = context.read<LaminaController>().paises;
    _pageIndex = math.max(
      0,
      paises.indexWhere((pais) => pais.iso3 == widget.initialIso3),
    );
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    if (_pageController != null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<ColeccionController>().cargarResumen(),
      context.read<LaminaController>().cargarPaises(),
      context.read<LaminaController>().cargarLaminas(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final paises = context.watch<LaminaController>().paises;

    // Sincronizar el índice si los paises cambiaron
    if (paises.isNotEmpty && _pageIndex >= paises.length) {
      _pageIndex = paises.length - 1;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_pageIndex);
      }
    }

    final safeIndex = paises.isEmpty
        ? 0
        : math.min(math.max(_pageIndex, 0), paises.length - 1);
    final title = paises.isEmpty ? 'Album' : paises[safeIndex].pais;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: paises.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              itemCount: paises.length,
              physics: const ClampingScrollPhysics(),
              onPageChanged: (index) {
                if (mounted && _pageIndex != index) {
                  setState(() => _pageIndex = index);
                }
              },
              itemBuilder: (_, index) {
                return _EquipoAlbumPage(
                  pais: paises[index],
                  onRefresh: _refresh,
                );
              },
            ),
    );
  }
}

class _EquipoAlbumPage extends StatelessWidget {
  final Pais pais;
  final Future<void> Function() onRefresh;

  const _EquipoAlbumPage({required this.pais, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final laminasCtrl = context.watch<LaminaController>();
    final coleccion = context.watch<ColeccionController>();
    final laminas = laminasCtrl.laminas
        .where((lamina) => lamina.iso3 == pais.iso3)
        .toList()
      ..sort((a, b) => a.numero.compareTo(b.numero));
    final owned = coleccion.idsObtenidas;
    final especial1 = _firstOrNull(laminas.where((l) => l.numero == 1));
    final especial13 = _firstOrNull(laminas.where((l) => l.numero == 13));
    final jugadores =
        laminas.where((l) => l.numero != 1 && l.numero != 13).toList();
    final obtenidas = laminas.where((l) => owned.contains(l.id)).length;
    final complete = laminas.isNotEmpty && obtenidas == laminas.length;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 880
              ? 5
              : constraints.maxWidth >= 640
                  ? 4
                  : 2;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TeamHeader(
                pais: pais,
                obtenidas: obtenidas,
                total: laminas.length,
                complete: complete,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (especial1 != null)
                    Expanded(
                      child: _StickerCard(
                        lamina: especial1,
                        owned: owned.contains(especial1.id),
                        item: coleccion.porLamina[especial1.id],
                        prominent: true,
                      ),
                    ),
                  if (especial1 != null && especial13 != null)
                    const SizedBox(width: 10),
                  if (especial13 != null)
                    Expanded(
                      child: _StickerCard(
                        lamina: especial13,
                        owned: owned.contains(especial13.id),
                        item: coleccion.porLamina[especial13.id],
                        prominent: true,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: jugadores.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: columns == 2 ? 0.72 : 0.68,
                ),
                itemBuilder: (_, i) {
                  final lamina = jugadores[i];
                  return _StickerCard(
                    lamina: lamina,
                    owned: owned.contains(lamina.id),
                    item: coleccion.porLamina[lamina.id],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  final Pais pais;
  final int obtenidas;
  final int total;
  final bool complete;

  const _TeamHeader({
    required this.pais,
    required this.obtenidas,
    required this.total,
    required this.complete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percent = total == 0 ? 0.0 : obtenidas / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: complete ? Colors.amber.shade100 : cs.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: complete ? Colors.amber.shade300 : cs.secondary,
            child: Text(
              pais.iso3,
              style: TextStyle(
                color: complete ? Colors.amber.shade900 : cs.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        pais.pais,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: complete
                                      ? Colors.amber.shade900
                                      : cs.onSecondaryContainer,
                                ),
                      ),
                    ),
                    if (complete)
                      Icon(Icons.workspace_premium,
                          color: Colors.amber.shade800),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '$obtenidas/$total completadas',
                  style: TextStyle(
                    color: complete
                        ? Colors.amber.shade900
                        : cs.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _unit(percent),
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.45),
                    color: complete ? Colors.amber.shade800 : cs.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StickerCard extends StatelessWidget {
  final Lamina lamina;
  final bool owned;
  final ColeccionItem? item;
  final bool prominent;

  const _StickerCard({
    required this.lamina,
    required this.owned,
    this.item,
    this.prominent = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = owned
        ? (lamina.esEscudo || lamina.esFotoEquipo
            ? Colors.amber.shade50
            : cs.surface)
        : cs.surfaceContainerHighest;
    final border = owned
        ? (lamina.esEscudo || lamina.esFotoEquipo
            ? Colors.amber.shade300
            : cs.outlineVariant)
        : cs.outlineVariant;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: owned ? 0.94 : 1, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        constraints: BoxConstraints(minHeight: prominent ? 164 : 190),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
          boxShadow: owned
              ? [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StickerImage(lamina: lamina, owned: owned),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${lamina.numero}',
                          style: TextStyle(
                            color: owned ? cs.primary : cs.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            owned ? lamina.nombreSticker : 'Bloqueada',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: owned ? cs.onSurface : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      owned ? lamina.tipoVisual : lamina.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    if (owned && (item?.cantidadRepetidas ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          '+${item!.cantidadRepetidas} repetidas',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickerImage extends StatelessWidget {
  final Lamina lamina;
  final bool owned;

  const _StickerImage({required this.lamina, required this.owned});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final icon = lamina.esEscudo
        ? Icons.shield_outlined
        : lamina.esFotoEquipo
            ? Icons.groups_2_outlined
            : Icons.person_outline;
    final url = lamina.fotoUrl;

    if (owned && url != null && url.isNotEmpty) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.transparent, BlendMode.src),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _ImageFallback(icon: icon, owned: owned),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: owned
            ? cs.primaryContainer.withValues(alpha: 0.55)
            : cs.surfaceContainerHighest,
      ),
      child: Center(
        child: Icon(
          owned ? icon : Icons.lock_outline,
          size: lamina.esFotoEquipo ? 48 : 42,
          color: owned ? cs.primary : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final IconData icon;
  final bool owned;

  const _ImageFallback({required this.icon, required this.owned});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration:
          BoxDecoration(color: cs.primaryContainer.withValues(alpha: 0.5)),
      child: Center(
        child: Icon(
          icon,
          color: owned ? cs.primary : cs.onSurfaceVariant,
          size: 42,
        ),
      ),
    );
  }
}

class _StatsDashboard extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _StatsDashboard({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final coleccion = context.watch<ColeccionController>();
    final progreso = coleccion.progreso;
    final paises = _progressRows(progreso);
    final most = paises.isEmpty
        ? null
        : paises.reduce((a, b) => _pct(a) >= _pct(b) ? a : b);
    final least = paises.isEmpty
        ? null
        : paises.reduce((a, b) => _pct(a) <= _pct(b) ? a : b);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GlobalProgressHeader(progreso: progreso),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 620;
              final cards = [
                _MetricCard(
                  icon: Icons.collections_bookmark_outlined,
                  label: 'Obtenidas',
                  value:
                      '${progreso?.laminasObtenidas ?? 0}/${progreso?.totalLaminas ?? 0}',
                ),
                _MetricCard(
                  icon: Icons.repeat,
                  label: 'Repetidas',
                  value: '${coleccion.totalRepetidas}',
                ),
                _MetricCard(
                  icon: Icons.trending_up,
                  label: 'Mas completo',
                  value: most == null
                      ? '-'
                      : '${most['pais']} (${_pct(most).toStringAsFixed(1)}%)',
                ),
                _MetricCard(
                  icon: Icons.pending_outlined,
                  label: 'Menos completo',
                  value: least == null
                      ? '-'
                      : '${least['pais']} (${_pct(least).toStringAsFixed(1)}%)',
                ),
              ];
              if (!twoColumns) {
                return Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              }
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.85,
                children: cards,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Progreso por equipo',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...paises.map((row) => _ProgressRow(row: row)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.tertiaryContainer,
              child: Icon(icon, color: cs.onTertiaryContainer, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final Map<String, dynamic> row;

  const _ProgressRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final porcentaje = _pct(row);
    final obtenidas = row['laminas_obtenidas'] as int? ?? 0;
    final total = row['total_laminas'] as int? ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              row['pais'] as String? ?? row['iso3'] as String? ?? '',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _unit(porcentaje / 100),
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                color: porcentaje == 100 ? Colors.amber.shade700 : cs.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '$obtenidas/$total',
              textAlign: TextAlign.end,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RepetidasTab extends StatefulWidget {
  final Future<void> Function() onRefresh;

  const _RepetidasTab({required this.onRefresh});

  @override
  State<_RepetidasTab> createState() => _RepetidasTabState();
}

class _RepetidasTabState extends State<_RepetidasTab> {
  String _team = 'todos';
  double _min = 1;

  @override
  Widget build(BuildContext context) {
    final coleccion = context.watch<ColeccionController>();
    final paises = context.watch<LaminaController>().paises;
    final filtered = coleccion.repetidas.where((item) {
      final iso = item.lamina?.iso3 ?? item.laminaId.substring(0, 3);
      return (_team == 'todos' || iso == _team) &&
          item.cantidadRepetidas >= _min.round();
    }).toList();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ListFilters(
            paises: paises,
            selectedTeam: _team,
            minValue: _min,
            minLabel: 'Min. repetidas',
            onTeamChanged: (value) => setState(() => _team = value),
            onMinChanged: (value) => setState(() => _min = value),
            onShare: () => _shareText(
              context,
              _buildRepetidasShare(filtered, paises),
              'Laminas repetidas',
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const _EmptyState(
              icon: Icons.repeat,
              text: 'No hay laminas repetidas con esos filtros',
            )
          else
            ..._orderedKeysForItems(filtered, paises).map((iso) {
              final items = filtered
                  .where((item) => (item.lamina?.iso3 ?? '') == iso)
                  .toList();
              return _GroupedSection(
                title: _paisName(iso, paises),
                count: items.length,
                children: items
                    .map((item) => _LaminaTile(
                          item: item,
                          showRepetidas: true,
                        ))
                    .toList(),
              );
            }),
        ],
      ),
    );
  }
}

class _FaltantesTab extends StatefulWidget {
  final Future<void> Function() onRefresh;

  const _FaltantesTab({required this.onRefresh});

  @override
  State<_FaltantesTab> createState() => _FaltantesTabState();
}

class _FaltantesTabState extends State<_FaltantesTab> {
  String _team = 'todos';

  @override
  Widget build(BuildContext context) {
    final coleccion = context.watch<ColeccionController>();
    final paises = context.watch<LaminaController>().paises;
    final filtered = coleccion.faltantes
        .where((lamina) => _team == 'todos' || lamina.iso3 == _team)
        .toList();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MissingFilters(
            paises: paises,
            selectedTeam: _team,
            onTeamChanged: (value) => setState(() => _team = value),
            onShare: () => _shareText(
              context,
              _buildFaltantesShare(filtered, paises),
              'Laminas faltantes',
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            const _EmptyState(
              icon: Icons.emoji_events,
              text: 'Coleccion completa para esos filtros',
            )
          else
            ..._orderedKeysForLaminas(filtered, paises).map((iso) {
              final items =
                  filtered.where((lamina) => lamina.iso3 == iso).toList();
              return _GroupedSection(
                title: _paisName(iso, paises),
                count: items.length,
                children: items
                    .map((lamina) => _MissingTile(lamina: lamina))
                    .toList(),
              );
            }),
        ],
      ),
    );
  }
}

class _ListFilters extends StatelessWidget {
  final List<Pais> paises;
  final String selectedTeam;
  final double minValue;
  final String minLabel;
  final ValueChanged<String> onTeamChanged;
  final ValueChanged<double> onMinChanged;
  final VoidCallback onShare;

  const _ListFilters({
    required this.paises,
    required this.selectedTeam,
    required this.minValue,
    required this.minLabel,
    required this.onTeamChanged,
    required this.onMinChanged,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _TeamDropdown(
                paises: paises,
                value: selectedTeam,
                onChanged: onTeamChanged,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox.square(
              dimension: 52,
              child: FilledButton(
                onPressed: onShare,
                child: const Icon(Icons.ios_share),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(width: 116, child: Text('$minLabel: ${minValue.round()}')),
            Expanded(
              child: Slider(
                value: minValue,
                min: 1,
                max: 5,
                divisions: 4,
                label: '${minValue.round()}',
                onChanged: onMinChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MissingFilters extends StatelessWidget {
  final List<Pais> paises;
  final String selectedTeam;
  final ValueChanged<String> onTeamChanged;
  final VoidCallback onShare;

  const _MissingFilters({
    required this.paises,
    required this.selectedTeam,
    required this.onTeamChanged,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TeamDropdown(
            paises: paises,
            value: selectedTeam,
            onChanged: onTeamChanged,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox.square(
          dimension: 52,
          child: FilledButton(
            onPressed: onShare,
            child: const Icon(Icons.ios_share),
          ),
        ),
      ],
    );
  }
}

class _TeamDropdown extends StatelessWidget {
  final List<Pais> paises;
  final String value;
  final ValueChanged<String> onChanged;

  const _TeamDropdown({
    required this.paises,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Equipo',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: 'todos', child: Text('Todos')),
        ...paises.map(
          (pais) => DropdownMenuItem(
            value: pais.iso3,
            child: Text('${pais.iso3} - ${pais.pais}'),
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _GroupedSection extends StatelessWidget {
  final String title;
  final int count;
  final List<Widget> children;

  const _GroupedSection({
    required this.title,
    required this.count,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              '$title ($count)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _LaminaTile extends StatelessWidget {
  final ColeccionItem item;
  final bool showRepetidas;

  const _LaminaTile({required this.item, required this.showRepetidas});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lamina = item.lamina;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lamina?.esEspecial == true
              ? Colors.amber.shade100
              : cs.primaryContainer,
          child: Text(
            lamina?.numero.toString() ?? item.laminaId,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: lamina?.esEspecial == true
                  ? Colors.amber.shade900
                  : cs.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          lamina?.nombreSticker ?? item.laminaId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          [
            if (lamina?.posicion != null) lamina!.posicion!,
            if (lamina?.equipoActual != null) lamina!.equipoActual!,
          ].join('  ·  '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: showRepetidas
            ? Chip(
                label: Text('+${item.cantidadRepetidas}'),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            : null,
      ),
    );
  }
}

class _MissingTile extends StatelessWidget {
  final Lamina lamina;

  const _MissingTile({required this.lamina});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      color: cs.surfaceContainerLowest,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.surfaceContainerHighest,
          child: Text(
            lamina.numero.toString(),
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        title: Text(
          lamina.nombreSticker,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${lamina.id}  ·  ${lamina.tipoVisual}',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
        trailing: const Icon(Icons.lock_open_outlined, size: 18),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(icon, size: 58, color: cs.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

List<Pais> _orderedPaises(List<Pais> paises, ProgresoData? progreso) {
  if (paises.isNotEmpty) return paises;
  return _progressRows(progreso)
      .map(
        (row) => Pais(
          iso3: row['iso3'] as String? ?? '',
          pais: row['pais'] as String? ?? row['iso3'] as String? ?? '',
          grupo: row['grupo'] as String? ?? '',
        ),
      )
      .where((pais) => pais.iso3.isNotEmpty)
      .toList();
}

_PaisStats _statsForPais(
  String iso3,
  ColeccionController coleccion,
  List<Lamina> laminas,
  ProgresoData? progreso,
) {
  final teamLaminas = laminas.where((lamina) => lamina.iso3 == iso3).toList();
  if (teamLaminas.isNotEmpty) {
    final ids = teamLaminas.map((lamina) => lamina.id).toSet();
    final obtenidas =
        coleccion.coleccion.where((item) => ids.contains(item.laminaId)).length;
    return _PaisStats(
      total: teamLaminas.length,
      obtenidas: obtenidas,
      porcentaje:
          teamLaminas.isEmpty ? 0 : obtenidas / teamLaminas.length * 100,
    );
  }

  final row = _firstOrNull(
    _progressRows(progreso).where((entry) => entry['iso3'] == iso3),
  );
  final total = row?['total_laminas'] as int? ?? 0;
  final obtenidas = row?['laminas_obtenidas'] as int? ?? 0;
  final porcentaje = (row?['porcentaje'] as num?)?.toDouble() ?? 0.0;
  return _PaisStats(total: total, obtenidas: obtenidas, porcentaje: porcentaje);
}

class _PaisStats {
  final int total;
  final int obtenidas;
  final double porcentaje;

  const _PaisStats({
    required this.total,
    required this.obtenidas,
    required this.porcentaje,
  });
}

List<Map<String, dynamic>> _progressRows(ProgresoData? progreso) {
  return progreso?.porPais ?? const [];
}

double _pct(Map<String, dynamic> row) {
  return (row['porcentaje'] as num?)?.toDouble() ?? 0.0;
}

double _unit(num value) {
  return value.clamp(0.0, 1.0).toDouble();
}

T? _firstOrNull<T>(Iterable<T> values) {
  final iterator = values.iterator;
  return iterator.moveNext() ? iterator.current : null;
}

String _paisName(String iso, List<Pais> paises) {
  for (final pais in paises) {
    if (pais.iso3 == iso) return pais.pais;
  }
  return iso;
}

List<String> _orderedKeysForItems(
    List<ColeccionItem> items, List<Pais> paises) {
  final keys = items
      .map((item) => item.lamina?.iso3 ?? item.laminaId.substring(0, 3))
      .toSet();
  final ordered = paises
      .map((pais) => pais.iso3)
      .where((iso) => keys.contains(iso))
      .toList();
  final leftovers = keys.where((iso) => !ordered.contains(iso)).toList()
    ..sort();
  return [...ordered, ...leftovers];
}

List<String> _orderedKeysForLaminas(List<Lamina> items, List<Pais> paises) {
  final keys = items.map((lamina) => lamina.iso3).toSet();
  final ordered = paises
      .map((pais) => pais.iso3)
      .where((iso) => keys.contains(iso))
      .toList();
  final leftovers = keys.where((iso) => !ordered.contains(iso)).toList()
    ..sort();
  return [...ordered, ...leftovers];
}

Future<void> _shareText(
  BuildContext context,
  String text,
  String subject,
) async {
  if (text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay datos para compartir')),
    );
    return;
  }
  await SharePlus.instance.share(
    ShareParams(text: text, subject: subject),
  );
}

String _buildRepetidasShare(List<ColeccionItem> items, List<Pais> paises) {
  if (items.isEmpty) return '';
  final buffer = StringBuffer('Mis laminas repetidas\n');
  for (final iso in _orderedKeysForItems(items, paises)) {
    buffer.writeln('\n${_paisName(iso, paises)}');
    final rows = items
        .where((item) =>
            (item.lamina?.iso3 ?? item.laminaId.substring(0, 3)) == iso)
        .toList();
    for (final item in rows) {
      final lamina = item.lamina;
      buffer.writeln(
        '- ${item.laminaId} ${lamina?.nombreSticker ?? ''} (+${item.cantidadRepetidas})',
      );
    }
  }
  return buffer.toString();
}

String _buildFaltantesShare(List<Lamina> items, List<Pais> paises) {
  if (items.isEmpty) return '';
  final buffer = StringBuffer('Mis laminas faltantes\n');
  for (final iso in _orderedKeysForLaminas(items, paises)) {
    buffer.writeln('\n${_paisName(iso, paises)}');
    final rows = items.where((lamina) => lamina.iso3 == iso).toList();
    for (final lamina in rows) {
      buffer.writeln('- ${lamina.id} ${lamina.nombreSticker}');
    }
  }
  return buffer.toString();
}
