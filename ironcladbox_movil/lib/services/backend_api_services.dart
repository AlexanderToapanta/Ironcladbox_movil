import 'package:dio/dio.dart';

import '../core/config/api_config.dart';
import '../models/backend_api_models.dart';
import 'api_service.dart';

String _messageFromData(
  dynamic data, {
  String fallback = 'Operación completada',
}) {
  final map = normalizeApiMap(data);
  for (final key in const ['message', 'msg', 'mensaje', 'error']) {
    final value = map[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return fallback;
}

bool _isNotFound(Object error) {
  return error is DioException && error.response?.statusCode == 404;
}

Future<Response<dynamic>> _getWithFallback(
  ApiService api,
  List<String> paths, {
  Map<String, dynamic>? queryParameters,
}) async {
  for (var index = 0; index < paths.length; index++) {
    final path = paths[index];
    try {
      return await api.getDio().get(path, queryParameters: queryParameters);
    } catch (error) {
      if (_isNotFound(error) && index < paths.length - 1) {
        continue;
      }
      rethrow;
    }
  }

  throw StateError('No se pudo resolver ninguna ruta válida.');
}

Future<Response<dynamic>> _postWithFallback(
  ApiService api,
  List<String> paths, {
  dynamic data,
}) async {
  for (var index = 0; index < paths.length; index++) {
    final path = paths[index];
    try {
      return await api.getDio().post(path, data: data);
    } catch (error) {
      if (_isNotFound(error) && index < paths.length - 1) {
        continue;
      }
      rethrow;
    }
  }

  throw StateError('No se pudo resolver ninguna ruta válida.');
}

Future<Response<dynamic>> _putWithFallback(
  ApiService api,
  List<String> paths, {
  dynamic data,
}) async {
  for (var index = 0; index < paths.length; index++) {
    final path = paths[index];
    try {
      return await api.getDio().put(path, data: data);
    } catch (error) {
      if (_isNotFound(error) && index < paths.length - 1) {
        continue;
      }
      rethrow;
    }
  }

  throw StateError('No se pudo resolver ninguna ruta válida.');
}

Future<Response<dynamic>> _deleteWithFallback(
  ApiService api,
  List<String> paths,
) async {
  for (var index = 0; index < paths.length; index++) {
    final path = paths[index];
    try {
      return await api.getDio().delete(path);
    } catch (error) {
      if (_isNotFound(error) && index < paths.length - 1) {
        continue;
      }
      rethrow;
    }
  }

  throw StateError('No se pudo resolver ninguna ruta válida.');
}

List<String> _classPaths(String suffix) => [
      '${ApiConfig.clasesEndpoint}$suffix',
      '/api/clases$suffix',
      '/api/classes$suffix',
    ];

List<String> _wodPaths(String suffix) => [
      '${ApiConfig.wodsEndpoint}$suffix',
      '/api/wod$suffix',
    ];

class MembershipsService {
  final ApiService _api = ApiService();

  Future<List<MembershipDto>> getAll() async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/auth/memberships',
    );
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => MembershipDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<MembershipDto?> getById(int id) async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/admin/memberships/$id',
    );
    final data = asApiObject(response.data);
    return data.isEmpty ? null : MembershipDto.fromJson(data);
  }

  Future<MembershipDto> create(Map<String, dynamic> payload) async {
    final response = await _api.post(
      '${ApiConfig.baseUrl}/api/admin/memberships',
      data: payload,
    );
    return MembershipDto.fromJson(asApiObject(response.data));
  }

  Future<MembershipDto> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.baseUrl}/api/admin/memberships/$id',
      data: payload,
    );
    return MembershipDto.fromJson(asApiObject(response.data));
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.baseUrl}/api/admin/memberships/$id');
  }
}

class AthletesService {
  final ApiService _api = ApiService();

