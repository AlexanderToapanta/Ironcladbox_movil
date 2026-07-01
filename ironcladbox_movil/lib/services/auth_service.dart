import 'api_service.dart';
import '../core/config/api_config.dart';
import '../models/app_models.dart';

/// Servicio de autenticación
/// Maneja login, registro y verificación de tokens
class AuthService {
  final ApiService _apiService = ApiService();

  String _extractToken(dynamic data, {Map<String, List<String>>? headers}) {
    if (data is! Map<String, dynamic>) {
      throw Exception('Respuesta de autenticacion invalida.');
    }

    final nested = (data['data'] is Map<String, dynamic>)
        ? data['data'] as Map<String, dynamic>
        : (data['result'] is Map<String, dynamic>)
            ? data['result'] as Map<String, dynamic>
            : <String, dynamic>{};

    final dynamic rawToken = data['token'] ??
        data['accessToken'] ??
        data['access_token'] ??
        nested['token'] ??
        nested['accessToken'] ??
        nested['access_token'];

    var token = rawToken?.toString() ?? '';

    if ((token.isEmpty || token.toLowerCase() == 'null') && headers != null) {
      final authValues = headers['authorization'] ?? headers['Authorization'];
      if (authValues != null && authValues.isNotEmpty) {
        final authHeader = authValues.first;
        if (authHeader.toLowerCase().startsWith('bearer ')) {
          token = authHeader.substring(7).trim();
        }
      }

      if (token.isEmpty || token.toLowerCase() == 'null') {
        final setCookie = headers['set-cookie'] ?? headers['Set-Cookie'];
        if (setCookie != null && setCookie.isNotEmpty) {
          final cookieText = setCookie.join(';');
          final match = RegExp(
            r'(?:token|jwt|access_token)=([^;]+)',
            caseSensitive: false,
          ).firstMatch(cookieText);
          if (match != null) {
            token = match.group(1)?.trim() ?? '';
          }
        }
      }
    }

    if (token.isEmpty || token.toLowerCase() == 'null') {
      throw Exception('El backend no envio un token valido.');
    }

    return token;
  }

  String _extractRole(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return 'athlete';
    }

    final nested = (data['data'] is Map<String, dynamic>)
      ? data['data'] as Map<String, dynamic>
      : (data['result'] is Map<String, dynamic>)
        ? data['result'] as Map<String, dynamic>
        : <String, dynamic>{};

    final dynamic rawRole =
      data['role'] ??
        data['rol'] ??
        nested['role'] ??
        nested['rol'] ??
        data['user']?['role'] ??
        data['user']?['rol'] ??
        nested['user']?['role'] ??
        nested['user']?['rol'];
    final role = rawRole?.toString().trim();

    if (role == null || role.isEmpty || role.toLowerCase() == 'null') {
      return 'athlete';
    }

    return role;
  }
  
  /// Login - retorna token JWT
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final token = _extractToken(
          response.data,
          headers: response.headers.map,
        );
        final role = _extractRole(response.data);
        await _apiService.setToken(token);
        await _apiService.setRole(role);
        return AuthSession(token: token, role: role);
      } else {
        throw Exception('Error en login: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Registro - crea nueva cuenta
  Future<AuthSession> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );
      
      if (response.statusCode == 201) {
        final token = _extractToken(
          response.data,
          headers: response.headers.map,
        );
        final role = _extractRole(response.data);
        await _apiService.setToken(token);
        await _apiService.setRole(role);
        return AuthSession(token: token, role: role);
      } else {
        throw Exception('Error en registro: ${response.statusMessage}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Verificar token - valida si el token es válido
  Future<bool> verifyToken() async {
    try {
      final token = await _apiService.getToken();
      if (token == null) return false;
      
      final response = await _apiService.get(ApiConfig.verifyTokenEndpoint);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Logout - elimina el token
  Future<void> logout() async {
    await _apiService.clearToken();
    await _apiService.clearRole();
  }
  
  /// Obtener token actual
  Future<String?> getToken() async {
    return await _apiService.getToken();
  }

  /// Obtener rol actual almacenado
  Future<String?> getRole() async {
    return await _apiService.getRole();
  }
}
