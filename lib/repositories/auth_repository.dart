import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<void> resetPassword(String email) {
    return _authService.resetPassword(email);
  }

  Future<void> login({
    required String email,
    required String password,
  }) {
    return _authService.login(
      email: email,
      password: password,
    );
  }

  Future<void> register({
    required String email,
    required String password,
  }) {
    return _authService.register(
      email: email,
      password: password,
    );
  }

  Future<void> logout() {
    return _authService.logout();
  }
}