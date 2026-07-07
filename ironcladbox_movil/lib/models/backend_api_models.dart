DateTime? parseApiDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

int? parseApiInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? parseApiDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? parseApiBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final text = value.toString().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}

Map<String, dynamic> normalizeApiMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return <String, dynamic>{};
}

dynamic pickPayload(dynamic data) {
  final map = normalizeApiMap(data);
  if (map.isEmpty) return data;

  for (final key in const ['data', 'result', 'items', 'rows', 'payload']) {
    final value = map[key];
    if (value != null) return value;
  }

  return map;
}

List<dynamic> asApiList(dynamic data) {
  final payload = pickPayload(data);
  if (payload is List) return payload;

  if (payload is Map) {
    final map = normalizeApiMap(payload);
    for (final key in const ['data', 'result', 'items', 'rows']) {
      final value = map[key];
      if (value is List) return value;
    }
  }

  return const [];
}

Map<String, dynamic> asApiObject(dynamic data) {
  final payload = pickPayload(data);
  if (payload is Map<String, dynamic>) return payload;
  if (payload is Map) return Map<String, dynamic>.from(payload);
  return <String, dynamic>{};
}

String apiText(Map<String, dynamic> json, List<String> keys, {String fallback = ''}) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  }
  return fallback;
}

class MembershipDto {
  final int? id;
  final String nombre;
  final String? descripcion;
  final double? precio;
  final int? duracionDias;
  final bool? activa;
  final String? estado;
  final String? beneficios;

  const MembershipDto({
    required this.nombre,
    this.id,
    this.descripcion,
    this.precio,
    this.duracionDias,
    this.activa,
    this.estado,
    this.beneficios,
  });

  factory MembershipDto.fromJson(Map<String, dynamic> json) {
    return MembershipDto(
      id: parseApiInt(json['id_membresia'] ?? json['id'] ?? json['idMembresia']),
      nombre: apiText(json, const ['nombre', 'membresia_nombre'], fallback: ''),
      descripcion: json['descripcion']?.toString(),
      precio: parseApiDouble(json['precio']),
      duracionDias: parseApiInt(json['duracion_dias'] ?? json['duracionDias']),
      activa: parseApiBool(json['activa'] ?? json['estado']),
      estado: json['estado']?.toString(),
      beneficios: json['beneficios']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'duracion_dias': duracionDias,
        'estado': estado,
        'beneficios': beneficios,
      };
}

class AthleteDto {
  final int? id;
  final int? userId;
  final String? nombre;
  final String? apellido;
  final String? email;
  final String? telefono;
  final String? direccion;
  final DateTime? fechaNacimiento;
  final double? peso;
  final double? altura;
  final int? membershipId;
  final DateTime? fechaRegistro;
  final DateTime? fechaInicioMembresia;
  final DateTime? fechaFinMembresia;
  final bool? activo;
  final String? estado;
  final String? membershipName;
  final int? totalInscripciones;
  final DateTime? ultimoWod;
  final bool canLogin;
  final bool isExpired;
  final bool hasMembership;
  final bool hasActiveMembership;

  const AthleteDto({
    this.id,
    this.userId,
    this.nombre,
    this.apellido,
    this.email,
    this.telefono,
    this.direccion,
    this.fechaNacimiento,
    this.peso,
    this.altura,
    this.membershipId,
    this.fechaRegistro,
    this.fechaInicioMembresia,
    this.fechaFinMembresia,
    this.activo,
    this.estado,
    this.membershipName,
    this.totalInscripciones,
    this.ultimoWod,
    this.canLogin = false,
    this.isExpired = false,
    this.hasMembership = false,
    this.hasActiveMembership = false,
  });

