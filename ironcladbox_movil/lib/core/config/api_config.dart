/// Configuración centralizada de la API REST
/// 
/// INSTRUCCIONES:
/// ✅ AQUÍ ES DONDE DEBES PONER TU IP DE LA API NODE.JS
/// 
/// Ejemplo: 
/// - http://192.168.1.100:3000
/// - http://10.0.2.2:3000 (para emulador Android)
/// - http://localhost:3000 (para dispositivo local)

class ApiConfig {
  static const String baseUrl = 'http://10.40.22.167:3000';

  // Auth
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String verifyTokenEndpoint = '/api/auth/verify';
  static const String profileEndpoint = '/api/auth/profile';
  static const String membershipsEndpoint = '/api/auth/memberships';

  // Admin - Memberships
  static const String adminMemberships = '/api/admin/memberships';
  static const String adminMembershipsAssign = '/api/admin/memberships/assign';
  static const String adminMembershipsExpired = '/api/admin/memberships/expired';
  static const String adminMembershipsDeactivate = '/api/admin/memberships/deactivate-expired';

  // Admin - Athletes
  static const String adminAthletes = '/api/admin/athletes';
  static const String adminAthletesStatus = '/api/admin/athletes';
  static const String adminAthletesMembership = '/api/admin/athletes';

  // Admin - Trainers
  static const String adminTrainers = '/api/admin/trainers';

  // Members (athlete's own data)
  static const String membersCheck = '/api/members/check-membership';
  static const String membersMyMembership = '/api/members/my-membership';

  // Trainers (public & own data)
  static const String trainers = '/api/trainers';
  static const String trainersMyClasses = '/api/trainers/my-classes';
  static const String trainersMyWods = '/api/trainers/my-wods';
  static const String trainersMyAthletes = '/api/trainers/my-athletes';

  // Classes
  static const String classes = '/api/classes';
  static const String classesAvailable = '/api/classes/available';
  static const String classesMy = '/api/classes/my-classes';
  static const String classesEnroll = '/api/classes/enroll';
  static const String classesUnenroll = '/api/classes/unenroll';
  static const String classesDeleteEnrollment = '/api/classes/delete-enrollment';

  // WOD
  static const String wod = '/api/wod';
  static const String wodMySchedules = '/api/wod/my-schedules';
  static const String wodRacha = '/api/wod/racha';
  static const String wodHistorial = '/api/wod/historial-asistencias';

  // Exercises
  static const String ejercicios = '/api/ejercicios';

  // Progress
  static const String progreso = '/api/progreso';
  static const String progresoEjercicios = '/api/progreso/ejercicios';
  static const String progresoEstadisticas = '/api/progreso/estadisticas';
  static const String progresoMarca = '/api/progreso/marca';

  // Contact
  static const String contact = '/api/contact';

  // Profile
  static const String changePassword = '/api/auth/change-password';

  // Admin - Classes
  static const String adminClasses = '/api/admin/classes';

  // Admin - Stats
  static const String adminStats = '/api/admin/stats';
  
  // Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeouts
  static const int connectTimeout = 120000; // 120 segundos (Render cold start)
  static const int receiveTimeout = 120000;
  static const int sendTimeout = 120000;
}
