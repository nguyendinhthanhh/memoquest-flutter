import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class SharedPrefsService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> setLoggedIn(bool value) async {
    await _prefs!.setBool(AppConstants.isLoggedInKey, value);
  }

  Future<bool> getLoggedIn() async {
    return _prefs!.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  Future<void> setUserEmail(String value) async {
    await _prefs!.setString(AppConstants.userEmailKey, value);
  }

  Future<String?> getUserEmail() async {
    return _prefs!.getString(AppConstants.userEmailKey);
  }

  Future<void> clearUserEmail() async {
    await _prefs!.remove(AppConstants.userEmailKey);
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs!.setBool(AppConstants.darkModeKey, value);
  }

  Future<bool> getDarkMode() async {
    return _prefs!.getBool(AppConstants.darkModeKey) ?? false;
  }

  Future<void> setNotificationEnabled(bool value) async {
    await _prefs!.setBool(AppConstants.notificationEnabledKey, value);
  }

  Future<bool> getNotificationEnabled() async {
    return _prefs!.getBool(AppConstants.notificationEnabledKey) ?? true;
  }

  Future<void> setReminderTime(String value) async {
    await _prefs!.setString(AppConstants.reminderTimeKey, value);
  }

  Future<String?> getReminderTime() async {
    return _prefs!.getString(AppConstants.reminderTimeKey);
  }

  Future<void> setFirstLaunch(bool value) async {
    await _prefs!.setBool(AppConstants.firstLaunchKey, value);
  }

  Future<bool> getFirstLaunch() async {
    return _prefs!.getBool(AppConstants.firstLaunchKey) ?? true;
  }
}
