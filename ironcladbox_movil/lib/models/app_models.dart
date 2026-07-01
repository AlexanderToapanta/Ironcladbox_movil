DateTime? _parseDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.tryParse(value.toString());
}

String? _formatDateTime(DateTime? value) => value?.toIso8601String();

class AuthSession {
  final String token;
  final String role;

  const AuthSession({required this.token, required this.role});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token']?.toString() ?? '',
      role: json['role']?.toString() ?? 'athlete',
    );
  }

  Map<String, dynamic> toJson() => {'token': token, 'role': role};

  AuthSession copyWith({String? token, String? role}) {
    return AuthSession(
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }
}

class Usuario {
  final int? id;
  final String? nombre;
  final String? email;
  final String? password;
  final int? rolId;
  final String? token;

  const Usuario({this.id, this.nombre, this.email, this.password, this.rolId, this.token});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int?,
      nombre: json['nombre'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      rolId: json['rolId'] as int?,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'password': password,
      'rolId': rolId,
      'token': token,
    };
  }

  Usuario copyWith({int? id, String? nombre, String? email, String? password, int? rolId, String? token}) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      password: password ?? this.password,
      rolId: rolId ?? this.rolId,
      token: token ?? this.token,
    );
  }
}

class Rol {
  final int? id;
  final String? nombre;
  final String? descripcion;