  Future<List<AthleteDto>> getAll() async {
    final response = await _api.get('${ApiConfig.baseUrl}/api/admin/athletes');
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => AthleteDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<AthleteDto?> getById(int id) async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/admin/athletes/$id',
    );
    final data = asApiObject(response.data);
    return data.isEmpty ? null : AthleteDto.fromJson(data);
  }

  Future<AthleteDto> create(Map<String, dynamic> payload) async {
    final response = await _api.post(
      '${ApiConfig.baseUrl}/api/admin/athletes',
      data: payload,
    );
    return AthleteDto.fromJson(asApiObject(response.data));
  }

  Future<AthleteDto> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.baseUrl}/api/admin/athletes/$id',
      data: payload,
    );
    return AthleteDto.fromJson(asApiObject(response.data));
  }

  Future<AthleteDto> updateMembership(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _api.put(
      '${ApiConfig.baseUrl}/api/admin/athletes/$id/membership',
      data: payload,
    );
    return AthleteDto.fromJson(asApiObject(response.data));
  }

  Future<AthleteDto> updateStatus(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.baseUrl}/api/admin/athletes/$id/status',
      data: payload,
    );
    return AthleteDto.fromJson(asApiObject(response.data));
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.baseUrl}/api/admin/athletes/$id');
  }

  Future<AthleteDto?> checkMembershipStatus() async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/members/check-membership',
    );
    final data = asApiObject(response.data);
    return data.isEmpty ? null : AthleteDto.fromJson(data);
  }

  Future<AthleteDto?> getMyMembership() async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/members/my-membership',
    );
    final data = asApiObject(response.data);
    return data.isEmpty ? null : AthleteDto.fromJson(data);
  }

  Future<AthleteDto> updateMyMembership(Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.baseUrl}/api/members/my-membership',
      data: payload,
    );
    return AthleteDto.fromJson(asApiObject(response.data));
  }

  Future<void> cancelMyMembership() async {
    await _api.delete('${ApiConfig.baseUrl}/api/members/my-membership');
  }

  Future<List<AthleteDto>> getExpiredMemberships() async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/admin/memberships/expired',
    );
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => AthleteDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<dynamic>> deactivateExpiredMemberships() async {
    final response = await _api.post(
      '${ApiConfig.baseUrl}/api/admin/memberships/deactivate-expired',
    );
    return asApiList(response.data);
  }

  Future<AthleteDto> assignMembership(Map<String, dynamic> payload) async {
    final response = await _api.post(
      '${ApiConfig.baseUrl}/api/admin/memberships/assign',
      data: payload,
    );
    return AthleteDto.fromJson(asApiObject(response.data));
  }
}

class TrainersService {
  final ApiService _api = ApiService();

  Future<List<TrainerDto>> getAll() async {
    final response = await _api.get('${ApiConfig.baseUrl}/api/trainers');
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => TrainerDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<TrainerDto?> getById(int id) async {
    final response = await _api.get('${ApiConfig.baseUrl}/api/trainers/$id');
    final data = asApiObject(response.data);
    return data.isEmpty ? null : TrainerDto.fromJson(data);
  }

  Future<List<TrainerDto>> getBySpecialty(String specialty) async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/trainers/specialty/$specialty',
    );
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => TrainerDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<TrainerDto> create(Map<String, dynamic> payload) async {
    final response = await _api.post(
      '${ApiConfig.baseUrl}/api/admin/trainers',
      data: payload,
    );
    return TrainerDto.fromJson(asApiObject(response.data));
  }

  Future<TrainerDto> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.baseUrl}/api/admin/trainers/$id',
      data: payload,
    );
    return TrainerDto.fromJson(asApiObject(response.data));
  }

  Future<TrainerDto> updateStatus(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.baseUrl}/api/admin/trainers/$id/status',
      data: payload,
    );
    return TrainerDto.fromJson(asApiObject(response.data));
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.baseUrl}/api/admin/trainers/$id');
  }

  Future<List<dynamic>> getMyClasses() async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/trainers/my-classes',
    );
    return asApiList(response.data);
  }

  Future<List<dynamic>> getMyWods() async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/trainers/my-wods',
    );
    return asApiList(response.data);
  }

  Future<List<dynamic>> getMyAthletes() async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/trainers/my-athletes',
    );
    return asApiList(response.data);
  }
}

class ClassesService {
  final ApiService _api = ApiService();

