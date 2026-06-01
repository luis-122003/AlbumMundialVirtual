import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/intercambio_controller.dart';
import '../../models/intercambio.dart';

class NuevoIntercambioView extends StatefulWidget {
  final ComparacionResult comparacion;
  final String tipo;
  const NuevoIntercambioView({
    super.key,
    required this.comparacion,
    required this.tipo,
  });

  @override
  State<NuevoIntercambioView> createState() => _NuevoIntercambioViewState();
}

class _NuevoIntercambioViewState extends State<NuevoIntercambioView> {
  final Set<String> _selEmisor = {};
  final Set<String> _selReceptor = {};

  bool get _puedeEnviar => _selEmisor.isNotEmpty && _selReceptor.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final comp = widget.comparacion;
    return Scaffold(
      appBar: AppBar(
        title: Text('Proponer a ${comp.otroUsuario.nombre}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(widget.tipo == 'presencial' ? 'Presencial' : 'Virtual'),
              avatar: Icon(
                widget.tipo == 'presencial' ? Icons.handshake : Icons.swap_horiz,
                size: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'Láminas que ofreces',
                    subtitle: 'Selecciona las tuyas repetidas que le darás',
                    color: Colors.blue,
                    count: _selEmisor.length,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final l = comp.yoTengoElOtroNecesita[i];
                      return _LaminaCheckTile(
                        lamina: l,
                        selected: _selEmisor.contains(l.laminaId),
                        accentColor: Colors.blue,
                        onToggle: (v) => setState(() =>
                            v ? _selEmisor.add(l.laminaId) : _selEmisor.remove(l.laminaId)),
                      );
                    },
                    childCount: comp.yoTengoElOtroNecesita.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    title: 'Láminas que pides',
                    subtitle: 'Selecciona las suyas repetidas que recibirás',
                    color: Colors.green,
                    count: _selReceptor.length,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final l = comp.otroTieneYoNecesito[i];
                      return _LaminaCheckTile(
                        lamina: l,
                        selected: _selReceptor.contains(l.laminaId),
                        accentColor: Colors.green,
                        onToggle: (v) => setState(() =>
                            v ? _selReceptor.add(l.laminaId) : _selReceptor.remove(l.laminaId)),
                      );
                    },
                    childCount: comp.otroTieneYoNecesito.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_puedeEnviar)
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Selecciona al menos una lámina de cada sección',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _puedeEnviar ? () => _enviar(context) : null,
                  icon: const Icon(Icons.send),
                  label: Text(
                    'Enviar propuesta (${_selEmisor.length} × ${_selReceptor.length})',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _enviar(BuildContext context) async {
    final ctrl = context.read<IntercambioController>();
    final intercambio = await ctrl.crearIntercambio(
      receptorId: widget.comparacion.otroUsuario.id,
      tipo: widget.tipo,
      laminasEmisor: _selEmisor.toList(),
      laminasReceptor: _selReceptor.toList(),
    );
    if (!context.mounted) return;
    if (intercambio != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Propuesta enviada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ctrl.error ?? 'Error al enviar la propuesta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final int count;
  const _SectionHeader(
      {required this.title,
      required this.subtitle,
      required this.color,
      required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: color.withAlpha(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (count > 0)
            Chip(
              label: Text('$count selec.',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              backgroundColor: color.withAlpha(30),
            ),
        ],
      ),
    );
  }
}

class _LaminaCheckTile extends StatelessWidget {
  final LaminaComparacion lamina;
  final bool selected;
  final Color accentColor;
  final ValueChanged<bool> onToggle;
  const _LaminaCheckTile(
      {required this.lamina,
      required this.selected,
      required this.accentColor,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      onChanged: (v) => onToggle(v ?? false),
      activeColor: accentColor,
      title: Text(lamina.nombreSticker, style: const TextStyle(fontSize: 13)),
      subtitle: Text(
        [lamina.laminaId, if (lamina.iso3 != null) lamina.iso3!].join(' · '),
        style: const TextStyle(fontSize: 11),
      ),
      secondary: lamina.esEspecial
          ? const Icon(Icons.star, color: Colors.amber, size: 18)
          : null,
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
