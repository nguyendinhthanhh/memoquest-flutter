import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  bool isLoading = false;
  bool isLoggedIn = false;
  String? errorMessage;
  String? currentUserEmail;

  Future<void> checkAuthStatus() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      isLoggedIn = await _authRepository.isLoggedIn();
      currentUserEmail = await _authRepository.getCurrentUserEmail();
    } catch (_) {
      errorMessage = 'Unable to check the login session.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.login(email, password);
      if (!result) {
        errorMessage = 'Incorrect email or password.';
        return false;
      }

      isLoggedIn = true;
      currentUserEmail = await _authRepository.getCurrentUserEmail();
      return true;
    } catch (_) {
      errorMessage = 'Unable to sign in. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();
    try {
      await _authRepository.logout();
      isLoggedIn = false;
      currentUserEmail = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
