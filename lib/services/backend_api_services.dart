import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../core/config/api_config.dart';
import '../models/backend_api_models.dart';
import 'api_service.dart';

String _messageFromData(
  dynamic data, {
  String fallback = 'Operacion completada',
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

class MembershipsService {
  final ApiService _api = ApiService();

  Future<List<MembershipDto>> getAll() async {
    final response = await _api.get(ApiConfig.membershipsEndpoint);
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => MembershipDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<MembershipDto?> getById(int id) async {
    final response = await _api.get('${ApiConfig.adminMemberships}/$id');
    final data = asApiObject(response.data);
    return data.isEmpty ? null : MembershipDto.fromJson(data);
  }

  Future<MembershipDto> create(Map<String, dynamic> payload) async {
    final response = await _api.post(ApiConfig.adminMemberships, data: payload);
    return MembershipDto.fromJson(asApiObject(response.data));
  }

  Future<MembershipDto> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.adminMemberships}/$id',
      data: payload,
    );
    return MembershipDto.fromJson(asApiObject(response.data));
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.adminMemberships}/$id');
  }
}

class AthletesService {
  final ApiService _api = ApiService();

  Future<List<AthleteDto>> getAll() async {
    final response = await _api.get(ApiConfig.adminAthletes);
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => AthleteDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<AthleteDto?> getById(int id) async {
    final response = await _api.get('${ApiConfig.adminAthletes}/$id');
    final data = asApiObject(response.data);
    return data.isEmpty ? null : AthleteDto.fromJson(data);
  }

  Future<AthleteDto> create(Map<String, dynamic> payload) async {
    final response = await _api.post(ApiConfig.adminAthletes, data: payload);
    return AthleteDto.fromJson(asApiObject(response.data));
  }

  Future<AthleteDto> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.adminAthletes}/$id',
      data: payload,
    );
    return AthleteDto.fromJson(asApiObject(response.data));
  }

  Future<AthleteDto> updateMembership(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _api.put(
      '${ApiConfig.adminAthletes}/$id/membership',
      data: payload,
    );
    return AthleteDto.fromJson(asApiObject(response.data));
  }

  Future<AthleteDto> updateStatus(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.adminAthletes}/$id/status',
      data: payload,
    );
    return AthleteDto.fromJson(asApiObject(response.data));
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.adminAthletes}/$id');
  }

  Future<AthleteDto?> checkMembershipStatus() async {
    final response = await _api.get(ApiConfig.membersCheck);
    final data = asApiObject(response.data);
    return data.isEmpty ? null : AthleteDto.fromJson(data);
  }

  Future<AthleteDto?> getMyMembership() async {
    final response = await _api.get(ApiConfig.membersMyMembership);
    final data = asApiObject(response.data);
    return data.isEmpty ? null : AthleteDto.fromJson(data);
  }

  Future<AthleteDto> updateMyMembership(Map<String, dynamic> payload) async {
    final response = await _api.put(
      ApiConfig.membersMyMembership,
      data: payload,
    );
    return AthleteDto.fromJson(asApiObject(response.data));
  }

  Future<void> cancelMyMembership() async {
    await _api.delete(ApiConfig.membersMyMembership);
  }

  Future<List<AthleteDto>> getExpiredMemberships() async {
    final response = await _api.get(ApiConfig.adminMembershipsExpired);
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => AthleteDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<dynamic>> deactivateExpiredMemberships() async {
    final response = await _api.post(ApiConfig.adminMembershipsDeactivate);
    return asApiList(response.data);
  }

  Future<AthleteDto> assignMembership(Map<String, dynamic> payload) async {
    final response = await _api.post(
      ApiConfig.adminMembershipsAssign,
      data: payload,
    );
    return AthleteDto.fromJson(asApiObject(response.data));
  }
}

class TrainersService {
  final ApiService _api = ApiService();

  Future<List<TrainerDto>> getAll() async {
    final response = await _api.get(ApiConfig.trainers);
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => TrainerDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<TrainerDto?> getById(int id) async {
    final response = await _api.get('${ApiConfig.trainers}/$id');
    final data = asApiObject(response.data);
    return data.isEmpty ? null : TrainerDto.fromJson(data);
  }

  Future<List<TrainerDto>> getBySpecialty(String specialty) async {
    final response = await _api.get(
      '${ApiConfig.trainers}/specialty/$specialty',
    );
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => TrainerDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<TrainerDto> create(Map<String, dynamic> payload) async {
    final response = await _api.post(
      ApiConfig.adminTrainers,
      data: payload,
    );
    return TrainerDto.fromJson(asApiObject(response.data));
  }

  Future<TrainerDto> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.adminTrainers}/$id',
      data: payload,
    );
    return TrainerDto.fromJson(asApiObject(response.data));
  }

  Future<TrainerDto> updateStatus(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.adminTrainers}/$id/status',
      data: payload,
    );
    return TrainerDto.fromJson(asApiObject(response.data));
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.adminTrainers}/$id');
  }

  Future<List<dynamic>> getMyClasses() async {
    final response = await _api.get(ApiConfig.trainersMyClasses);
    return asApiList(response.data);
  }

  Future<List<dynamic>> getMyWods() async {
    final response = await _api.get(ApiConfig.trainersMyWods);
    return asApiList(response.data);
  }

  Future<List<dynamic>> getMyAthletes() async {
    final response = await _api.get(ApiConfig.trainersMyAthletes);
    return asApiList(response.data);
  }
}

