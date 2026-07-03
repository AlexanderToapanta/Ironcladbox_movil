import 'package:dio/dio.dart';
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
    } on DioException catch (e) {
      // Extraer mensaje de error del backend (para errores 403 de membresía, etc.)
      final dynamic responseData = e.response?.data;
      if (responseData is Map && responseData.containsKey('message')) {
        throw Exception(responseData['message']);
      }
      
      // Fallback a manejo genérico
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        throw Exception('No se pudo conectar con el servidor. Verifica tu red.');
      }
      
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciales incorrectas');
      }

      if (e.response?.statusCode == 403) {
        throw Exception('Acceso denegado. Revisa tu membresía.');
      }

      throw Exception('Error del servidor: ${e.response?.statusCode ?? "desconocido"}');
    } catch (e) {
      rethrow;
    }
  }
  
  /// Registro - crea nueva cuenta
  Future<String> register({
    required String email,
    required String password,
    required String name,
    String? lastName,
    String? phone,
    String? address,
    DateTime? birthDate,
    int? membershipId,
    double? weight,
    double? height,
    String? role,
  }) async {
    final String path = ApiConfig.registerEndpoint;
    final String fullUrl = '${ApiConfig.baseUrl}$path';
    
    final Map<String, dynamic> body = {
      'nombre': name,
      'apellido': lastName ?? '',
      'email': email,
      'telefono': phone ?? '',
      'direccion': address ?? '',
      'fecha_nacimiento': birthDate?.toIso8601String().split('T').first,
      'password': password,
      'rol': role ?? 'ATLETA',
      'peso': weight ?? 0,
      'altura': height ?? 0,
      'id_membresia': membershipId ?? 0,
    };

    print('========== REGISTER ==========');
    print('URL: $fullUrl');
    print('HEADERS: ${ApiConfig.defaultHeaders}');
    print('BODY: $body');

    try {
      final response = await _apiService.post(
        path,
        data: body,
      );

      print('STATUS: ${response.statusCode}');
      print('RESPONSE: ${response.data}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final String message = response.data['message'] ?? 'Registro exitoso';
        return message;
      } else {
        throw Exception('Error en registro: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      print('STATUS: ${e.response?.statusCode}');
      print('BODY: ${e.response?.data}');
      print('MESSAGE: ${e.message}');
      
      final dynamic responseData = e.response?.data;
      if (responseData is Map && responseData.containsKey('message')) {
        throw Exception(responseData['message']);
      }
      
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        throw Exception('No se pudo conectar con el servidor. Verifica tu red.');
      }

      throw Exception('Error del servidor: ${e.response?.statusCode ?? "desconocido"}');
    } catch (e) {
      print('NON-DIO ERROR: $e');
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

  /// Obtener perfil autenticado
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.profileEndpoint);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final nested = data['data'];
        if (nested is Map<String, dynamic>) {
          return nested;
        }
        final result = data['result'];
        if (result is Map<String, dynamic>) {
          return result;
        }
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtener rol actual almacenado
  Future<String?> getRole() async {
    return await _apiService.getRole();
  }
}
