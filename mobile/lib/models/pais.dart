class Pais {
  final String iso3;
  final String pais;
  final String grupo;

  const Pais({required this.iso3, required this.pais, required this.grupo});

  factory Pais.fromJson(Map<String, dynamic> json) => Pais(
        iso3: json['iso3'] as String,
        pais: json['pais'] as String,
        grupo: json['grupo'] as String,
      );

  Map<String, dynamic> toJson() => {'iso3': iso3, 'pais': pais, 'grupo': grupo};
}
