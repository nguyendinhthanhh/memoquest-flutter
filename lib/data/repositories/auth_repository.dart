import '../../core/constants/app_constants.dart';
import '../services/shared_prefs_service.dart';

class AuthRepository {
  AuthRepository(this._prefsService);

  final SharedPrefsService _prefsService;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final isValid = email.trim() == AppConstants.mockEmail &&
        password.trim() == AppConstants.mockPassword;

    if (isValid) {
      await _prefsService.setLoggedIn(true);
      await _prefsService.setUserEmail(email.trim());
    }

    return isValid;
  }

  Future<void> logout() async {
    await _prefsService.setLoggedIn(false);
    await _prefsService.clearUserEmail();
  }

  Future<bool> isLoggedIn() => _prefsService.getLoggedIn();

  Future<String?> getCurrentUserEmail() => _prefsService.getUserEmail();
}