  Future<List<ClassDto>> getAll() async {
    final response = await _getWithFallback(_api, _classPaths(''));
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ClassDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ClassDto>> getAvailable() async {
    final response = await _getWithFallback(_api, _classPaths('/disponibles'));
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ClassDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ClassDto?> getById(int id) async {
    final response = await _getWithFallback(_api, _classPaths('/$id'));
    final data = asApiObject(response.data);
    return data.isEmpty ? null : ClassDto.fromJson(data);
  }

  Future<ClassDto> create(Map<String, dynamic> payload) async {
    final response = await _postWithFallback(
      _api,
      _classPaths(''),
      data: payload,
    );
    return ClassDto.fromJson(asApiObject(response.data));
  }

  Future<ClassDto> update(int id, Map<String, dynamic> payload) async {
    final response = await _putWithFallback(
      _api,
      _classPaths('/$id'),
      data: payload,
    );
    return ClassDto.fromJson(asApiObject(response.data));
  }

  Future<void> delete(int id) async {
    await _deleteWithFallback(_api, _classPaths('/$id'));
  }

  Future<List<dynamic>> getEnrolledStudents(int id) async {
    final response = await _getWithFallback(
      _api,
      _classPaths('/$id/estudiantes'),
    );
    return asApiList(response.data);
  }

  Future<List<dynamic>> getMyClasses() async {
    final response = await _getWithFallback(_api, _classPaths('/mis-clases'));
    return asApiList(response.data);
  }

  Future<dynamic> enroll(Map<String, dynamic> payload) async {
    final response = await _postWithFallback(
      _api,
      _classPaths('/inscribir'),
      data: payload,
    );
    return pickPayload(response.data);
  }

  Future<dynamic> unenroll(int id) async {
    final response = await _deleteWithFallback(
      _api,
      _classPaths('/desinscribir/$id'),
    );
    return pickPayload(response.data);
  }

  Future<dynamic> deleteEnrollment(int id) async {
    final response = await _deleteWithFallback(
      _api,
      _classPaths('/eliminar-inscripcion/$id'),
    );
    return pickPayload(response.data);
  }

  Future<ClassDto> reactivate(int id) async {
    final response = await _putWithFallback(_api, [
      '${ApiConfig.clasesEndpoint}/admin/$id/reactivate',
      '/api/classes/admin/$id/reactivate',
      '/api/admin/clases/$id/reactivate',
    ]);
    return ClassDto.fromJson(asApiObject(response.data));
  }

  Future<void> deletePermanently(int id) async {
    await _deleteWithFallback(_api, [
      '${ApiConfig.clasesEndpoint}/admin/$id/permanent',
      '/api/classes/admin/$id/permanent',
      '/api/admin/clases/$id/permanent',
    ]);
  }
}

class WodsService {
  final ApiService _api = ApiService();

  Future<List<WodDto>> getByMonth(int year, int month) async {
    final String path = '/api/wod/calendar/$year/$month';
    final String fullUrl = '${ApiConfig.baseUrl}$path';

    print("=========== WODS ===========");
    print("GET -> $fullUrl");

    try {
      final response = await _api.get(path);
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.data}");

      return asApiList(response.data)
          .whereType<Map>()
          .map((item) => WodDto.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      print("STATUS ERROR: ${e.response?.statusCode}");
      print("BODY ERROR: ${e.response?.data}");
      rethrow;
    }
  }

  Future<WodDto?> getByDate(DateTime fecha) async {
    final String path = '/api/wod/date/${fecha.toIso8601String().split('T').first}';
    print("WodsService: getByDate -> $path");
    try {
      final response = await _api.get(path);
      final data = asApiObject(response.data);
      return data.isEmpty ? null : WodDto.fromJson(data);
    } on DioException catch (e) {
      print("WodsService ERROR: ${e.response?.statusCode} - ${e.response?.data}");
      rethrow;
    }
  }

  Future<WodDto?> getById(int id) async {
    final response = await _getWithFallback(_api, _wodPaths('/$id'));
    final data = asApiObject(response.data);
    return data.isEmpty ? null : WodDto.fromJson(data);
  }

  Future<WodDto> create(Map<String, dynamic> payload) async {
    final response = await _postWithFallback(
      _api,
      _wodPaths(''),
      data: payload,
    );
    return WodDto.fromJson(asApiObject(response.data));
  }

  Future<WodDto> update(int id, Map<String, dynamic> payload) async {
    final response = await _putWithFallback(
      _api,
      _wodPaths('/$id'),
      data: payload,
    );
    return WodDto.fromJson(asApiObject(response.data));
  }

  Future<void> delete(int id) async {
    await _api.delete('/api/wod/$id');
  }

  Future<List<ScheduleDto>> getSchedulesByWod(int id) async {
    final response = await _api.get('/api/wod/$id/schedules');
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ScheduleDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ScheduleDto>> createSchedule(
    int wodId,
    List<Map<String, dynamic>> schedules,
  ) async {
    final response = await _api.post(
      '/api/wod/$wodId/schedule',
      data: schedules,
    );
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ScheduleDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<dynamic> enrollSchedule(int scheduleId) async {
    final response = await _api.post('/api/wod/schedule/$scheduleId/enroll');
    return pickPayload(response.data);
  }

  Future<dynamic> unenrollSchedule(int scheduleId) async {
    final response = await _api.delete('/api/wod/schedule/$scheduleId/unenroll');
    return pickPayload(response.data);
  }

  Future<dynamic> cancelSchedule(int scheduleId) async {
    final response = await _api.put('/api/wod/schedule/$scheduleId/cancel');
    return pickPayload(response.data);
  }

  Future<List<dynamic>> getEnrolledAthletes(int scheduleId) async {
    final response = await _api.get('/api/wod/schedule/$scheduleId/athletes');
    return asApiList(response.data);
  }

  Future<List<dynamic>> getMySchedules() async {
    final response = await _api.get('/api/wod/my-schedules');
    return asApiList(response.data);
  }

  Future<StreakDto?> getRacha() async {
    final response = await _api.get('/api/wod/racha');
    final data = asApiObject(response.data);
    return data.isEmpty ? null : StreakDto.fromJson(data);
  }

  Future<List<dynamic>> getHistorialAsistencias() async {
    final response = await _api.get('/api/wod/historial-asistencias');
    return asApiList(response.data);
  }

  Future<dynamic> marcarAsistencia(int inscripcionId) async {
    final response = await _api.post('/api/wod/asistencia/$inscripcionId');
    return pickPayload(response.data);
  }
}

class ExercisesService {
  final ApiService _api = ApiService();

  Future<List<ExerciseDto>> getAll() async {
    final response = await _api.get('${ApiConfig.baseUrl}/api/ejercicios');
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ExerciseDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ExerciseDto?> getById(int id) async {
    final response = await _api.get('${ApiConfig.baseUrl}/api/ejercicios/$id');
    final data = asApiObject(response.data);
    return data.isEmpty ? null : ExerciseDto.fromJson(data);
  }

  Future<List<ExerciseDto>> search(String term) async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/ejercicios/search',
      queryParameters: {'q': term},
    );
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ExerciseDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/ejercicios/stats',
    );
    return asApiObject(response.data);
  }

  Future<ExerciseDto> create(Map<String, dynamic> payload) async {
    final response = await _api.post(
      '${ApiConfig.baseUrl}/api/ejercicios',
      data: payload,
    );
    return ExerciseDto.fromJson(asApiObject(response.data));
  }

  Future<ExerciseDto> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.baseUrl}/api/ejercicios/$id',
      data: payload,
    );
    return ExerciseDto.fromJson(asApiObject(response.data));
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.baseUrl}/api/ejercicios/$id');
  }

  Future<ExerciseDto> reactivate(int id) async {
    final response = await _api.post(
      '${ApiConfig.baseUrl}/api/ejercicios/$id/reactivate',
    );
    return ExerciseDto.fromJson(asApiObject(response.data));
  }
}