  const Rol({this.id, this.nombre, this.descripcion});

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'] as int?,
      nombre: json['nombre'] as String?,
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'descripcion': descripcion};

  Rol copyWith({int? id, String? nombre, String? descripcion}) {
    return Rol(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}

class Atleta {
  final int? id;
  final int? usuarioId;
  final double? altura;
  final double? peso;
  final DateTime? fechaNacimiento;
  final String? estado;

  const Atleta({this.id, this.usuarioId, this.altura, this.peso, this.fechaNacimiento, this.estado});

  factory Atleta.fromJson(Map<String, dynamic> json) {
    return Atleta(
      id: json['id'] as int?,
      usuarioId: json['usuarioId'] as int?,
      altura: (json['altura'] as num?)?.toDouble(),
      peso: (json['peso'] as num?)?.toDouble(),
      fechaNacimiento: _parseDateTime(json['fechaNacimiento']),
      estado: json['estado'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'altura': altura,
      'peso': peso,
      'fechaNacimiento': _formatDateTime(fechaNacimiento),
      'estado': estado,
    };
  }

  Atleta copyWith({int? id, int? usuarioId, double? altura, double? peso, DateTime? fechaNacimiento, String? estado}) {
    return Atleta(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      altura: altura ?? this.altura,
      peso: peso ?? this.peso,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      estado: estado ?? this.estado,
    );
  }
}

class Entrenador {
  final int? id;
  final int? usuarioId;
  final String? especialidad;
  final int? experienciaAnos;

  const Entrenador({this.id, this.usuarioId, this.especialidad, this.experienciaAnos});

  factory Entrenador.fromJson(Map<String, dynamic> json) {
    return Entrenador(
      id: json['id'] as int?,
      usuarioId: json['usuarioId'] as int?,
      especialidad: json['especialidad'] as String?,
      experienciaAnos: json['experienciaAnos'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'usuarioId': usuarioId, 'especialidad': especialidad, 'experienciaAnos': experienciaAnos};

  Entrenador copyWith({int? id, int? usuarioId, String? especialidad, int? experienciaAnos}) {
    return Entrenador(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      especialidad: especialidad ?? this.especialidad,
      experienciaAnos: experienciaAnos ?? this.experienciaAnos,
    );
  }
}

class Membresia {
  final int? id;
  final String? nombre;
  final String? descripcion;
  final double? precio;
  final int? duracionDias;
  final bool? activa;

  const Membresia({this.id, this.nombre, this.descripcion, this.precio, this.duracionDias, this.activa});

  factory Membresia.fromJson(Map<String, dynamic> json) {
    return Membresia(
      id: json['id'] as int?,
      nombre: json['nombre'] as String?,
      descripcion: json['descripcion'] as String?,
      precio: (json['precio'] as num?)?.toDouble(),
      duracionDias: json['duracionDias'] as int?,
      activa: json['activa'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'descripcion': descripcion, 'precio': precio, 'duracionDias': duracionDias, 'activa': activa};

  Membresia copyWith({int? id, String? nombre, String? descripcion, double? precio, int? duracionDias, bool? activa}) {
    return Membresia(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      duracionDias: duracionDias ?? this.duracionDias,
      activa: activa ?? this.activa,
    );
  }
}

class Clase {
  final int? id;
  final String? nombre;
  final String? descripcion;
  final int? capacidad;
  final int? entrenadorId;

  const Clase({this.id, this.nombre, this.descripcion, this.capacidad, this.entrenadorId});

  factory Clase.fromJson(Map<String, dynamic> json) {
    return Clase(
      id: json['id'] as int?,
      nombre: json['nombre'] as String?,
      descripcion: json['descripcion'] as String?,
      capacidad: json['capacidad'] as int?,
      entrenadorId: json['entrenadorId'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'descripcion': descripcion, 'capacidad': capacidad, 'entrenadorId': entrenadorId};

  Clase copyWith({int? id, String? nombre, String? descripcion, int? capacidad, int? entrenadorId}) {
    return Clase(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      capacidad: capacidad ?? this.capacidad,
      entrenadorId: entrenadorId ?? this.entrenadorId,
    );
  }
}

class Wod {
  final int? id;
  final String? titulo;
  final String? descripcion;
  final DateTime? fecha;
  final int? claseId;
  final String? nivel;

  const Wod({this.id, this.titulo, this.descripcion, this.fecha, this.claseId, this.nivel});

  factory Wod.fromJson(Map<String, dynamic> json) {
    return Wod(
      id: json['id'] as int?,
      titulo: json['titulo'] as String?,
      descripcion: json['descripcion'] as String?,
      fecha: _parseDateTime(json['fecha']),
      claseId: json['claseId'] as int?,
      nivel: json['nivel'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'titulo': titulo, 'descripcion': descripcion, 'fecha': _formatDateTime(fecha), 'claseId': claseId, 'nivel': nivel};

  Wod copyWith({int? id, String? titulo, String? descripcion, DateTime? fecha, int? claseId, String? nivel}) {
    return Wod(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      claseId: claseId ?? this.claseId,
      nivel: nivel ?? this.nivel,
    );
  }
}

class HorarioClase {
  final int? id;
  final int? claseId;
  final String? diaSemana;
  final String? horaInicio;
  final String? horaFin;

  const HorarioClase({this.id, this.claseId, this.diaSemana, this.horaInicio, this.horaFin});

  factory HorarioClase.fromJson(Map<String, dynamic> json) {
    return HorarioClase(
      id: json['id'] as int?,
      claseId: json['claseId'] as int?,
      diaSemana: json['diaSemana'] as String?,
      horaInicio: json['horaInicio'] as String?,
      horaFin: json['horaFin'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'claseId': claseId, 'diaSemana': diaSemana, 'horaInicio': horaInicio, 'horaFin': horaFin};

  HorarioClase copyWith({int? id, int? claseId, String? diaSemana, String? horaInicio, String? horaFin}) {
    return HorarioClase(
      id: id ?? this.id,
      claseId: claseId ?? this.claseId,
      diaSemana: diaSemana ?? this.diaSemana,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
    );
  }
}

class Inscripcion {
  final int? id;
  final int? atletaId;
  final int? claseId;
  final DateTime? fecha;
  final String? estado;

  const Inscripcion({this.id, this.atletaId, this.claseId, this.fecha, this.estado});

  factory Inscripcion.fromJson(Map<String, dynamic> json) {
    return Inscripcion(
      id: json['id'] as int?,
      atletaId: json['atletaId'] as int?,
      claseId: json['claseId'] as int?,
      fecha: _parseDateTime(json['fecha']),
      estado: json['estado'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'atletaId': atletaId, 'claseId': claseId, 'fecha': _formatDateTime(fecha), 'estado': estado};

  Inscripcion copyWith({int? id, int? atletaId, int? claseId, DateTime? fecha, String? estado}) {
    return Inscripcion(
      id: id ?? this.id,
      atletaId: atletaId ?? this.atletaId,
      claseId: claseId ?? this.claseId,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
    );
  }
}

class Ejercicio {
  final int? id;
  final String? nombre;
  final String? descripcion;
  final int? series;
  final int? repeticiones;
  final double? peso;
  final String? tipo;

  const Ejercicio({this.id, this.nombre, this.descripcion, this.series, this.repeticiones, this.peso, this.tipo});

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    return Ejercicio(
      id: json['id'] as int?,
      nombre: json['nombre'] as String?,
      descripcion: json['descripcion'] as String?,
      series: json['series'] as int?,
      repeticiones: json['repeticiones'] as int?,
      peso: (json['peso'] as num?)?.toDouble(),
      tipo: json['tipo'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'descripcion': descripcion, 'series': series, 'repeticiones': repeticiones, 'peso': peso, 'tipo': tipo};

  Ejercicio copyWith({int? id, String? nombre, String? descripcion, int? series, int? repeticiones, double? peso, String? tipo}) {
    return Ejercicio(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      series: series ?? this.series,
      repeticiones: repeticiones ?? this.repeticiones,
      peso: peso ?? this.peso,
      tipo: tipo ?? this.tipo,
    );
  }
}

class Progreso {
  final int? id;
  final int? atletaId;
  final int? ejercicioId;
  final DateTime? fecha;
  final double? valor;
  final String? observaciones;

  const Progreso({this.id, this.atletaId, this.ejercicioId, this.fecha, this.valor, this.observaciones});

  factory Progreso.fromJson(Map<String, dynamic> json) {
    return Progreso(
      id: json['id'] as int?,
      atletaId: json['atletaId'] as int?,
      ejercicioId: json['ejercicioId'] as int?,
      fecha: _parseDateTime(json['fecha']),
      valor: (json['valor'] as num?)?.toDouble(),
      observaciones: json['observaciones'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'atletaId': atletaId, 'ejercicioId': ejercicioId, 'fecha': _formatDateTime(fecha), 'valor': valor, 'observaciones': observaciones};

  Progreso copyWith({int? id, int? atletaId, int? ejercicioId, DateTime? fecha, double? valor, String? observaciones}) {
    return Progreso(
      id: id ?? this.id,
      atletaId: atletaId ?? this.atletaId,
      ejercicioId: ejercicioId ?? this.ejercicioId,
      fecha: fecha ?? this.fecha,
      valor: valor ?? this.valor,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}

class Racha {
  final int? id;
  final int? atletaId;
  final int? diasConsecutivos;
  final DateTime? ultimaActividad;

  const Racha({this.id, this.atletaId, this.diasConsecutivos, this.ultimaActividad});

  factory Racha.fromJson(Map<String, dynamic> json) {
    return Racha(
      id: json['id'] as int?,
      atletaId: json['atletaId'] as int?,
      diasConsecutivos: json['diasConsecutivos'] as int?,
      ultimaActividad: _parseDateTime(json['ultimaActividad']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'atletaId': atletaId, 'diasConsecutivos': diasConsecutivos, 'ultimaActividad': _formatDateTime(ultimaActividad)};

  Racha copyWith({int? id, int? atletaId, int? diasConsecutivos, DateTime? ultimaActividad}) {
    return Racha(
      id: id ?? this.id,
      atletaId: atletaId ?? this.atletaId,
      diasConsecutivos: diasConsecutivos ?? this.diasConsecutivos,
      ultimaActividad: ultimaActividad ?? this.ultimaActividad,
    );
  }
}

class Contacto {
  final int? id;
  final String? nombre;
  final String? email;
  final String? asunto;
  final String? mensaje;
  final DateTime? fecha;

  const Contacto({this.id, this.nombre, this.email, this.asunto, this.mensaje, this.fecha});

  factory Contacto.fromJson(Map<String, dynamic> json) {
    return Contacto(
      id: json['id'] as int?,
      nombre: json['nombre'] as String?,
      email: json['email'] as String?,
      asunto: json['asunto'] as String?,
      mensaje: json['mensaje'] as String?,
      fecha: _parseDateTime(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'nombre': nombre, 'email': email, 'asunto': asunto, 'mensaje': mensaje, 'fecha': _formatDateTime(fecha)};

  Contacto copyWith({int? id, String? nombre, String? email, String? asunto, String? mensaje, DateTime? fecha}) {
    return Contacto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      asunto: asunto ?? this.asunto,
      mensaje: mensaje ?? this.mensaje,
      fecha: fecha ?? this.fecha,
    );
  }
}