  factory AthleteDto.fromJson(Map<String, dynamic> json) {
    return AthleteDto(
      id: parseApiInt(json['id_atleta'] ?? json['idAtleta'] ?? json['id']),
      userId: parseApiInt(json['id_usuario'] ?? json['idUsuario']),
      nombre: json['nombre']?.toString(),
      apellido: json['apellido']?.toString(),
      email: json['email']?.toString(),
      telefono: json['telefono']?.toString(),
      direccion: json['direccion']?.toString(),
      fechaNacimiento: parseApiDate(json['fecha_nacimiento'] ?? json['fechaNacimiento']),
      peso: parseApiDouble(json['peso']),
      altura: parseApiDouble(json['altura']),
      membershipId: parseApiInt(json['id_membresia'] ?? json['idMembresia']),
      fechaRegistro: parseApiDate(json['fecha_registro'] ?? json['fechaRegistro']),
      fechaInicioMembresia: parseApiDate(json['fecha_inicio'] ?? json['fecha_inicio_membresia'] ?? json['fechaInicioMembresia']),
      fechaFinMembresia: parseApiDate(json['fecha_fin'] ?? json['fecha_fin_membresia'] ?? json['fechaFinMembresia']),
      activo: parseApiBool(json['estado'] ?? json['activo']),
      estado: json['estado']?.toString(),
      membershipName: json['membresia_nombre']?.toString() ?? json['membership_name']?.toString(),
      totalInscripciones: parseApiInt(json['total_inscripciones'] ?? json['inscripciones_count'] ?? json['total_inscritos'] ?? json['total_clases'] ?? json['totalInscripciones']),
      ultimoWod: parseApiDate(json['ultimo_wod'] ?? json['fecha_ultimo_wod'] ?? json['ultimo_entrenamiento'] ?? json['last_wod'] ?? json['fecha'] ?? json['fecha_inscripcion'] ?? json['ultimoWod']),
      canLogin: parseApiBool(json['canLogin']) ?? false,
      isExpired: parseApiBool(json['isExpired']) ?? false,
      hasMembership: parseApiBool(json['hasMembresia']) ?? false,
      hasActiveMembership: parseApiBool(json['hasActiveMembership']) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id_usuario': userId,
        'peso': peso,
        'altura': altura,
        'direccion': direccion,
        'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
        'id_membresia': membershipId,
        'fecha_inicio_membresia': fechaInicioMembresia?.toIso8601String(),
        'fecha_fin_membresia': fechaFinMembresia?.toIso8601String(),
        'estado': estado,
      };
}

class TrainerDto {
  final int? id;
  final int? userId;
  final String? nombre;
  final String? apellido;
  final String? email;
  final String? telefono;
  final String? direccion;
  final DateTime? fechaNacimiento;
  final bool? activo;
  final String? especialidad;
  final int? aniosExperiencia;
  final String? certificaciones;
  final String? biografia;
  final String? estado;

  const TrainerDto({
    this.id,
    this.userId,
    this.nombre,
    this.apellido,
    this.email,
    this.telefono,
    this.direccion,
    this.fechaNacimiento,
    this.activo,
    this.especialidad,
    this.aniosExperiencia,
    this.certificaciones,
    this.biografia,
    this.estado,
  });

