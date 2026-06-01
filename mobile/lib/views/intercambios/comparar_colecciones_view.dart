import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/intercambio_controller.dart';
import '../../models/intercambio.dart';
import 'nuevo_intercambio_view.dart';

class CompararColeccionesView extends StatefulWidget {
  final UsuarioBusqueda usuario;
  const CompararColeccionesView({super.key, required this.usuario});

  @override
  State<CompararColeccionesView> createState() => _CompararColeccionesViewState();
}

class _CompararColeccionesViewState extends State<CompararColeccionesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IntercambioController>().compararColecciones(widget.usuario.id);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<IntercambioController>();
    final comp = ctrl.comparacion;

    return Scaffold(
      appBar: AppBar(
        title: Text('vs ${widget.usuario.nombre}'),
        bottom: comp != null
            ? TabBar(
                controller: _tabCtrl,
                tabs: [
                  Tab(text: 'Yo doy (${comp.yoTengoElOtroNecesita.length})'),
                  Tab(text: 'Yo recibo (${comp.otroTieneYoNecesito.length})'),
                ],
              )
            : null,
      ),
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : comp == null
              ? Center(
                  child: Text(ctrl.error ?? 'Error al cargar comparación',
                      style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    _ResumenBanner(comparacion: comp),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Filtrar por nombre o país...',
                          prefixIcon: Icon(Icons.search),
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => _filtro = v.toLowerCase()),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _LaminasList(
                            laminas: _filtrar(comp.yoTengoElOtroNecesita),
                            empty: 'No tienes láminas repetidas que el otro necesite.',
                            badge: 'DOYS',
                            badgeColor: Colors.blue,
                          ),
                          _LaminasList(
                            laminas: _filtrar(comp.otroTieneYoNecesito),
                            empty: '${widget.usuario.nombre} no tiene repetidas que necesites.',
                            badge: 'RECIBES',
                            badgeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: comp != null &&
              comp.yoTengoElOtroNecesita.isNotEmpty &&
              comp.otroTieneYoNecesito.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NuevoIntercambioView(
                    comparacion: comp,
                    tipo: 'presencial',
                  ),
                ),
              ),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Proponer intercambio'),
            )
          : null,
    );
  }

  List<LaminaComparacion> _filtrar(List<LaminaComparacion> lista) {
    if (_filtro.isEmpty) return lista;
    return lista.where((l) =>
        l.nombreSticker.toLowerCase().contains(_filtro) ||
        (l.iso3?.toLowerCase().contains(_filtro) ?? false) ||
        l.laminaId.toLowerCase().contains(_filtro)).toList();
  }
}

class _ResumenBanner extends StatelessWidget {
  final ComparacionResult comparacion;
  const _ResumenBanner({required this.comparacion});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: cs.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
              label: 'Yo doy',
              value: '${comparacion.yoTengoElOtroNecesita.length}',
              color: Colors.blue),
          _Stat(
              label: 'Coincidencias',
              value: '${comparacion.matches}',
              color: cs.primary),
          _Stat(
              label: 'Yo recibo',
              value: '${comparacion.otroTieneYoNecesito.length}',
              color: Colors.green),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _LaminasList extends StatelessWidget {
  final List<LaminaComparacion> laminas;
  final String empty;
  final String badge;
  final Color badgeColor;
  const _LaminasList(
      {required this.laminas,
      required this.empty,
      required this.badge,
      required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    if (laminas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(empty, textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: laminas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        final l = laminas[i];
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor: l.esEspecial ? Colors.amber.shade100 : badgeColor.withAlpha(30),
              child: Text(l.laminaId,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: l.esEspecial ? Colors.amber.shade900 : badgeColor)),
            ),
            title: Text(l.nombreSticker, style: const TextStyle(fontSize: 13)),
            subtitle: Text(
              [if (l.posicion != null) l.posicion!, if (l.iso3 != null) l.iso3!].join(' · '),
              style: const TextStyle(fontSize: 11),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (l.esEspecial) const Icon(Icons.star, color: Colors.amber, size: 16),
                if (l.cantidadRepetidas > 1)
                  Chip(
                    label: Text('+${l.cantidadRepetidas}',
                        style: const TextStyle(fontSize: 10)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
