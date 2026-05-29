import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../controllers/coleccion_controller.dart';
import '../../models/scan_history_item.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  final _iso3Ctrl = TextEditingController(text: 'MEX');
  final _numCtrl = TextEditingController(text: '1');
  final _scannerController = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 700,
    autoZoom: true,
  );

  bool _processing = false;
  String? _lastRaw;
  DateTime? _lastScanAt;
  _ScanFeedback? _feedback;

  bool get _scannerSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ColeccionController>().cargarHistorial();
    });
  }

  @override
  void dispose() {
    _iso3Ctrl.dispose();
    _numCtrl.dispose();
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  Future<void> _handleCapture(BarcodeCapture capture) async {
    String? raw;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue ?? barcode.displayValue;
      if (value != null && value.trim().isNotEmpty) {
        raw = value;
        break;
      }
    }
    if (raw == null || raw.trim().isEmpty) return;
    await _processRawQr(raw);
  }

  Future<void> _processRawQr(String raw) async {
    final now = DateTime.now();
    if (_processing) return;
    if (_lastRaw == raw &&
        _lastScanAt != null &&
        now.difference(_lastScanAt!) < const Duration(seconds: 2)) {
      return;
    }

    _lastRaw = raw;
    _lastScanAt = now;
    setState(() {
      _processing = true;
      _feedback = null;
    });

    final coleccion = context.read<ColeccionController>();
    if (_scannerSupported) {
      await _scannerController.stop().catchError((_) {});
    }

    try {
      final payload = _QrPayload.parse(raw);
      final result = await coleccion.escanearLamina(
        payload.equipoIso3,
        payload.laminaNumero,
        contenidoQr: raw,
      );
      if (!mounted) return;

      if (result == null) {
        setState(() {
          _feedback = _ScanFeedback.error(
            coleccion.error ?? 'Error al escanear',
          );
        });
      } else {
        setState(() {
          _feedback = _ScanFeedback.success(result);
        });
      }
    } on FormatException catch (e) {
      if (!mounted) return;
      setState(() {
        _feedback = _ScanFeedback.error(e.message);
      });
    } finally {
      if (mounted) {
        setState(() => _processing = false);
        if (_scannerSupported) {
          await Future<void>.delayed(const Duration(milliseconds: 900));
          await _scannerController.start().catchError((_) {});
        }
      }
    }
  }

  Future<void> _simularEscaneo() async {
    final iso3 = _iso3Ctrl.text.trim().toUpperCase();
    final num = int.tryParse(_numCtrl.text.trim());
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(iso3) ||
        num == null ||
        num < 1 ||
        num > 20) {
      setState(() {
        _feedback = _ScanFeedback.error(
          'QR invalido: ISO3 de 3 letras y numero entre 1 y 20',
        );
      });
      return;
    }

    await _processRawQr(jsonEncode({
      'equipo_id': iso3,
      'lamina_numero': num,
    }));
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const HistorialEscaneosView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final historial = context.watch<ColeccionController>().historial;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escaner QR'),
        actions: [
          IconButton(
            tooltip: 'Historial',
            onPressed: _openHistory,
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ColeccionController>().cargarHistorial(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _scannerSupported
                    ? _CameraScanner(
                        controller: _scannerController,
                        onDetect: _handleCapture,
                        processing: _processing,
                      )
                    : _ScannerUnavailable(colorScheme: cs),
              ),
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _feedback == null
                  ? _ScannerHint(processing: _processing)
                  : _ResultadoCard(key: ValueKey(_feedback), data: _feedback!),
            ),
            const SizedBox(height: 12),
            _ManualScanPanel(
              iso3Ctrl: _iso3Ctrl,
              numCtrl: _numCtrl,
              processing: _processing,
              onSubmit: _simularEscaneo,
            ),
            const SizedBox(height: 18),
            _RecentHistory(items: historial.take(5).toList()),
          ],
        ),
      ),
    );
  }
}