  factory TrainerDto.fromJson(Map<String, dynamic> json) {
    return TrainerDto(
      id: parseApiInt(json['id_entrenador'] ?? json['idEntrenador'] ?? json['id']),
      userId: parseApiInt(json['id_usuario'] ?? json['idUsuario']),
      nombre: json['nombre']?.toString(),
      apellido: json['apellido']?.toString(),
      email: json['email']?.toString(),
      telefono: json['telefono']?.toString(),
      direccion: json['direccion']?.toString(),
      fechaNacimiento: parseApiDate(json['fecha_nacimiento'] ?? json['fechaNacimiento']),
      activo: parseApiBool(json['estado'] ?? json['activo']),
      especialidad: json['especialidad']?.toString(),
      aniosExperiencia: parseApiInt(json['anios_experiencia'] ?? json['aniosExperiencia']),
      certificaciones: json['certificaciones']?.toString(),
      biografia: json['biografia']?.toString(),
      estado: json['estado']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_usuario': userId,
        'especialidad': especialidad,
        'anios_experiencia': aniosExperiencia,
        'certificaciones': certificaciones,
        'biografia': biografia,
        'direccion': direccion,
        'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      };
}

class ClassDto {
  final int? id;
  final String nombre;
  final String? descripcion;
  final DateTime? fecha;
  final String? hora;
  final int? cupoMaximo;
  final int? entrenadorId;
  final String? entrenadorNombre;
  final String? especialidad;
  final int? inscritos;
  final int? cuposDisponibles;
  final String? estado;

  const ClassDto({
    required this.nombre,
    this.id,
    this.descripcion,
    this.fecha,
    this.hora,
    this.cupoMaximo,
    this.entrenadorId,
    this.entrenadorNombre,
    this.especialidad,
    this.inscritos,
    this.cuposDisponibles,
    this.estado,
  });

  factory ClassDto.fromJson(Map<String, dynamic> json) {
    return ClassDto(
      id: parseApiInt(json['id_clase'] ?? json['idClase'] ?? json['id']),
      nombre: apiText(json, const ['nombre', 'clase_nombre'], fallback: ''),
      descripcion: json['descripcion']?.toString(),
      fecha: parseApiDate(json['fecha']),
      hora: json['hora']?.toString(),
      cupoMaximo: parseApiInt(json['cupo_maximo'] ?? json['capacidad_maxima'] ?? json['cupoMaximo']),
      entrenadorId: parseApiInt(json['id_entrenador'] ?? json['entrenadorId']),
      entrenadorNombre: json['entrenador_nombre']?.toString(),
      especialidad: json['especialidad']?.toString(),
      inscritos: parseApiInt(json['inscritos']),
      cuposDisponibles: parseApiInt(json['cupos_disponibles']),
      estado: json['estado']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'fecha': fecha?.toIso8601String(),
        'hora': hora,
        'cupo_maximo': cupoMaximo,
        'id_entrenador': entrenadorId,
        'estado': estado,
      };
}

class ScheduleDto {
  final int? id;
  final int? wodId;
  final String? hora;
  final int? cupoMaximo;
  final int? entrenadorId;
  final String? entrenadorNombre;
  final int? inscritos;
  final int? cuposDisponibles;
  final String? estado;
  final DateTime? createdAt;

  const ScheduleDto({
    this.id,
    this.wodId,
    this.hora,
    this.cupoMaximo,
    this.entrenadorId,
    this.entrenadorNombre,
    this.inscritos,
    this.cuposDisponibles,
    this.estado,
    this.createdAt,
  });

  factory ScheduleDto.fromJson(Map<String, dynamic> json) {
    return ScheduleDto(
      id: parseApiInt(json['id_horario'] ?? json['idHorario'] ?? json['id']),
      wodId: parseApiInt(json['id_wod'] ?? json['wodId']),
      hora: json['hora']?.toString(),
      cupoMaximo: parseApiInt(json['cupo_maximo'] ?? json['capacidad_maxima']),
      entrenadorId: parseApiInt(json['id_entrenador'] ?? json['entrenadorId']),
      entrenadorNombre: json['entrenador_nombre']?.toString(),
      inscritos: parseApiInt(json['inscritos']),
      cuposDisponibles: parseApiInt(json['cupos_disponibles']),
      estado: json['estado']?.toString(),
      createdAt: parseApiDate(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_wod': wodId,
        'hora': hora,
        'cupo_maximo': cupoMaximo,
        'id_entrenador': entrenadorId,
        'estado': estado,
      };
}

class WodDto {
  final int? id;
  final DateTime? fecha;
  final String? titulo;
  final String? descripcion;
  final String? tipo;
  final String? nivel;
  final int? entrenadorId;
  final String? entrenadorNombre;
  final List<ScheduleDto> horarios;

  const WodDto({
    this.id,
    this.fecha,
    this.titulo,
    this.descripcion,
    this.tipo,
    this.nivel,
    this.entrenadorId,
    this.entrenadorNombre,
    this.horarios = const [],
  });

  factory WodDto.fromJson(Map<String, dynamic> json) {
    final rawSchedules = json['horarios'];
    final schedules = rawSchedules is List
        ? rawSchedules
            .whereType<Map>()
            .map((item) => ScheduleDto.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <ScheduleDto>[];

    return WodDto(
      id: parseApiInt(json['id_wod'] ?? json['idWod'] ?? json['id']),
      fecha: parseApiDate(json['fecha']),
      titulo: json['titulo']?.toString(),
      descripcion: json['descripcion']?.toString(),
      tipo: json['tipo']?.toString(),
      nivel: json['nivel']?.toString(),
      entrenadorId: parseApiInt(json['id_entrenador'] ?? json['entrenadorId']),
      entrenadorNombre: json['entrenador_nombre']?.toString(),
      horarios: schedules,
    );
  }

  Map<String, dynamic> toJson() => {
        'fecha': fecha?.toIso8601String(),
        'titulo': titulo,
        'descripcion': descripcion,
        'tipo': tipo,
        'nivel': nivel,
        'id_entrenador': entrenadorId,
      };
}

class ExerciseDto {
  final int? id;
  final String nombre;
  final String? descripcion;
  final String? imagenUrl;
  final bool? activo;
  final int? totalRegistrados;
  final double? promedioMarca;

  const ExerciseDto({
    required this.nombre,
    this.id,
    this.descripcion,
    this.imagenUrl,
    this.activo,
    this.totalRegistrados,
    this.promedioMarca,
  });

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    return ExerciseDto(
      id: parseApiInt(json['id_ejercicio'] ?? json['idEjercicio'] ?? json['id']),
      nombre: apiText(json, const ['nombre'], fallback: ''),
      descripcion: json['descripcion']?.toString(),
      imagenUrl: json['imagen_url']?.toString(),
      activo: parseApiBool(json['activo']),
      totalRegistrados: parseApiInt(json['total_registros'] ?? json['totalRegistrados']),
      promedioMarca: parseApiDouble(json['promedio_marca'] ?? json['average']),
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'imagen_url': imagenUrl,
      };
}

class ProgressDto {
  final int? id;
  final int? athleteId;
  final int? exerciseId;
  final String? exerciseName;
  final String? descripcion;
  final String? imagenUrl;
  final double? marcaMaxima;
  final DateTime? fechaRegistro;
  final DateTime? fechaActualizacion;

  const ProgressDto({
    this.id,
    this.athleteId,
    this.exerciseId,
    this.exerciseName,
    this.descripcion,
    this.imagenUrl,
    this.marcaMaxima,
    this.fechaRegistro,
    this.fechaActualizacion,
  });

  factory ProgressDto.fromJson(Map<String, dynamic> json) {
    return ProgressDto(
      id: parseApiInt(json['id_progreso'] ?? json['idProgreso'] ?? json['id']),
      athleteId: parseApiInt(json['id_atleta'] ?? json['athleteId']),
      exerciseId: parseApiInt(json['id_ejercicio'] ?? json['exerciseId']),
      exerciseName: json['nombre_ejercicio']?.toString(),
      descripcion: json['descripcion']?.toString(),
      imagenUrl: json['imagen_url']?.toString(),
      marcaMaxima: parseApiDouble(json['marca_maxima']),
      fechaRegistro: parseApiDate(json['fecha_registro']),
      fechaActualizacion: parseApiDate(json['fecha_actualizacion']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_atleta': athleteId,
        'id_ejercicio': exerciseId,
        'marca_maxima': marcaMaxima,
      };
}

class StreakDto {
  final int? athleteId;
  final int rachaActual;
  final int rachaMaxima;
  final DateTime? ultimaAsistencia;
  final DateTime? fechaInicioRacha;
  final int totalAsistencias;
  final int asistenciasMes;

  const StreakDto({
    this.athleteId,
    required this.rachaActual,
    required this.rachaMaxima,
    this.ultimaAsistencia,
    this.fechaInicioRacha,
    required this.totalAsistencias,
    required this.asistenciasMes,
  });

  factory StreakDto.fromJson(Map<String, dynamic> json) {
    return StreakDto(
      athleteId: parseApiInt(json['id_atleta'] ?? json['athleteId']),
      rachaActual: parseApiInt(json['racha_actual']) ?? 0,
      rachaMaxima: parseApiInt(json['racha_maxima']) ?? 0,
      ultimaAsistencia: parseApiDate(json['ultima_asistencia']),
      fechaInicioRacha: parseApiDate(json['fecha_inicio_racha']),
      totalAsistencias: parseApiInt(json['total_asistencias']) ?? 0,
      asistenciasMes: parseApiInt(json['asistencias_mes']) ?? 0,
    );
  }
}

class ContactDto {
  final int? id;
  final String nombre;
  final String email;
  final String asunto;
  final String mensaje;
  final DateTime? fecha;
  final String? status;

  const ContactDto({
    this.id,
    required this.nombre,
    required this.email,
    required this.asunto,
    required this.mensaje,
    this.fecha,
    this.status,
  });

  factory ContactDto.fromJson(Map<String, dynamic> json) {
    return ContactDto(
      id: parseApiInt(json['id'] ?? json['id_contacto']),
      nombre: json['nombre']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      asunto: json['asunto']?.toString() ?? '',
      mensaje: json['mensaje']?.toString() ?? '',
      fecha: parseApiDate(json['fecha']),
      status: json['status']?.toString() ?? json['estado']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'email': email,
        'asunto': asunto,
        'mensaje': mensaje,
      };
}