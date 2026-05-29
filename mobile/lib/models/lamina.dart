class Lamina {
  final String id;
  final String nombreSticker;
  final DateTime? fechaNacimiento;
  final int? estaturaCm;
  final int? pesoKg;
  final String? equipoActual;
  final bool esEspecial;
  final String? fotoUrl;
  final String iso3;
  final String? posicion;

  const Lamina({
    required this.id,
    required this.nombreSticker,
    this.fechaNacimiento,
    this.estaturaCm,
    this.pesoKg,
    this.equipoActual,
    required this.esEspecial,
    this.fotoUrl,
    required this.iso3,
    this.posicion,
  });

  factory Lamina.fromJson(Map<String, dynamic> json) => Lamina(
        id: json['id'] as String,
        nombreSticker: json['nombre_sticker'] as String,
        fechaNacimiento: json['fecha_nacimiento'] != null
            ? DateTime.tryParse(json['fecha_nacimiento'] as String)
            : null,
        estaturaCm: json['estatura_cm'] as int?,
        pesoKg: json['peso_kg'] as int?,
        equipoActual: json['equipo_actual'] as String?,
        esEspecial: json['es_especial'] as bool? ?? false,
        fotoUrl: json['foto_url'] as String?,
        iso3: json['iso3'] as String,
        posicion: json['posicion'] as String?,
      );

  int get numero {
    if (id.startsWith(iso3)) {
      return int.tryParse(id.substring(iso3.length)) ?? 0;
    }
    final match = RegExp(r'(\d+)$').firstMatch(id);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  bool get esEscudo => numero == 1 || posicion?.toUpperCase() == 'ESCUDO';

  bool get esFotoEquipo => numero == 13 || posicion?.toUpperCase() == 'EQUIPO';

  String get tipoVisual {
    if (esEscudo) return 'Escudo';
    if (esFotoEquipo) return 'Equipo';
    return posicion ?? 'Jugador';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre_sticker': nombreSticker,
        'es_especial': esEspecial,
        'iso3': iso3,
        if (posicion != null) 'posicion': posicion,
      };
}
