import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SocketService _socketService = SocketService();
  
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentRole = 'athlete';
  
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get currentRole => _currentRole;
  
  void setRole(String role) {
    _currentRole = role;
    notifyListeners();
  }

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
        _socketService.connect();
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

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    _socketService.disconnect();
    await _authService.logout();

    _currentRole = 'athlete';
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
