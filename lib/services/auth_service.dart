import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _disposed = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  // Inicializar serviço
  Future<void> init() async {
    await ApiService.init();
    await _checkAuthStatus();
  }

  // Verificar status de autenticação
  Future<void> _checkAuthStatus() async {
    try {
      final response = await ApiService.verifyToken();
      if (response['success']) {
        _user = User.fromJson(response['data']['user']);
        _isAuthenticated = true;
        if (!_disposed) {
          notifyListeners();
        }
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _setLoading(true);

    try {
      final response = await ApiService.login(username, password);

      if (response['success']) {
        _user = User.fromJson(response['data']['user']);
        _isAuthenticated = true;
        if (!_disposed) {
          notifyListeners();
        }
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Erro no login: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await ApiService.logout();
    } catch (e) {
      debugPrint('Erro no logout: $e');
    } finally {
      _user = null;
      _isAuthenticated = false;
      _setLoading(false);
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  // Atualizar dados do usuário
  void updateUser(User user) {
    _user = user;
    if (!_disposed) {
      notifyListeners();
    }
  }

  // Definir estado de loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
