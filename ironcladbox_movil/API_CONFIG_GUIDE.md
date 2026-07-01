📍 CONFIGURACIÓN DE LA API - GUÍA RÁPIDA
========================================

✅ UBICACIÓN DEL ARCHIVO DE CONFIGURACIÓN:
lib/core/config/api_config.dart

⚠️ PASO 1: REEMPLAZA LA URL BASE CON TU IP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Abre el archivo: lib/core/config/api_config.dart

Encuentra esta línea:
```
static const String baseUrl = 'http://TU_IP_AQUI:3000';
```

Reemplázala con tu IP:
```
static const String baseUrl = 'http://192.168.1.100:3000';
```

📋 EJEMPLOS DE IPs SEGÚN TU CASO:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🖥️ API en tu computadora (misma red):
   static const String baseUrl = 'http://192.168.1.100:3000';

📱 Emulador Android (especial):
   static const String baseUrl = 'http://10.0.2.2:3000';

🔌 Dispositivo físico en misma red:
   static const String baseUrl = 'http://192.168.1.100:3000';

🌐 API en servidor remoto:
   static const String baseUrl = 'http://tu-dominio.com:3000';

🏠 API en localhost (solo funciona en web):
   static const String baseUrl = 'http://localhost:3000';

⚙️ PASO 2: USAR EL SERVICIO EN TUS ViewModels
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ejemplo de LoginViewModel:

```dart
import '/services/api_service.dart';
import '/core/config/api_config.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _apiService.setToken(token);
        notifyListeners();
      }
    } catch (e) {
      print('Error de login: $e');
    }
  }
}
```

🔑 ENDPOINTS DISPONIBLES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Todos definidos en ApiConfig:
- ApiConfig.loginEndpoint        → /api/auth/login
- ApiConfig.registerEndpoint     → /api/auth/register
- ApiConfig.verifyTokenEndpoint  → /api/auth/verify
- ApiConfig.usersEndpoint        → /api/users
- ApiConfig.wodsEndpoint         → /api/wods
- ApiConfig.clasesEndpoint       → /api/clases
- ApiConfig.inscripcionesEndpoint → /api/inscripciones
- ApiConfig.membershipsEndpoint  → /api/memberships
- ApiConfig.ejerciciosEndpoint   → /api/ejercicios
- ApiConfig.progressEndpoint     → /api/progress

✨ CARACTERÍSTICAS INCLUIDAS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Interceptor automático de tokens JWT
✓ Almacenamiento seguro de tokens (flutter_secure_storage)
✓ Manejo centralizado de errores HTTP
✓ Timeouts configurables
✓ Patrón Singleton para una única instancia de Dio

🧪 PRUEBA TU CONEXIÓN:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Verifica que tu servidor Node.js esté corriendo:
1. Terminal: flutter run
2. El app debería conectarse a tu API automáticamente
3. Revisa los logs para errores de conexión

❌ Si hay errores:
   - Verifica que la IP sea correcta
   - Comprueba que el puerto sea correcto (por defecto 3000)
   - Asegúrate de que el servidor Node.js esté encendido
   - En Android emulador, usa 10.0.2.2 en lugar de 127.0.0.1
