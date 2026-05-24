import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/coleccion_controller.dart';
import '../../models/coleccion_item.dart';

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
        title: const Text('Mi Colección'),
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
                _LaminaList(
                  items: coleccion.coleccion,
                  empty: 'Aún no tienes láminas. ¡Escanea tu primer QR!',
                ),
                _LaminaList(
                  items: coleccion.repetidas,
                  empty: 'No tienes láminas repetidas.',
                  showRepetidas: true,
                ),
                _FaltantesList(laminas: coleccion.faltantes),
              ],
            ),
    );
  }
}

class _LaminaList extends StatelessWidget {
  final List<ColeccionItem> items;
  final String empty;
  final bool showRepetidas;

  const _LaminaList({
    required this.items,
    required this.empty,
    this.showRepetidas = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(empty,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ColeccionController>().cargarColeccion(),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) => _LaminaTile(
            item: items[i], showRepetidas: showRepetidas),
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
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lamina?.esEspecial == true
              ? Colors.amber.shade100
              : cs.primaryContainer,
          child: Text(
            item.laminaId,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: lamina?.esEspecial == true
                  ? Colors.amber.shade900
                  : cs.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(
          lamina?.nombreSticker ?? item.laminaId,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(
          [
            if (lamina?.posicion != null) lamina!.posicion!,
            if (lamina?.equipoActual != null) lamina!.equipoActual!,
          ].join(' · '),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: showRepetidas && item.cantidadRepetidas > 0
            ? Chip(
                label: Text(
                  '+${item.cantidadRepetidas}',
                  style: const TextStyle(fontSize: 11),
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )
            : lamina?.esEspecial == true
                ? const Icon(Icons.star, color: Colors.amber, size: 18)
                : null,
      ),
    );
  }
}

class _FaltantesList extends StatelessWidget {
  final List<dynamic> laminas;
  const _FaltantesList({required this.laminas});

  @override
  Widget build(BuildContext context) {
    if (laminas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            SizedBox(height: 12),
            Text('¡Colección completa!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ColeccionController>().cargarFaltantes(),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: laminas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) {
          final l = laminas[i];
          return Card(
            margin: EdgeInsets.zero,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.help_outline, size: 18),
              ),
              title: Text(l.nombreSticker,
                  style: const TextStyle(fontSize: 14)),
              subtitle: Text(l.id, style: const TextStyle(fontSize: 12)),
              trailing: l.esEspecial
                  ? const Icon(Icons.star_border, color: Colors.amber, size: 18)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
