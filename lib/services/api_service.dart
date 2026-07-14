import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/api_config.dart';
import 'cache_service.dart';
import 'sync_queue_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  late Dio _dio;
  final _secureStorage = const FlutterSecureStorage();
  final CacheService _cache = CacheService();
  final SyncQueueService _queue = SyncQueueService();
  bool _isOffline = false;
  bool _lastWriteQueued = false;

  bool _sessionExpiredFired = false;

  final _sessionExpiredController = StreamController<void>.broadcast();
  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  bool get isOffline => _isOffline;
  bool get lastWriteQueued => _lastWriteQueued;
  int get pendingCount => _queue.pendingCount;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initializeDio();
    _cache.init();
    _queue.init();
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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (!_sessionExpiredFired && response.data is Map && response.data['sessionExpired'] == true) {
            _handleSessionExpired();
          }
          if (response.requestOptions.method.toUpperCase() == 'GET') {
            final key = response.requestOptions.path.replaceAll('/', '_');
            _cache.save(key, response.data);
          }
          _isOffline = false;
          return handler.next(response);
        },
        onError: (error, handler) {
          if (!_sessionExpiredFired && error.response?.statusCode == 401) {
            _handleSessionExpired();
          } else if (!_sessionExpiredFired && error.response?.statusCode == 403) {
            final data = error.response?.data;
            if (data is Map && data['sessionExpired'] == true) {
              _handleSessionExpired();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  void _handleSessionExpired() {
    if (_sessionExpiredFired) return;
    _sessionExpiredFired = true;
    _secureStorage.delete(key: 'jwt_token');
    _secureStorage.delete(key: 'user_role');
    _cache.clear();
    _queue.clear();
    _sessionExpiredController.add(null);
  }

  void resetSessionExpiredFlag() {
    _sessionExpiredFired = false;
  }

  bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout;
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      _isOffline = false;
      return response;
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        final key = path.replaceAll('/', '_');
        final cached = _cache.get(key);
        if (cached != null) {
          _isOffline = true;
          return Response(
            requestOptions: RequestOptions(path: path),
            statusCode: 200,
            data: cached,
            extra: {'fromCache': true, 'cacheAgeMin': _cache.getAgeMinutes(key)},
          );
        }
      }
      _isOffline = _isConnectionError(e);
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      _isOffline = false;
      _drainQueue();
      return response;
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        _isOffline = true;
        _lastWriteQueued = true;
        _queue.enqueue('POST', path, body: data is Map<String, dynamic> ? data : null);
        return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 201,
          data: {'success': true, 'message': 'Guardado localmente. Se sincronizara al reconectar.', 'queued': true},
          extra: {'queued': true},
        );
      }
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      _isOffline = false;
      _drainQueue();
      return response;
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        _isOffline = true;
        _lastWriteQueued = true;
        _queue.enqueue('PUT', path, body: data is Map<String, dynamic> ? data : null);
        return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {'success': true, 'message': 'Guardado localmente. Se sincronizara al reconectar.', 'queued': true},
          extra: {'queued': true},
        );
      }
      rethrow;
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      _isOffline = false;
      return response;
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        _isOffline = true;
        _lastWriteQueued = true;
        _queue.enqueue(
          'PATCH',
          path,
          body: data is Map<String, dynamic> ? data : null,
        );
        return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {
            'success': true,
            'message': 'Guardado localmente. Se sincronizara al reconectar.',
            'queued': true,
          },
          extra: {'queued': true},
        );
      }
      rethrow;
    }
  }

  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      _isOffline = false;
      _drainQueue();
      return response;
    } on DioException catch (e) {
      if (_isConnectionError(e)) {
        _isOffline = true;
        _lastWriteQueued = true;
        _queue.enqueue('DELETE', path);
        return Response(
          requestOptions: RequestOptions(path: path),
          statusCode: 200,
          data: {'success': true, 'message': 'Eliminado localmente. Se sincronizara al reconectar.', 'queued': true},
          extra: {'queued': true},
        );
      }
      rethrow;
    }
  }

  void _drainQueue() {
    drainQueue();
  }

  Future<void> drainQueue() async {
    await _queue.processQueue((method, path, body) async {
      if (method == 'POST') {
        await _dio.post(path, data: body);
      } else if (method == 'PUT') {
        await _dio.put(path, data: body);
      } else if (method == 'PATCH') {
        await _dio.patch(path, data: body);
      } else if (method == 'DELETE') {
        await _dio.delete(path);
      }
    });
  }

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: 'jwt_token', value: token);
  }

  Future<void> setRole(String role) async {
    await _secureStorage.write(key: 'user_role', value: role);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  Future<String?> getRole() async {
    return await _secureStorage.read(key: 'user_role');
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'jwt_token');
  }

  Future<void> clearRole() async {
    await _secureStorage.delete(key: 'user_role');
  }

  Dio getDio() => _dio;

  void forceOnline() {
    _isOffline = false;
    _lastWriteQueued = false;
  }

  void clearLastWriteFlag() {
    _lastWriteQueued = false;
  }
}