class ClassesService {
  final ApiService _api = ApiService();

  Future<List<ClassDto>> getAll() async {
    final response = await _api.get(ApiConfig.classes);
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ClassDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ClassDto>> getAvailable() async {
    final response = await _api.get(ApiConfig.classesAvailable);
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ClassDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ClassDto?> getById(int id) async {
    final response = await _api.get('${ApiConfig.classes}/$id');
    final data = asApiObject(response.data);
    return data.isEmpty ? null : ClassDto.fromJson(data);
  }

  Future<ClassDto> create(Map<String, dynamic> payload) async {
    final response = await _api.post(ApiConfig.classes, data: payload);
    return ClassDto.fromJson(asApiObject(response.data));
  }

  Future<ClassDto> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.classes}/$id',
      data: payload,
    );
    return ClassDto.fromJson(asApiObject(response.data));
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.classes}/$id');
  }

  Future<List<dynamic>> getEnrolledStudents(int id) async {
    final response = await _api.get('${ApiConfig.classes}/$id/students');
    return asApiList(response.data);
  }

  Future<List<dynamic>> getMyClasses() async {
    final response = await _api.get(ApiConfig.classesMy);
    return asApiList(response.data);
  }

  Future<dynamic> enroll(Map<String, dynamic> payload) async {
    final response = await _api.post(ApiConfig.classesEnroll, data: payload);
    return pickPayload(response.data);
  }

  Future<dynamic> unenroll(int id) async {
    final response = await _api.delete('${ApiConfig.classesUnenroll}/$id');
    return pickPayload(response.data);
  }

  Future<dynamic> deleteEnrollment(int id) async {
    final response = await _api.delete(
      '${ApiConfig.classesDeleteEnrollment}/$id',
    );
    return pickPayload(response.data);
  }

  Future<ClassDto> reactivate(int id) async {
    final response = await _api.put(
      '${ApiConfig.adminClasses}/$id/reactivate',
    );
    return ClassDto.fromJson(asApiObject(response.data));
  }

  Future<void> deletePermanently(int id) async {
    await _api.delete('${ApiConfig.adminClasses}/$id/permanent');
  }
}

class WodsService {
  final ApiService _api = ApiService();