class _CameraScanner extends StatelessWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture capture) onDetect;
  final bool processing;

  const _CameraScanner({
    required this.controller,
    required this.onDetect,
    required this.processing,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth * 0.72, 300.0);
        final scanWindow = Rect.fromCenter(
          center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
          width: side,
          height: side,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: controller,
              scanWindow: scanWindow,
              fit: BoxFit.cover,
              onDetect: onDetect,
              errorBuilder: (context, error) {
                return _ScannerError(message: error.errorDetails?.message);
              },
              placeholderBuilder: (_) => const ColoredBox(
                color: Colors.black,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            CustomPaint(painter: _ScanFramePainter(scanWindow: scanWindow)),
            if (processing)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(child: CircularProgressIndicator()),
              ),
            Positioned(
              top: 12,
              right: 12,
              child: _ScannerCameraControls(controller: controller),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    'Apunta al codigo QR de la lamina',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScannerCameraControls extends StatelessWidget {
  final MobileScannerController controller;

  const _ScannerCameraControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final hasMultipleCameras = (state.availableCameras ?? 0) > 1;
        final torchAvailable = state.torchState != TorchState.unavailable;
        final torchOn = state.torchState == TorchState.on;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ScannerRoundButton(
              tooltip: torchOn ? 'Apagar linterna' : 'Encender linterna',
              onPressed: torchAvailable
                  ? () => unawaited(controller.toggleTorch())
                  : null,
              icon: torchOn ? Icons.flash_on : Icons.flash_off,
            ),
            const SizedBox(width: 8),
            _ScannerRoundButton(
              tooltip: 'Cambiar camara',
              onPressed: hasMultipleCameras
                  ? () => unawaited(controller.switchCamera())
                  : null,
              icon: Icons.cameraswitch_outlined,
            ),
          ],
        );
      },
    );
  }
}

class _ScannerRoundButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;

  const _ScannerRoundButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.55),
          disabledBackgroundColor: Colors.black.withValues(alpha: 0.25),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white54,
        ),
        icon: Icon(icon),
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  final Rect scanWindow;

  const _ScanFramePainter({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.44);
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final accentPaint = Paint()
      ..color = const Color(0xFF2ECC71)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final full = Path()..addRect(Offset.zero & size);
    final cutout = Path()
      ..addRRect(
          RRect.fromRectAndRadius(scanWindow, const Radius.circular(18)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, cutout),
      overlayPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanWindow, const Radius.circular(18)),
      borderPaint,
    );

    const corner = 36.0;
    final left = scanWindow.left;
    final right = scanWindow.right;
    final top = scanWindow.top;
    final bottom = scanWindow.bottom;
    canvas
      ..drawLine(Offset(left, top + corner), Offset(left, top), accentPaint)
      ..drawLine(Offset(left, top), Offset(left + corner, top), accentPaint)
      ..drawLine(Offset(right - corner, top), Offset(right, top), accentPaint)
      ..drawLine(Offset(right, top), Offset(right, top + corner), accentPaint)
      ..drawLine(
        Offset(left, bottom - corner),
        Offset(left, bottom),
        accentPaint,
      )
      ..drawLine(
        Offset(left, bottom),
        Offset(left + corner, bottom),
        accentPaint,
      )
      ..drawLine(
        Offset(right - corner, bottom),
        Offset(right, bottom),
        accentPaint,
      )
      ..drawLine(
        Offset(right, bottom),
        Offset(right, bottom - corner),
        accentPaint,
      );
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow;
  }
}

class _ScannerError extends StatelessWidget {
  final String? message;

