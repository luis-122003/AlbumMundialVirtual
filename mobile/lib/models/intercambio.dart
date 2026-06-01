class IntercambioLamina {
  final int id;
  final int intercambioId;
  final String laminaId;
  final String direccion;
  final String? nombreSticker;
  final String? iso3;
  final String? fotoUrl;
  final bool? esEspecial;
  final String? posicion;

  const IntercambioLamina({
    required this.id,
    required this.intercambioId,
    required this.laminaId,
    required this.direccion,
    this.nombreSticker,
    this.iso3,
    this.fotoUrl,
    this.esEspecial,
    this.posicion,
  });

  factory IntercambioLamina.fromJson(Map<String, dynamic> json) =>
      IntercambioLamina(
        id: json['id'] as int,
        intercambioId: json['intercambio_id'] as int,
        laminaId: json['lamina_id'] as String,
        direccion: json['direccion'] as String,
        nombreSticker: json['nombre_sticker'] as String?,
        iso3: json['iso3'] as String?,
        fotoUrl: json['foto_url'] as String?,
        esEspecial: json['es_especial'] as bool?,
        posicion: json['posicion'] as String?,
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
  final DateTime? updatedAt;
  final List<IntercambioLamina>? laminas;
  final String? emisorNombre;
  final String? emisorEmail;
  final String? receptorNombre;
  final String? receptorEmail;

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
    this.updatedAt,
    this.laminas,
    this.emisorNombre,
    this.emisorEmail,
    this.receptorNombre,
    this.receptorEmail,
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
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
        laminas: json['laminas'] != null
            ? (json['laminas'] as List)
                .map((l) => IntercambioLamina.fromJson(l as Map<String, dynamic>))
                .toList()
            : null,
        emisorNombre: json['emisor_nombre'] as String?,
        emisorEmail: json['emisor_email'] as String?,
        receptorNombre: json['receptor_nombre'] as String?,
        receptorEmail: json['receptor_email'] as String?,
      );
}

class UsuarioBusqueda {
  final int id;
  final String nombre;
  final String email;
  final String? ciudad;
  final String? pais;

  const UsuarioBusqueda({
    required this.id,
    required this.nombre,
    required this.email,
    this.ciudad,
    this.pais,
  });

  factory UsuarioBusqueda.fromJson(Map<String, dynamic> json) => UsuarioBusqueda(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        email: json['email'] as String,
        ciudad: json['ciudad'] as String?,
        pais: json['pais'] as String?,
      );
}

class OfertaUsuario {
  final int id;
  final String nombre;
  final String email;
  final String? ciudad;
  final String? pais;
  final int totalRepetidas;
  final int tieneParaMi;
  final int necesitaDeMi;

  const OfertaUsuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.ciudad,
    this.pais,
    required this.totalRepetidas,
    required this.tieneParaMi,
    required this.necesitaDeMi,
  });

  factory OfertaUsuario.fromJson(Map<String, dynamic> json) => OfertaUsuario(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        email: json['email'] as String,
        ciudad: json['ciudad'] as String?,
        pais: json['pais'] as String?,
        totalRepetidas: json['total_repetidas'] as int? ?? 0,
        tieneParaMi: json['tiene_para_mi'] as int? ?? 0,
        necesitaDeMi: json['necesita_de_mi'] as int? ?? 0,
      );
}

class LaminaComparacion {
  final String laminaId;
  final int cantidadRepetidas;
  final String nombreSticker;
  final String? iso3;
  final bool esEspecial;
  final String? posicion;

  const LaminaComparacion({
    required this.laminaId,
    required this.cantidadRepetidas,
    required this.nombreSticker,
    this.iso3,
    required this.esEspecial,
    this.posicion,
  });

  factory LaminaComparacion.fromJson(Map<String, dynamic> json) =>
      LaminaComparacion(
        laminaId: json['lamina_id'] as String,
        cantidadRepetidas: json['cantidad_repetidas'] as int? ?? 0,
        nombreSticker: json['nombre_sticker'] as String,
        iso3: json['iso3'] as String?,
        esEspecial: json['es_especial'] as bool? ?? false,
        posicion: json['posicion'] as String?,
      );
}

class ComparacionResult {
  final UsuarioBusqueda otroUsuario;
  final List<LaminaComparacion> yoTengoElOtroNecesita;
  final List<LaminaComparacion> otroTieneYoNecesito;
  final int matches;

  const ComparacionResult({
    required this.otroUsuario,
    required this.yoTengoElOtroNecesita,
    required this.otroTieneYoNecesito,
    required this.matches,
  });

  factory ComparacionResult.fromJson(Map<String, dynamic> json) =>
      ComparacionResult(
        otroUsuario: UsuarioBusqueda.fromJson(
            json['otro_usuario'] as Map<String, dynamic>),
        yoTengoElOtroNecesita: (json['yo_tengo_el_otro_necesita'] as List)
            .map((e) => LaminaComparacion.fromJson(e as Map<String, dynamic>))
            .toList(),
        otroTieneYoNecesito: (json['otro_tiene_yo_necesito'] as List)
            .map((e) => LaminaComparacion.fromJson(e as Map<String, dynamic>))
            .toList(),
        matches: json['matches'] as int? ?? 0,
      );
}
