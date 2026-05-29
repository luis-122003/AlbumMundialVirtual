import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class ApiService {
  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await StorageService.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static dynamic _handle(http.Response res) {
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    if (res.statusCode == 401) {
      StorageService.clearToken();
      throw ApiException(401, 'Sesión expirada, vuelve a iniciar sesión');
    }
    final msg = (data is Map && data['error'] != null)
        ? data['error'] as String
        : 'Error del servidor';
    throw ApiException(res.statusCode, msg);
  }

  static Future<dynamic> get(String path, {bool auth = false}) async {
    try {
      final res = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: await _headers(auth: auth),
          )
          .timeout(const Duration(seconds: 15));
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, _networkMessage(e));
    }
  }

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, _networkMessage(e));
    }
  }

  static Future<dynamic> put(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    try {
      final res = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _handle(res);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(0, _networkMessage(e));
    }
  }

  static String _networkMessage(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('timeout')) {
      return 'Tiempo de espera agotado. Verifica el servidor.';
    }
    if (s.contains('connection refused') || s.contains('failed host lookup')) {
      return 'No se pudo conectar al servidor. Verifica que el backend esté corriendo.';
    }
    return 'Error de red: $e';
  }
}
