class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String? fotoPerfilUrl;
  final String? ciudad;
  final String? pais;
  final DateTime createdAt;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.fotoPerfilUrl,
    this.ciudad,
    this.pais,
    required this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        email: json['email'] as String,
        fotoPerfilUrl: json['foto_perfil_url'] as String?,
        ciudad: json['ciudad'] as String?,
        pais: json['pais'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
