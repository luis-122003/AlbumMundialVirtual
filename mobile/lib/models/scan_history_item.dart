import 'lamina.dart';

class ScanHistoryItem {
  final int id;
  final int usuarioId;
  final String laminaId;
  final String estado;
  final int cantidadRepetidas;
  final String? contenidoQr;
  final DateTime fechaEscaneo;
  final Lamina? lamina;

  const ScanHistoryItem({
    required this.id,
    required this.usuarioId,
    required this.laminaId,
    required this.estado,
    required this.cantidadRepetidas,
    this.contenidoQr,
    required this.fechaEscaneo,
    this.lamina,
  });

  bool get esNueva => estado == 'nueva';

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) =>
      ScanHistoryItem(
        id: json['id'] as int,
        usuarioId: json['usuario_id'] as int,
        laminaId: json['lamina_id'] as String,
        estado: json['estado'] as String? ?? 'nueva',
        cantidadRepetidas: json['cantidad_repetidas'] as int? ?? 0,
        contenidoQr: json['contenido_qr'] as String?,
        fechaEscaneo: DateTime.parse(json['fecha_escaneo'] as String),
        lamina: json['lamina'] != null
            ? Lamina.fromJson(json['lamina'] as Map<String, dynamic>)
            : null,
      );
}
