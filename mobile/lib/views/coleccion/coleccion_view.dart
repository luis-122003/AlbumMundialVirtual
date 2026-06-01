import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/coleccion_controller.dart';
import '../../models/coleccion_item.dart';
import '../../models/lamina.dart';

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
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context.read<ColeccionController>();
      c.cargarColeccion();
      c.cargarRepetidas();
      c.cargarFaltantes();
    });
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
        title: const Text('Mi Álbum'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'Tengo (${coleccion.coleccion.length})'),
            Tab(text: 'Repetidas (${coleccion.repetidas.length})'),
            Tab(text: 'Faltan (${coleccion.faltantes.length})'),
          ],
        ),
      ),
      body: coleccion.loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _CardGrid(
                  items: coleccion.coleccion,
                  empty: 'Aún no tienes láminas.\n¡Escanea tu primer QR!',
                  onRefresh: coleccion.cargarColeccion,
                ),
                _CardGrid(
                  items: coleccion.repetidas,
                  empty: 'No tienes láminas repetidas.',
                  showRepetidas: true,
                  onRefresh: coleccion.cargarRepetidas,
                ),
                _MissingGrid(
                  laminas: coleccion.faltantes,
                  onRefresh: coleccion.cargarFaltantes,
                ),
              ],
            ),
    );
  }
}

// ─── Grilla de cartas obtenidas ──────────────────────────────────────────────

class _CardGrid extends StatelessWidget {
  final List<ColeccionItem> items;
  final String empty;
  final bool showRepetidas;
  final Future<void> Function() onRefresh;

  const _CardGrid({
    required this.items,
    required this.empty,
    required this.onRefresh,
    this.showRepetidas = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories_outlined,
                  size: 56,
                  color: Theme.of(context).colorScheme.outlineVariant),
              const SizedBox(height: 16),
              Text(
                empty,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.62,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return _PaniniCard(
            id: item.laminaId,
            nombre: item.lamina?.nombreSticker ?? item.laminaId,
            iso3: item.lamina?.iso3 ?? '???',
            posicion: item.lamina?.posicion,
            esEspecial: item.lamina?.esEspecial ?? false,
            fotoUrl: item.lamina?.fotoUrl,
            owned: true,
            repeatedCount: showRepetidas && item.cantidadRepetidas > 0
                ? item.cantidadRepetidas
                : null,
          );
        },
      ),
    );
  }
}

// ─── Grilla de cartas faltantes ──────────────────────────────────────────────

class _MissingGrid extends StatelessWidget {
  final List<Lamina> laminas;
  final Future<void> Function() onRefresh;

  const _MissingGrid({required this.laminas, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (laminas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 72, color: Color(0xFFC9A227)),
            SizedBox(height: 16),
            Text(
              '¡Colección completa!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF0D1B2A),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Felicitaciones, tienes todas las láminas.',
              style: TextStyle(color: Color(0xFF607D8B)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.62,
          crossAxisSpacing: 8,
          mainAxisSpacing: 12,
        ),
        itemCount: laminas.length,
        itemBuilder: (_, i) {
          final l = laminas[i];
          return _PaniniCard(
            id: l.id,
            nombre: l.nombreSticker,
            iso3: l.iso3,
            posicion: l.posicion,
            esEspecial: l.esEspecial,
            fotoUrl: l.fotoUrl,
            owned: false,
          );
        },
      ),
    );
  }
}

// ─── Carta Panini ────────────────────────────────────────────────────────────

class _PaniniCard extends StatelessWidget {
  final String id;
  final String nombre;
  final String iso3;
  final String? posicion;
  final bool esEspecial;
  final String? fotoUrl;
  final bool owned;
  final int? repeatedCount;

  const _PaniniCard({
    required this.id,
    required this.nombre,
    required this.iso3,
    this.posicion,
    required this.esEspecial,
    this.fotoUrl,
    required this.owned,
    this.repeatedCount,
  });

  static Color _countryColor(String iso3) {
    const palette = [
      Color(0xFF1565C0), Color(0xFFC62828), Color(0xFF2E7D32),
      Color(0xFFF57F17), Color(0xFF6A1B9A), Color(0xFF00695C),
      Color(0xFF37474F), Color(0xFF4527A0), Color(0xFF00838F),
      Color(0xFF283593), Color(0xFF6D4C41), Color(0xFF558B2F),
    ];
    final h = iso3.codeUnits.fold(0, (a, b) => (a * 31 + b) & 0x7FFFFFFF);
    return palette[h % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _countryColor(iso3);
    final initial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    // Photo area (gradient + initial as fallback)
    Widget photoArea = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.85),
            color.withValues(alpha: 0.45),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    if (fotoUrl != null && fotoUrl!.isNotEmpty) {
      photoArea = Image.network(
        fotoUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => photoArea,
      );
    }

    // Card inner content
    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Country header bar
        Container(
          height: 26,
          color: color,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  iso3,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (esEspecial)
                const Icon(Icons.star, color: Color(0xFFFFD700), size: 13),
            ],
          ),
        ),
        // Photo
        Expanded(child: photoArea),
        // Name strip
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(5, 4, 5, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B2A),
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                posicion ?? id,
                style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFF78909C),
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    // Clip corners of card content
    Widget clipped = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: cardContent,
    );

    // Missing card: grayscale + dark overlay with "?"
    if (!owned) {
      clipped = Stack(
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.213, 0.715, 0.072, 0, 0,
              0.213, 0.715, 0.072, 0, 0,
              0.213, 0.715, 0.072, 0, 0,
              0,     0,     0,     1, 0,
            ]),
            child: clipped,
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.black.withValues(alpha: 0.55),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.question_mark_rounded,
                      color: Colors.white.withValues(alpha: 0.45),
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      id,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Outer shadow (gold glow for special owned, normal shadow otherwise)
    Widget result = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: (esEspecial && owned)
                ? const Color(0xFFFFD700).withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.14),
            blurRadius: (esEspecial && owned) ? 10 : 4,
            spreadRadius: (esEspecial && owned) ? 1 : 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: clipped,
    );

    // Repetidas badge (top-right corner)
    if (repeatedCount != null && repeatedCount! > 0) {
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          result,
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A227),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Text(
                'x${repeatedCount! + 1}',
                style: const TextStyle(
                  color: Color(0xFF0D1B2A),
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return result;
  }
}