class ProgressService {
  final ApiService _api = ApiService();

  Future<List<ProgressDto>> getEjerciciosConProgreso() async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/progreso/ejercicios',
    );
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ProgressDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ProgressDto> actualizarMarca(Map<String, dynamic> payload) async {
    final response = await _api.post(
      '${ApiConfig.baseUrl}/api/progreso/marca',
      data: payload,
    );
    return ProgressDto.fromJson(asApiObject(response.data));
  }

  Future<Map<String, dynamic>> getEstadisticas() async {
    final response = await _api.get(
      '${ApiConfig.baseUrl}/api/progreso/estadisticas',
    );
    return asApiObject(response.data);
  }

  Future<void> eliminarMarca(int exerciseId) async {
    await _api.delete('${ApiConfig.baseUrl}/api/progreso/marca/$exerciseId');
  }
}

class ContactsService {
  final ApiService _api = ApiService();

  Future<ContactDto> send(Map<String, dynamic> payload) async {
    final response = await _api.post(
      '${ApiConfig.baseUrl}/api/contact',
      data: payload,
    );
    return ContactDto.fromJson(asApiObject(response.data));
  }

  Future<List<ContactDto>> getAll() async {
    final response = await _api.get('${ApiConfig.baseUrl}/api/contact');
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ContactDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ContactDto> updateStatus(int id, String status) async {
    final response = await _api.put(
      '${ApiConfig.baseUrl}/api/contact/$id/status',
      data: {'status': status},
    );
    return ContactDto.fromJson(asApiObject(response.data));
  }
}

String extractServiceError(dynamic error) {
  if (error is String && error.trim().isNotEmpty) return error;
  if (error is Exception)
    return error.toString().replaceFirst('Exception: ', '');
  return 'Ocurrió un error inesperado';
}

String serviceResponseMessage(
  dynamic data, {
  String fallback = 'Operación completada',
}) {
  return _messageFromData(data, fallback: fallback);
}
