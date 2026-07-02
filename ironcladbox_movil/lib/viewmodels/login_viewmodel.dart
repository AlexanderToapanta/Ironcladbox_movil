import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// ViewModel para la pantalla de Login
/// Maneja la lógica de autenticación
class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentRole = 'athlete';
  
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get currentRole => _currentRole;
  
  /// Realizar login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final session = await _authService.login(
        email: email,
        password: password,
      );
      
      if (session.token.isNotEmpty) {
        _currentRole = session.role;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      final raw = e.toString();
      _errorMessage = raw.replaceFirst('Exception: ', '');
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Cerrar sesión y limpiar el estado local
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();

    _currentRole = 'athlete';
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }
  
  /// Limpiar mensajes de error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
