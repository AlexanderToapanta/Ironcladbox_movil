import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/api_config.dart';

/// Servicio base para todas las peticiones HTTP
/// Centraliza la configuración de Dio y manejo de tokens
class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  late Dio _dio;
  final _secureStorage = const FlutterSecureStorage();
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal() {
    _initializeDio();
  }
  
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: ApiConfig.sendTimeout),
        headers: ApiConfig.defaultHeaders,
      ),
    );
    
    // Agregar interceptor para tokens JWT
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Manejar errores 401 (token expirado)
          if (error.response?.statusCode == 401) {
            // Limpiar token y redirigir a login
            _secureStorage.delete(key: 'jwt_token');
          }
          return handler.next(error);
        },
      ),
    );
  }
  
  /// GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }
  
  /// POST request
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }
  
  /// PUT request
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }
  
  /// DELETE request
  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
  
  /// Manejo centralizado de excepciones HTTP
  String _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tiempo de conexión agotado';
      case DioExceptionType.sendTimeout:
        return 'Tiempo de envío agotado';
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de respuesta agotado';
      case DioExceptionType.badResponse:
        return 'Error del servidor: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Solicitud cancelada';
      case DioExceptionType.connectionError:
        return 'Error de conexión. Verifica tu conexión a internet.';
      case DioExceptionType.unknown:
        return 'Error desconocido: ${error.message}';
      default:
        return 'Error inesperado';
    }
  }
  
  /// Establecer token JWT
  Future<void> setToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }

  Future<void> setRole(String role) async {
    await _secureStorage.write(key: 'user_role', value: role);
  }
  
  /// Obtener token JWT
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<String?> getRole() async {
    return await _secureStorage.read(key: 'user_role');
  }
  
  /// Limpiar token
  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'jwt_token');
  }

  Future<void> clearRole() async {
    await _secureStorage.delete(key: 'user_role');
  }
  
  Dio getDio() => _dio;
}
