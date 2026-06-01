import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/coleccion_controller.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final _iso3Ctrl = TextEditingController(text: 'MEX');
  final _numCtrl = TextEditingController(text: '1');
  bool _scanning = false;
  Map<String, dynamic>? _resultado;

  @override
  void dispose() {
    _iso3Ctrl.dispose();
    _numCtrl.dispose();
    super.dispose();
  }

  Future<void> _simularEscaneo() async {
    final iso3 = _iso3Ctrl.text.trim().toUpperCase();
    final num = int.tryParse(_numCtrl.text.trim());
    if (iso3.length != 3 || num == null || num < 1 || num > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ISO3 debe tener 3 letras y número entre 1 y 20')),
      );
      return;
    }

    setState(() {
      _scanning = true;
      _resultado = null;
    });

    final result =
        await context.read<ColeccionController>().escanearLamina(iso3, num);
    if (!mounted) return;

    setState(() {
      _scanning = false;
      _resultado = result;
    });

    if (result == null) {
      final err = context.read<ColeccionController>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Error al escanear'),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escáner QR')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── QR Frame Placeholder ──────────────────────────────────
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B2A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Corner decorations
                  ..._buildCorners(),
                  // Inner content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Escáner QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A227)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFC9A227)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'Próximamente',
                          style: TextStyle(
                            color: Color(0xFFC9A227),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Simulador ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B2A).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.tune,
                            size: 18, color: Color(0xFF0D1B2A)),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Simular escaneo',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1B2A),
                            ),
                          ),
                          Text(
                            'Introduce los datos del QR manualmente',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF90A4AE)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _iso3Ctrl,
                          textCapitalization: TextCapitalization.characters,
                          maxLength: 3,
                          decoration: const InputDecoration(
                            labelText: 'ISO3',
                            hintText: 'MEX',
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _numCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Nro.',
                            hintText: '1',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _scanning ? null : _simularEscaneo,
                      icon: _scanning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.qr_code),
                      label: Text(_scanning ? 'Escaneando...' : 'Simular escaneo'),
                    ),
                  ),
                ],
              ),
            ),

            // ── Resultado ─────────────────────────────────────────────
            if (_resultado != null) ...[
              const SizedBox(height: 20),
              _ResultadoCard(data: _resultado!),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const size = 28.0;
    const stroke = 3.0;
    const color = Color(0xFFC9A227);
    const radius = Radius.circular(4);

    Widget corner(AlignmentGeometry align, BorderRadius borderRadius) =>
        Positioned(
          child: Align(
            alignment: align,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: size,
                height: size,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: borderRadius.topLeft != Radius.zero
                          ? const BorderSide(color: color, width: stroke)
                          : BorderSide.none,
                      bottom: borderRadius.bottomLeft != Radius.zero
                          ? const BorderSide(color: color, width: stroke)
                          : BorderSide.none,
                      left: (borderRadius.topLeft != Radius.zero ||
                              borderRadius.bottomLeft != Radius.zero)
                          ? const BorderSide(color: color, width: stroke)
                          : BorderSide.none,
                      right: (borderRadius.topRight != Radius.zero ||
                              borderRadius.bottomRight != Radius.zero)
                          ? const BorderSide(color: color, width: stroke)
                          : BorderSide.none,
                    ),
                    borderRadius: borderRadius,
                  ),
                ),
              ),
            ),
          ),
        );

    return [
      corner(Alignment.topLeft,
          const BorderRadius.only(topLeft: radius)),
      corner(Alignment.topRight,
          const BorderRadius.only(topRight: radius)),
      corner(Alignment.bottomLeft,
          const BorderRadius.only(bottomLeft: radius)),
      corner(Alignment.bottomRight,
          const BorderRadius.only(bottomRight: radius)),
    ];
  }
}

class _ResultadoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ResultadoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final esNueva = data['estado'] == 'nueva';
    final lamina = data['lamina'] as Map<String, dynamic>?;
    final bgColor =
        esNueva ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1);
    final borderColor =
        esNueva ? const Color(0xFF81C784) : const Color(0xFFFFCA28);
    final iconColor =
        esNueva ? const Color(0xFF2E7D32) : const Color(0xFFF57F17);
    final label = esNueva ? '¡Lámina nueva!' : 'Lámina repetida';
    final icon = esNueva ? Icons.new_releases_rounded : Icons.repeat_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: iconColor,
                ),
              ),
            ],
          ),
          if (lamina != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lamina['nombre_sticker'] as String? ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'ID: ${lamina['id']}  ·  ${lamina['iso3']}',
                          style: const TextStyle(
                            color: Color(0xFF78909C),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!esNueva)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x${data['cantidad_repetidas']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
