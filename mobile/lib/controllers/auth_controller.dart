import 'package:flutter/foundation.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthController extends ChangeNotifier {
  Usuario? _user;
  bool _loading = false;
  String? _error;

  Usuario? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> tryAutoLogin() async {
    final token = await StorageService.getToken();
    if (token == null) return;
    try {
      final data = await ApiService.get('/auth/profile', auth: true);
      _user = Usuario.fromJson(data as Map<String, dynamic>);
      notifyListeners();
    } on ApiException {
      await StorageService.clearToken();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      final data = await ApiService.post(
        '/auth/login',
        {'email': email.trim(), 'password': password},
      ) as Map<String, dynamic>;
      await StorageService.saveToken(data['token'] as String);
      _user = Usuario.fromJson(data['usuario'] as Map<String, dynamic>);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(
    String nombre,
    String email,
    String password, {
    String? ciudad,
    String? pais,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final body = <String, dynamic>{
        'nombre': nombre.trim(),
        'email': email.trim(),
        'password': password,
        if (ciudad != null && ciudad.isNotEmpty) 'ciudad': ciudad.trim(),
        if (pais != null && pais.isNotEmpty) 'pais': pais.trim(),
      };
      final data =
          await ApiService.post('/auth/register', body) as Map<String, dynamic>;
      await StorageService.saveToken(data['token'] as String);
      _user = Usuario.fromJson(data['usuario'] as Map<String, dynamic>);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    _setLoading(true);
    _error = null;
    try {
      final data =
          await ApiService.put('/auth/profile', fields, auth: true)
              as Map<String, dynamic>;
      _user = Usuario.fromJson(data);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await StorageService.clearToken();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
