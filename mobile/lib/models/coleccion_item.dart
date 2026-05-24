import 'lamina.dart';

class ColeccionItem {
  final int id;
  final int usuarioId;
  final String laminaId;
  final bool pegada;
  final int cantidadRepetidas;
  final DateTime fechaObtenida;
  final Lamina? lamina;

  const ColeccionItem({
    required this.id,
    required this.usuarioId,
    required this.laminaId,
    required this.pegada,
    required this.cantidadRepetidas,
    required this.fechaObtenida,
    this.lamina,
  });

  factory ColeccionItem.fromJson(Map<String, dynamic> json) => ColeccionItem(
        id: json['id'] as int,
        usuarioId: json['usuario_id'] as int,
        laminaId: json['lamina_id'] as String,
        pegada: json['pegada'] as bool? ?? true,
        cantidadRepetidas: json['cantidad_repetidas'] as int? ?? 0,
        fechaObtenida: DateTime.parse(json['fecha_obtenida'] as String),
        lamina: json['lamina'] != null
            ? Lamina.fromJson(json['lamina'] as Map<String, dynamic>)
            : null,
      );
}
