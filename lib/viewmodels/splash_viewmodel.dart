import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SocketService _socketService = SocketService();
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _hasSession = false;
  String _role = 'athlete';
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  bool get hasSession => _hasSession;
  String get role => _role;
  String get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _hasSession = await _authService.verifyToken();
      if (_hasSession) {
        _role = (await _authService.getRole()) ?? 'athlete';
        _socketService.connect();
        _apiService.drainQueue();
      }
    } catch (e) {
      _hasSession = false;
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