  const _ScannerError({this.message});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined,
                  color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                message ?? 'No se pudo abrir la camara',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerUnavailable extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ScannerUnavailable({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_2,
                  size: 74, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                'Camara QR no disponible en esta plataforma',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerHint extends StatelessWidget {
  final bool processing;

  const _ScannerHint({required this.processing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('hint'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            processing ? Icons.hourglass_top : Icons.center_focus_strong,
            color: cs.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              processing ? 'Procesando lamina...' : 'Listo para escanear',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualScanPanel extends StatelessWidget {
  final TextEditingController iso3Ctrl;
  final TextEditingController numCtrl;
  final bool processing;
  final VoidCallback onSubmit;

  const _ManualScanPanel({
    required this.iso3Ctrl,
    required this.numCtrl,
    required this.processing,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('Ingreso manual'),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: iso3Ctrl,
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
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: numCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nro.',
                  hintText: '1',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox.square(
              dimension: 52,
              child: FilledButton(
                onPressed: processing ? null : onSubmit,
                child: processing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultadoCard extends StatelessWidget {
  final _ScanFeedback data;

  const _ResultadoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.errorMessage != null) {
      return _ErrorResult(message: data.errorMessage!);
    }
    final result = data.result!;
    final esNueva = result['estado'] == 'nueva';
    final lamina = result['lamina'] as Map<String, dynamic>?;
    final id = lamina?['id'] as String? ?? '';
    final iso3 = lamina?['iso3'] as String? ?? '';
    final numero =
        id.startsWith(iso3) ? int.tryParse(id.substring(iso3.length)) : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esNueva ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
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
                esNueva ? Icons.auto_awesome : Icons.repeat,
                color: esNueva ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  esNueva
                      ? 'Nueva lamina pegada'
                      : 'Lamina repetida (${result['cantidad_repetidas']} disponibles)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: esNueva
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          if (lamina != null) ...[
            const SizedBox(height: 12),
            Text(
              lamina['nombre_sticker'] as String? ?? id,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (iso3.isNotEmpty) iso3,
                if (numero != null) '#$numero',
                if (lamina['posicion'] != null) lamina['posicion'],
                if (lamina['equipo_actual'] != null) lamina['equipo_actual'],
              ].join('  ·  '),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorResult extends StatelessWidget {
  final String message;

  const _ErrorResult({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentHistory extends StatelessWidget {
  final List<ScanHistoryItem> items;

  const _RecentHistory({required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escaneos recientes',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text(
            'Sin escaneos registrados',
            style: TextStyle(color: cs.onSurfaceVariant),
          )
        else
          ...items.map((item) => _HistoryTile(item: item)),
      ],
    );
  }
}

class HistorialEscaneosView extends StatefulWidget {
  const HistorialEscaneosView({super.key});

  @override
  State<HistorialEscaneosView> createState() => _HistorialEscaneosViewState();
}

class _HistorialEscaneosViewState extends State<HistorialEscaneosView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ColeccionController>().cargarHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ColeccionController>();
    final items = controller.historial;

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: RefreshIndicator(
        onRefresh: () => context.read<ColeccionController>().cargarHistorial(),
        child: items.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Sin escaneos registrados')),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) => _HistoryTile(item: items[i]),
              ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final ScanHistoryItem item;

  const _HistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lamina = item.lamina;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              item.esNueva ? Colors.green.shade100 : Colors.orange.shade100,
          child: Icon(
            item.esNueva ? Icons.check : Icons.repeat,
            color:
                item.esNueva ? Colors.green.shade800 : Colors.orange.shade800,
            size: 19,
          ),
        ),
        title: Text(
          lamina?.nombreSticker ?? item.laminaId,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            item.laminaId,
            _formatDate(item.fechaEscaneo),
            if (!item.esNueva) '+${item.cantidadRepetidas} repetidas',
          ].join('  ·  '),
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
        ),
      ),
    );
  }
}

class _ScanFeedback {
  final Map<String, dynamic>? result;
  final String? errorMessage;

  const _ScanFeedback._({this.result, this.errorMessage});

  factory _ScanFeedback.success(Map<String, dynamic> data) =>
      _ScanFeedback._(result: data);

  factory _ScanFeedback.error(String message) =>
      _ScanFeedback._(errorMessage: message);
}

class _QrPayload {
  final String equipoIso3;
  final int laminaNumero;

  const _QrPayload({required this.equipoIso3, required this.laminaNumero});

  factory _QrPayload.parse(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      throw const FormatException('QR vacio');
    }

    if (text.startsWith('{')) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is Map<String, dynamic>) {
          return _QrPayload._fromValues(
            decoded['equipo_id'] ?? decoded['equipo_iso3'] ?? decoded['iso3'],
            decoded['lamina_numero'] ?? decoded['numero'],
          );
        }
      } on FormatException {
        throw const FormatException('QR con JSON invalido');
      }
    }

    final match = RegExp(r'^([A-Za-z]{3})[-_\s:]?(\d{1,2})$').firstMatch(text);
    if (match != null) {
      return _QrPayload._fromValues(match.group(1), match.group(2));
    }

    throw const FormatException(
      'QR invalido: se esperaba equipo_id y lamina_numero',
    );
  }

  factory _QrPayload._fromValues(Object? equipo, Object? numero) {
    final iso3 = (equipo ?? '').toString().trim().toUpperCase();
    final n = int.tryParse((numero ?? '').toString().trim());
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(iso3) || n == null || n < 1 || n > 20) {
      throw const FormatException(
        'QR con formato incorrecto: equipo_id y lamina_numero',
      );
    }
    return _QrPayload(equipoIso3: iso3, laminaNumero: n);
  }
}

String _formatDate(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year} '
      '${two(value.hour)}:${two(value.minute)}';
}
