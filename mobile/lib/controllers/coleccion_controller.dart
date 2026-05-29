import 'package:flutter/foundation.dart';

import '../models/coleccion_item.dart';
import '../models/lamina.dart';
import '../models/scan_history_item.dart';
import '../services/api_service.dart';

class ProgresoData {
  final int totalLaminas;
  final int laminasObtenidas;
  final double porcentaje;
  final List<Map<String, dynamic>> porPais;

  const ProgresoData({
    required this.totalLaminas,
    required this.laminasObtenidas,
    required this.porcentaje,
    required this.porPais,
  });

  factory ProgresoData.fromJson(Map<String, dynamic> json) => ProgresoData(
        totalLaminas: json['total_laminas'] as int? ?? 0,
        laminasObtenidas: json['laminas_obtenidas'] as int? ?? 0,
        porcentaje: (json['porcentaje'] as num?)?.toDouble() ?? 0.0,
        porPais: (json['por_pais'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [],
      );
}

class ColeccionController extends ChangeNotifier {
  List<ColeccionItem> _coleccion = [];
  List<ColeccionItem> _repetidas = [];
  List<Lamina> _faltantes = [];
  List<ScanHistoryItem> _historial = [];
  ProgresoData? _progreso;
  bool _loading = false;
  String? _error;

  List<ColeccionItem> get coleccion => _coleccion;
  List<ColeccionItem> get repetidas => _repetidas;
  List<Lamina> get faltantes => _faltantes;
  List<ScanHistoryItem> get historial => _historial;
  ProgresoData? get progreso => _progreso;
  bool get loading => _loading;
  String? get error => _error;

  int get totalRepetidas =>
      _repetidas.fold(0, (sum, item) => sum + item.cantidadRepetidas);

  Set<String> get idsObtenidas =>
      _coleccion.map((item) => item.laminaId).toSet();

  Map<String, ColeccionItem> get porLamina => {
        for (final item in _coleccion) item.laminaId: item,
      };

  Future<void> cargarResumen() async {
    _setLoading(true);
    try {
      final responses = await Future.wait<dynamic>([
        ApiService.get('/coleccion', auth: true),
        ApiService.get('/coleccion/repetidas', auth: true),
        ApiService.get('/coleccion/faltantes', auth: true),
        ApiService.get('/coleccion/progreso', auth: true),
        ApiService.get('/coleccion/historial', auth: true),
      ]);

      _coleccion = (responses[0] as List)
          .map((e) => ColeccionItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _repetidas = (responses[1] as List)
          .map((e) => ColeccionItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _faltantes = (responses[2] as List)
          .map((e) => Lamina.fromJson(e as Map<String, dynamic>))
          .toList();
      _progreso = ProgresoData.fromJson(responses[3] as Map<String, dynamic>);
      _historial = (responses[4] as List)
          .map((e) => ScanHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarColeccion() async {
    _setLoading(true);
    try {
      final data = await ApiService.get('/coleccion', auth: true) as List;
      _coleccion = data
          .map((e) => ColeccionItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarProgreso() async {
    try {
      final data = await ApiService.get('/coleccion/progreso', auth: true)
          as Map<String, dynamic>;
      _progreso = ProgresoData.fromJson(data);
      _error = null;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<void> cargarRepetidas() async {
    _setLoading(true);
    try {
      final data =
          await ApiService.get('/coleccion/repetidas', auth: true) as List;
      _repetidas = data
          .map((e) => ColeccionItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarFaltantes() async {
    _setLoading(true);
    try {
      final data =
          await ApiService.get('/coleccion/faltantes', auth: true) as List;
      _faltantes =
          data.map((e) => Lamina.fromJson(e as Map<String, dynamic>)).toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarHistorial() async {
    try {
      final data =
          await ApiService.get('/coleccion/historial', auth: true) as List;
      _historial = data
          .map((e) => ScanHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> escanearLamina(
    String equipoIso3,
    int laminaNumero, {
    String? contenidoQr,
  }) async {
    _error = null;
    try {
      final data = await ApiService.post(
        '/coleccion/escanear',
        {
          'equipo_iso3': equipoIso3,
          'equipo_id': equipoIso3,
          'lamina_numero': laminaNumero,
          if (contenidoQr != null) 'contenido_qr': contenidoQr,
        },
        auth: true,
      ) as Map<String, dynamic>;
      await cargarResumen();
      return data;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  void reset() {
    _coleccion = [];
    _repetidas = [];
    _faltantes = [];
    _historial = [];
    _progreso = null;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
