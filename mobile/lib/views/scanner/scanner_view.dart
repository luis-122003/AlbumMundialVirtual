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
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Escáner QR')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Placeholder cámara
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner,
                      size: 72, color: cs.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    'Escáner QR — Próximamente',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Simula un escaneo abajo',
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Simular escaneo',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Introduce los datos del QR manualmente',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 16),
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
                      border: OutlineInputBorder(),
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
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _scanning ? null : _simularEscaneo,
                icon: _scanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.qr_code),
                label: Text(_scanning ? 'Escaneando...' : 'Simular escaneo'),
              ),
            ),
            if (_resultado != null) ...[
              const SizedBox(height: 24),
              _ResultadoCard(data: _resultado!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultadoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ResultadoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final esNueva = data['estado'] == 'nueva';
    final lamina = data['lamina'] as Map<String, dynamic>?;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esNueva ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esNueva ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                esNueva ? Icons.new_releases : Icons.repeat,
                color: esNueva ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                esNueva ? '¡Lámina nueva!' : 'Lámina repetida',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: esNueva
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
            ],
          ),
          if (lamina != null) ...[
            const SizedBox(height: 10),
            Text(
              lamina['nombre_sticker'] as String? ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${lamina['id']}  ·  ${lamina['iso3']}',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            ),
            if (!esNueva)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Repetidas: ${data['cantidad_repetidas']}',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
