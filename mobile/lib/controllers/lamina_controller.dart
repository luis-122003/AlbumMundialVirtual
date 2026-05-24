import 'package:flutter/foundation.dart';
import '../models/lamina.dart';
import '../models/pais.dart';
import '../services/api_service.dart';

class LaminaController extends ChangeNotifier {
  List<Lamina> _laminas = [];
  List<Pais> _paises = [];
  bool _loading = false;
  String? _error;

  List<Lamina> get laminas => _laminas;
  List<Pais> get paises => _paises;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> cargarPaises() async {
    _setLoading(true);
    try {
      final data = await ApiService.get('/paises') as List;
      _paises =
          data.map((e) => Pais.fromJson(e as Map<String, dynamic>)).toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cargarLaminas() async {
    _setLoading(true);
    try {
      final data = await ApiService.get('/laminas') as List;
      _laminas =
          data.map((e) => Lamina.fromJson(e as Map<String, dynamic>)).toList();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
