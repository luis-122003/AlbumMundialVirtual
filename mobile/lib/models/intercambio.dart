class IntercambioLamina {
  final int id;
  final int intercambioId;
  final String laminaId;
  final String direccion;

  const IntercambioLamina({
    required this.id,
    required this.intercambioId,
    required this.laminaId,
    required this.direccion,
  });

  factory IntercambioLamina.fromJson(Map<String, dynamic> json) =>
      IntercambioLamina(
        id: json['id'] as int,
        intercambioId: json['intercambio_id'] as int,
        laminaId: json['lamina_id'] as String,
        direccion: json['direccion'] as String,
      );
}

class Intercambio {
  final int id;
  final int usuarioEmisorId;
  final int usuarioReceptorId;
  final String tipo;
  final String estado;
  final double? puntoEncuentroLat;
  final double? puntoEncuentroLng;
  final String? puntoEncuentroDesc;
  final DateTime? fechaEncuentro;
  final String? metodoEnvio;
  final DateTime createdAt;
  final List<IntercambioLamina>? laminas;

  const Intercambio({
    required this.id,
    required this.usuarioEmisorId,
    required this.usuarioReceptorId,
    required this.tipo,
    required this.estado,
    this.puntoEncuentroLat,
    this.puntoEncuentroLng,
    this.puntoEncuentroDesc,
    this.fechaEncuentro,
    this.metodoEnvio,
    required this.createdAt,
    this.laminas,
  });

  factory Intercambio.fromJson(Map<String, dynamic> json) => Intercambio(
        id: json['id'] as int,
        usuarioEmisorId: json['usuario_emisor_id'] as int,
        usuarioReceptorId: json['usuario_receptor_id'] as int,
        tipo: json['tipo'] as String,
        estado: json['estado'] as String,
        puntoEncuentroLat: (json['punto_encuentro_lat'] as num?)?.toDouble(),
        puntoEncuentroLng: (json['punto_encuentro_lng'] as num?)?.toDouble(),
        puntoEncuentroDesc: json['punto_encuentro_desc'] as String?,
        fechaEncuentro: json['fecha_encuentro'] != null
            ? DateTime.tryParse(json['fecha_encuentro'] as String)
            : null,
        metodoEnvio: json['metodo_envio'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        laminas: json['laminas'] != null
            ? (json['laminas'] as List)
                .map((l) =>
                    IntercambioLamina.fromJson(l as Map<String, dynamic>))
                .toList()
            : null,
      );
}
