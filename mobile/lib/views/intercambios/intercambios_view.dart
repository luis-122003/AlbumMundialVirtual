import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/intercambio_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/intercambio.dart';
import 'detalle_intercambio_view.dart';
import 'comparar_colecciones_view.dart';

class IntercambiosView extends StatefulWidget {
  const IntercambiosView({super.key});

  @override
  State<IntercambiosView> createState() => _IntercambiosViewState();
}

class _IntercambiosViewState extends State<IntercambiosView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<IntercambioController>();
      ctrl.cargarIntercambios();
      ctrl.cargarOfertas();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intercambios'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'Mis (${ctrl.activos.length})'),
            const Tab(text: 'Explorar'),
            const Tab(text: 'Buscar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _MisIntercambiosTab(ctrl: ctrl),
          _ExplorarTab(ctrl: ctrl),
          const _BuscarUsuarioTab(),
        ],
      ),
    );
  }
}

// ─── Tab 1: Mis Intercambios ─────────────────────────────────────────────────

class _MisIntercambiosTab extends StatefulWidget {
  final IntercambioController ctrl;
  const _MisIntercambiosTab({required this.ctrl});

  @override
  State<_MisIntercambiosTab> createState() => _MisIntercambiosTabState();
}

class _MisIntercambiosTabState extends State<_MisIntercambiosTab>
    with SingleTickerProviderStateMixin {
  late TabController _inner;

  @override
  void initState() {
    super.initState();
    _inner = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _inner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ctrl;
    return Column(
      children: [
        TabBar(
          controller: _inner,
          labelColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: 'Activos (${ctrl.activos.length})'),
            Tab(text: 'Historial (${ctrl.historial.length})'),
          ],
        ),
        Expanded(
          child: ctrl.loading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _inner,
                  children: [
                    _IntercambioList(
                      intercambios: ctrl.activos,
                      empty: 'No tienes intercambios activos.',
                      onRefresh: ctrl.cargarIntercambios,
                    ),
                    _IntercambioList(
                      intercambios: ctrl.historial,
                      empty: 'Sin intercambios en el historial.',
                      onRefresh: ctrl.cargarIntercambios,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _IntercambioList extends StatelessWidget {
  final List<Intercambio> intercambios;
  final String empty;
  final Future<void> Function() onRefresh;
  const _IntercambioList(
      {required this.intercambios, required this.empty, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (intercambios.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(empty,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      );
    }
    final myId = context.read<AuthController>().user?.id;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: intercambios.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) => _IntercambioTile(
          intercambio: intercambios[i],
          myId: myId ?? 0,
        ),
      ),
    );
  }
}

class _IntercambioTile extends StatelessWidget {
  final Intercambio intercambio;
  final int myId;
  const _IntercambioTile({required this.intercambio, required this.myId});

  @override
  Widget build(BuildContext context) {
    final soyEmisor = intercambio.usuarioEmisorId == myId;
    final otroNombre = soyEmisor
        ? (intercambio.receptorNombre ?? 'Usuario')
        : (intercambio.emisorNombre ?? 'Usuario');
    final (color, icon, label) = _estadoInfo(intercambio.estado);
    final laminasEmisor =
        intercambio.laminas?.where((l) => l.direccion == 'emisor').length ?? 0;
    final laminasReceptor =
        intercambio.laminas?.where((l) => l.direccion == 'receptor').length ?? 0;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalleIntercambioView(intercambio: intercambio),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          soyEmisor ? 'A: $otroNombre' : 'De: $otroNombre',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: Text(
          '$label · ${intercambio.tipo} · $laminasEmisor↔$laminasReceptor lám.',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Icon(
          intercambio.tipo == 'presencial' ? Icons.handshake : Icons.swap_horiz,
          size: 18,
          color: Colors.grey,
        ),
      ),
    );
  }

  (Color, IconData, String) _estadoInfo(String estado) {
    switch (estado) {
      case 'pendiente':
        return (Colors.orange, Icons.hourglass_empty, 'Pendiente');
      case 'aceptado':
        return (Colors.blue, Icons.check_circle_outline, 'Aceptado');
      case 'completado':
        return (Colors.green, Icons.check_circle, 'Completado');
      case 'rechazado':
        return (Colors.red, Icons.cancel, 'Rechazado');
      default:
        return (Colors.grey, Icons.block, estado);
    }
  }
}

// ─── Tab 2: Explorar Ofertas ─────────────────────────────────────────────────

class _ExplorarTab extends StatelessWidget {
  final IntercambioController ctrl;
  const _ExplorarTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.loading && ctrl.ofertas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.ofertas.isEmpty) {
      return RefreshIndicator(
        onRefresh: ctrl.cargarOfertas,
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 300,
            child: Center(
              child: Text('No hay usuarios con láminas repetidas aún.',
                  textAlign: TextAlign.center),
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: ctrl.cargarOfertas,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: ctrl.ofertas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) => _OfertaTile(oferta: ctrl.ofertas[i]),
      ),
    );
  }
}

