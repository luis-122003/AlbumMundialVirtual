import 'package:flutter/foundation.dart';
import '../models/intercambio.dart';
import '../services/api_service.dart';

class IntercambioController extends ChangeNotifier {
  List<Intercambio> _intercambios = [];
  List<OfertaUsuario> _ofertas = [];
  List<UsuarioBusqueda> _resultadosBusqueda = [];
  ComparacionResult? _comparacion;
  Map<String, dynamic>? _estadisticas;
  bool _loading = false;
  bool _loadingBusqueda = false;
  String? _error;

  List<Intercambio> get intercambios => _intercambios;
  List<Intercambio> get activos => _intercambios
      .where((i) => ['pendiente', 'aceptado'].contains(i.estado))
      .toList();
  List<Intercambio> get historial => _intercambios
      .where((i) => ['completado', 'rechazado', 'cancelado'].contains(i.estado))
      .toList();
  List<OfertaUsuario> get ofertas => _ofertas;
  List<UsuarioBusqueda> get resultadosBusqueda => _resultadosBusqueda;
  ComparacionResult? get comparacion => _comparacion;
  Map<String, dynamic>? get estadisticas => _estadisticas;
  bool get loading => _loading;
  bool get loadingBusqueda => _loadingBusqueda;
  String? get error => _error;

  Future<void> cargarIntercambios() async {
    _setLoading(true);
    try {
      final data = await ApiService.get('/intercambios', auth: true) as List;
      _intercambios = data
          .map((e) => Intercambio.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarOfertas() async {
    _setLoading(true);
    try {
      final data = await ApiService.get('/intercambios/ofertas', auth: true) as List;
      _ofertas = data
          .map((e) => OfertaUsuario.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> buscarUsuarios(String q) async {
    if (q.trim().length < 2) {
      _resultadosBusqueda = [];
      notifyListeners();
      return;
    }
    _loadingBusqueda = true;
    notifyListeners();
    try {
      final data = await ApiService.get(
        '/usuarios/buscar?q=${Uri.encodeComponent(q.trim())}',
        auth: true,
      ) as List;
      _resultadosBusqueda = data
          .map((e) => UsuarioBusqueda.fromJson(e as Map<String, dynamic>))
          .toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _loadingBusqueda = false;
      notifyListeners();
    }
  }

  Future<bool> compararColecciones(int userId) async {
    _setLoading(true);
    try {
      final data = await ApiService.get(
        '/intercambios/comparar/$userId',
        auth: true,
      ) as Map<String, dynamic>;
      _comparacion = ComparacionResult.fromJson(data);
      _error = null;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Intercambio?> crearIntercambio({
    required int receptorId,
    required String tipo,
    required List<String> laminasEmisor,
    required List<String> laminasReceptor,
  }) async {
    _setLoading(true);
    try {
      final data = await ApiService.post(
        '/intercambios',
        {
          'receptor_id': receptorId,
          'tipo': tipo,
          'laminas_emisor': laminasEmisor,
          'laminas_receptor': laminasReceptor,
        },
        auth: true,
      ) as Map<String, dynamic>;
      final intercambio = Intercambio.fromJson(data);
      _intercambios.insert(0, intercambio);
      _error = null;
      notifyListeners();
      return intercambio;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> aceptarIntercambio(int id) async {
    return _accionIntercambio('/intercambios/$id/aceptar');
  }

  Future<bool> rechazarIntercambio(int id) async {
    return _accionIntercambio('/intercambios/$id/rechazar');
  }

  Future<bool> completarIntercambio(int id) async {
    return _accionIntercambio('/intercambios/$id/completar');
  }

  Future<bool> coordinarEncuentro(
    int id, {
    double? lat,
    double? lng,
    String? descripcion,
    String? fechaEncuentro,
    String metodoEnvio = 'encuentro',
  }) async {
    _setLoading(true);
    try {
      final data = await ApiService.put(
        '/intercambios/$id/coordinar',
        {
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          if (descripcion != null) 'descripcion': descripcion,
          if (fechaEncuentro != null) 'fecha_encuentro': fechaEncuentro,
          'metodo_envio': metodoEnvio,
        },
        auth: true,
      ) as Map<String, dynamic>;
      _updateIntercambioLocal(Intercambio.fromJson(data));
      _error = null;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarEstadisticas() async {
    try {
      final data = await ApiService.get('/intercambios/estadisticas', auth: true)
          as Map<String, dynamic>;
      _estadisticas = data;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
    }
  }

  void limpiarBusqueda() {
    _resultadosBusqueda = [];
    notifyListeners();
  }

  void limpiarComparacion() {
    _comparacion = null;
    notifyListeners();
  }

  void reset() {
    _intercambios = [];
    _ofertas = [];
    _resultadosBusqueda = [];
    _comparacion = null;
    _estadisticas = null;
    _error = null;
    notifyListeners();
  }

  Future<bool> _accionIntercambio(String path) async {
    _setLoading(true);
    try {
      final data = await ApiService.put(path, {}, auth: true) as Map<String, dynamic>;
      _updateIntercambioLocal(Intercambio.fromJson(data));
      _error = null;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _updateIntercambioLocal(Intercambio updated) {
    final idx = _intercambios.indexWhere((i) => i.id == updated.id);
    if (idx >= 0) {
      _intercambios[idx] = updated;
    } else {
      _intercambios.insert(0, updated);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
