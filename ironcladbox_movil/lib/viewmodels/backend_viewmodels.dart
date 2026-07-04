import 'package:flutter/foundation.dart';
import 'dart:io';

import '../models/backend_api_models.dart';
import '../services/backend_api_services.dart';

abstract class BaseCollectionViewModel<T> extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  List<T> _items = const [];
  T? _selectedItem;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<T> get items => _items;
  T? get selectedItem => _selectedItem;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  void _setItems(List<T> value) {
    _items = value;
    notifyListeners();
  }

  void _setSelectedItem(T? value) {
    _selectedItem = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void clearSelection() {
    _selectedItem = null;
    notifyListeners();
  }
}

class MembershipsViewModel extends BaseCollectionViewModel<MembershipDto> {
  final MembershipsService _service = MembershipsService();

  Future<void> loadAll() async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.getAll());
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadById(int id) async {
    _setLoading(true);
    _setError('');
    try {
      _setSelectedItem(await _service.getById(id));
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> create(Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.create(payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> update(int id, Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.update(id, payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> delete(int id) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.delete(id);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }
}

class AthletesViewModel extends BaseCollectionViewModel<AthleteDto> {
  final AthletesService _service = AthletesService();

  Future<void> loadAll() async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.getAll());
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadById(int id) async {
    _setLoading(true);
    _setError('');
    try {
      _setSelectedItem(await _service.getById(id));
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> create(Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.create(payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> update(int id, Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.update(id, payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> updateMembership(int id, Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.updateMembership(id, payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> updateStatus(int id, Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.updateStatus(id, payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> delete(int id) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.delete(id);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadMyMembership() async {
    _setLoading(true);
    _setError('');
    try {
      _setSelectedItem(await _service.getMyMembership());
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> updateMyMembership(Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      _setSelectedItem(await _service.updateMyMembership(payload));
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> cancelMyMembership() async {
    _setLoading(true);
    _setError('');
    try {
      await _service.cancelMyMembership();
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadExpiredMemberships() async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.getExpiredMemberships());
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadMyAthletes() async {
    _setLoading(true);
    _setError('');
    try {
      final trainerService = TrainersService();
      final data = await trainerService.getMyAthletes();
      final athletes = data.whereType<Map>().map((item) => AthleteDto.fromJson(Map<String, dynamic>.from(item))).toList();
      _setItems(athletes);
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }
}

class TrainersViewModel extends BaseCollectionViewModel<TrainerDto> {
  final TrainersService _service = TrainersService();

  Future<void> loadAll() async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.getAll());
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadById(int id) async {
    _setLoading(true);
    _setError('');
    try {
      _setSelectedItem(await _service.getById(id));
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadBySpecialty(String specialty) async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.getBySpecialty(specialty));
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> create(Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.create(payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> update(int id, Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.update(id, payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> updateStatus(int id, Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.updateStatus(id, payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> delete(int id) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.delete(id);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }
}

class ClassesViewModel extends BaseCollectionViewModel<ClassDto> {
  final ClassesService _service = ClassesService();

  Future<void> loadAll() async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.getAll());
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadAvailable() async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.getAvailable());
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadById(int id) async {
    _setLoading(true);
    _setError('');
    try {
      _setSelectedItem(await _service.getById(id));
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> create(Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.create(payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> update(int id, Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.update(id, payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> delete(int id) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.delete(id);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> reactivate(int id) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.reactivate(id);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> deletePermanently(int id) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.deletePermanently(id);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }
}

class WodsViewModel extends BaseCollectionViewModel<WodDto> {
  final WodsService _service = WodsService();

  Future<void> loadByMonth(int year, int month) async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.getByMonth(year, month));
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadByDate(DateTime fecha) async {
    _setLoading(true);
    _setError('');
    try {
      final item = await _service.getByDate(fecha);
      _setSelectedItem(item);
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadById(int id) async {
    _setLoading(true);
    _setError('');
    try {
      _setSelectedItem(await _service.getById(id));
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> create(Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.create(payload);
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> update(int id, Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.update(id, payload);
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> delete(int id) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.delete(id);
      await loadByMonth(DateTime.now().year, DateTime.now().month);
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadSchedules(int wodId) async {
    _setLoading(true);
    _setError('');
    try {
      final schedules = await _service.getSchedulesByWod(wodId);
      final current = selectedItem;
      if (current != null) {
        _setSelectedItem(
          WodDto(
            id: current.id,
            fecha: current.fecha,
            titulo: current.titulo,
            descripcion: current.descripcion,
            tipo: current.tipo,
            nivel: current.nivel,
            entrenadorId: current.entrenadorId,
            entrenadorNombre: current.entrenadorNombre,
            horarios: schedules,
          ),
        );
      }
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> enrollSchedule(int scheduleId) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.enrollSchedule(scheduleId);
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> unenrollSchedule(int scheduleId) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.unenrollSchedule(scheduleId);
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> cancelSchedule(int scheduleId) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.cancelSchedule(scheduleId);
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadMySchedules() async {
    _setLoading(true);
    _setError('');
    try {
      final items = await _service.getMySchedules();
      _setItems(items.whereType<Map>().map((item) => WodDto.fromJson(Map<String, dynamic>.from(item))).toList());
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadRacha() async {
    _setLoading(true);
    _setError('');
    try {
      final streak = await _service.getRacha();
      if (streak != null) {
        _setError('');
      }
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }
}

class ExercisesViewModel extends BaseCollectionViewModel<ExerciseDto> {
  final ExercisesService _service = ExercisesService();

  Future<void> loadAll() async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.getAll());
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> loadById(int id) async {
    _setLoading(true);
    _setError('');
    try {
      _setSelectedItem(await _service.getById(id));
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> search(String term) async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.search(term));
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<Map<String, dynamic>> loadStats() async {
    _setLoading(true);
    _setError('');
    try {
      return await _service.getStats();
    } catch (e) {
      _setError(extractServiceError(e));
      return <String, dynamic>{};
    } finally {
      _setLoading(false);
    }
  }

  Future<void> create(Map<String, dynamic> payload, {File? imageFile}) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.create(payload, imageFile: imageFile);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> update(int id, Map<String, dynamic> payload, {File? imageFile, bool deleteImage = false}) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.update(id, payload, imageFile: imageFile, deleteImage: deleteImage);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> delete(int id) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.delete(id);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> reactivate(int id) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.reactivate(id);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }
}

class ProgressViewModel extends BaseCollectionViewModel<ProgressDto> {
  final ProgressService _service = ProgressService();

  Future<void> loadAll() async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.getEjerciciosConProgreso());
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<Map<String, dynamic>> loadStats() async {
    _setLoading(true);
    _setError('');
    try {
      return await _service.getEstadisticas();
    } catch (e) {
      _setError(extractServiceError(e));
      return <String, dynamic>{};
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMark(Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.actualizarMarca(payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> deleteMark(int exerciseId) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.eliminarMarca(exerciseId);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }
}

class ContactsViewModel extends BaseCollectionViewModel<ContactDto> {
  final ContactsService _service = ContactsService();

  Future<void> loadAll() async {
    _setLoading(true);
    _setError('');
    try {
      _setItems(await _service.getAll());
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> send(Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.send(payload);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }

  Future<void> updateStatus(int id, String status) async {
    _setLoading(true);
    _setError('');
    try {
      await _service.updateStatus(id, status);
      await loadAll();
    } catch (e) {
      _setError(extractServiceError(e));
    }
    _setLoading(false);
  }
}