class _OfertaTile extends StatelessWidget {
  final OfertaUsuario oferta;
  const _OfertaTile({required this.oferta});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompararColeccionesView(
              usuario: UsuarioBusqueda(
                id: oferta.id,
                nombre: oferta.nombre,
                email: oferta.email,
                ciudad: oferta.ciudad,
                pais: oferta.pais,
              ),
            ),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(oferta.nombre[0].toUpperCase(),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold)),
        ),
        title: Text(oferta.nombre,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(
          [
            if (oferta.ciudad != null) oferta.ciudad!,
            if (oferta.pais != null) oferta.pais!,
          ].join(', ').isNotEmpty
              ? [
                  if (oferta.ciudad != null) oferta.ciudad!,
                  if (oferta.pais != null) oferta.pais!,
                ].join(', ')
              : oferta.email,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (oferta.tieneParaMi > 0)
              Text('${oferta.tieneParaMi} para ti',
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.w600)),
            if (oferta.necesitaDeMi > 0)
              Text('${oferta.necesitaDeMi} te pide',
                  style: const TextStyle(fontSize: 11, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 3: Buscar Usuario ───────────────────────────────────────────────────

class _BuscarUsuarioTab extends StatefulWidget {
  const _BuscarUsuarioTab();

  @override
  State<_BuscarUsuarioTab> createState() => _BuscarUsuarioTabState();
}

class _BuscarUsuarioTabState extends State<_BuscarUsuarioTab> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intercambioCtrl = context.watch<IntercambioController>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _ctrl.clear();
                        context.read<IntercambioController>().limpiarBusqueda();
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => context.read<IntercambioController>().buscarUsuarios(v),
          ),
        ),
        if (intercambioCtrl.loadingBusqueda)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          )
        else if (intercambioCtrl.resultadosBusqueda.isEmpty && _ctrl.text.length >= 2)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Sin resultados para esa búsqueda.'),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: intercambioCtrl.resultadosBusqueda.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, i) => _UsuarioTile(
                usuario: intercambioCtrl.resultadosBusqueda[i],
              ),
            ),
          ),
        if (_ctrl.text.length < 2 && intercambioCtrl.resultadosBusqueda.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_search, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Escribe al menos 2 caracteres\npara buscar usuarios',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _UsuarioTile extends StatelessWidget {
  final UsuarioBusqueda usuario;
  const _UsuarioTile({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CompararColeccionesView(usuario: usuario),
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(usuario.nombre[0].toUpperCase(),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold)),
        ),
        title: Text(usuario.nombre,
            style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          [
            usuario.email,
            if (usuario.ciudad != null) usuario.ciudad!,
          ].join(' · '),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.compare_arrows, size: 20),
      ),
    );
  }
}