  Future<List<WodDto>> getByMonth(int year, int month) async {
    final String path = '${ApiConfig.wod}/calendar/$year/$month';

    try {
      final response = await _api.get(path);
      return asApiList(response.data)
          .whereType<Map>()
          .map((item) => WodDto.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<WodDto?> getByDate(DateTime fecha) async {
    final String path =
        '${ApiConfig.wod}/date/${fecha.toIso8601String().split('T').first}';
    try {
      final response = await _api.get(path);
      final data = asApiObject(response.data);
      return data.isEmpty ? null : WodDto.fromJson(data);
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<WodDto?> getById(int id) async {
    final response = await _api.get('${ApiConfig.wod}/$id');
    final data = asApiObject(response.data);
    return data.isEmpty ? null : WodDto.fromJson(data);
  }

  Future<WodDto> create(Map<String, dynamic> payload) async {
    final response = await _api.post(ApiConfig.wod, data: payload);
    return WodDto.fromJson(asApiObject(response.data));
  }

  Future<WodDto> update(int id, Map<String, dynamic> payload) async {
    final response = await _api.put(
      '${ApiConfig.wod}/$id',
      data: payload,
    );
    return WodDto.fromJson(asApiObject(response.data));
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.wod}/$id');
  }

  Future<List<ScheduleDto>> getSchedulesByWod(int id) async {
    final response = await _api.get('${ApiConfig.wod}/$id/schedules');
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
      '${ApiConfig.wod}/$wodId/schedule',
      data: schedules,
    );
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ScheduleDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<dynamic> enrollSchedule(int scheduleId) async {
    final response = await _api.post(
      '${ApiConfig.wod}/schedule/$scheduleId/enroll',
    );
    return pickPayload(response.data);
  }

  Future<dynamic> unenrollSchedule(int scheduleId) async {
    final response = await _api.delete(
      '${ApiConfig.wod}/schedule/$scheduleId/unenroll',
    );
    return pickPayload(response.data);
  }

  Future<dynamic> cancelSchedule(int scheduleId) async {
    final response = await _api.put(
      '${ApiConfig.wod}/schedule/$scheduleId/cancel',
    );
    return pickPayload(response.data);
  }

  Future<List<dynamic>> getEnrolledAthletes(int scheduleId) async {
    final response = await _api.get(
      '${ApiConfig.wod}/schedule/$scheduleId/athletes',
    );
    return asApiList(response.data);
  }

  Future<List<dynamic>> getMySchedules() async {
    final response = await _api.get(ApiConfig.wodMySchedules);
    return asApiList(response.data);
  }

  Future<StreakDto?> getRacha() async {
    final response = await _api.get(ApiConfig.wodRacha);
    final data = asApiObject(response.data);
    return data.isEmpty ? null : StreakDto.fromJson(data);
  }

  Future<List<dynamic>> getHistorialAsistencias() async {
    final response = await _api.get(ApiConfig.wodHistorial);
    return asApiList(response.data);
  }

  Future<dynamic> marcarAsistencia(int inscripcionId) async {
    final response = await _api.post(
      '${ApiConfig.wod}/asistencia/$inscripcionId',
    );
    return pickPayload(response.data);
  }
}

class ExercisesService {
  final ApiService _api = ApiService();

  Future<List<ExerciseDto>> getAll() async {
    final response = await _api.get(ApiConfig.ejercicios);
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ExerciseDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ExerciseDto?> getById(int id) async {
    final response = await _api.get('${ApiConfig.ejercicios}/$id');
    final data = asApiObject(response.data);
    return data.isEmpty ? null : ExerciseDto.fromJson(data);
  }

  Future<List<ExerciseDto>> search(String term) async {
    final response = await _api.get(
      '${ApiConfig.ejercicios}/search',
      queryParameters: {'q': term},
    );
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ExerciseDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _api.get('${ApiConfig.ejercicios}/stats');
    return asApiObject(response.data);
  }

  Future<ExerciseDto> create(Map<String, dynamic> payload,
      {File? imageFile}) async {
    try {
      dynamic data;

      if (imageFile != null) {
        data = FormData.fromMap({
          'nombre': payload['nombre'],
          'descripcion': payload['descripcion'],
          'imagen': await MultipartFile.fromFile(
            imageFile.path,
            filename: p.basename(imageFile.path),
          ),
        });
      } else {
        data = payload;
      }

      final response = await _api.getDio().post(
            ApiConfig.ejercicios,
            data: data,
            options: Options(
              contentType: imageFile != null
                  ? 'multipart/form-data'
                  : 'application/json',
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );
      return ExerciseDto.fromJson(asApiObject(response.data));
    } catch (e) {
      rethrow;
    }
  }

  Future<ExerciseDto> update(int id, Map<String, dynamic> payload,
      {File? imageFile, bool deleteImage = false}) async {
    try {
      dynamic data;

      final Map<String, dynamic> map = {
        'nombre': payload['nombre'],
        'descripcion': payload['descripcion'],
        'deleteImage': deleteImage.toString(),
      };

      if (imageFile != null) {
        map['imagen'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: p.basename(imageFile.path),
        );
        data = FormData.fromMap(map);
      } else if (deleteImage) {
        data = FormData.fromMap(map);
      } else {
        data = payload;
      }

      final response = await _api.getDio().put(
            '${ApiConfig.ejercicios}/$id',
            data: data,
            options: Options(
              contentType: (imageFile != null || deleteImage)
                  ? 'multipart/form-data'
                  : 'application/json',
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );
      return ExerciseDto.fromJson(asApiObject(response.data));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    await _api.delete('${ApiConfig.ejercicios}/$id');
  }

  Future<ExerciseDto> reactivate(int id) async {
    final response = await _api.patch(
      '${ApiConfig.ejercicios}/$id/reactivate',
    );
    return ExerciseDto.fromJson(asApiObject(response.data));
  }
}

class ProgressService {
  final ApiService _api = ApiService();

  Future<List<ProgressDto>> getEjerciciosConProgreso() async {
    final response = await _api.get(ApiConfig.progresoEjercicios);
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ProgressDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ProgressDto> actualizarMarca(Map<String, dynamic> payload) async {
    final response = await _api.post(
      ApiConfig.progresoMarca,
      data: payload,
    );
    return ProgressDto.fromJson(asApiObject(response.data));
  }

  Future<Map<String, dynamic>> getEstadisticas() async {
    final response = await _api.get(ApiConfig.progresoEstadisticas);
    return asApiObject(response.data);
  }

  Future<void> eliminarMarca(int exerciseId) async {
    await _api.delete('${ApiConfig.progresoMarca}/$exerciseId');
  }
}

class ContactsService {
  final ApiService _api = ApiService();

  Future<ContactDto> send(Map<String, dynamic> payload) async {
    final response = await _api.post(ApiConfig.contact, data: payload);
    return ContactDto.fromJson(asApiObject(response.data));
  }

  Future<List<ContactDto>> getAll() async {
    final response = await _api.get(ApiConfig.contact);
    return asApiList(response.data)
        .whereType<Map>()
        .map((item) => ContactDto.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ContactDto> updateStatus(int id, String status) async {
    final response = await _api.put(
      '${ApiConfig.contact}/$id/status',
      data: {'status': status},
    );
    return ContactDto.fromJson(asApiObject(response.data));
  }
}

String extractServiceError(dynamic error) {
  if (error is String && error.trim().isNotEmpty) return error;
  if (error is Exception)
    return error.toString().replaceFirst('Exception: ', '');
  return 'Ocurrio un error inesperado';
}

String serviceResponseMessage(
  dynamic data, {
  String fallback = 'Operacion completada',
}) {
  return _messageFromData(data, fallback: fallback);
}
