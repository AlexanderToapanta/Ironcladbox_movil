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
  // ⬇️ REEMPLAZA ESTA URL CON LA IP Y PUERTO DE TU API NODE.JS ⬇️
  static const String baseUrl = 'http://192.168.18.2:3000';
  
  // Endpoints de autenticación
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String verifyTokenEndpoint = '/api/auth/verify';
  static const String profileEndpoint = '/api/auth/profile';
  
  // Endpoints de usuarios
  static const String usersEndpoint = '/api/users';
  
  // Endpoints de WOD (Workout of the Day)
  static const String wodsEndpoint = '/api/wod';
  
  // Endpoints de clases
  static const String clasesEndpoint = '/api/clases';
  
  // Endpoints de inscripciones
  static const String inscripcionesEndpoint = '/api/inscripciones';
  
  // Endpoints de membresías
  static const String membershipsEndpoint = '/api/auth/memberships';
  
  // Endpoints de ejercicios
  static const String ejerciciosEndpoint = '/api/ejercicios';
  
  // Endpoints de progreso
  static const String progressEndpoint = '/api/progress';
  
  // Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeouts
  static const int connectTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos
  static const int sendTimeout = 30000; // 30 segundos
}
