import '../../core/constants/app_constants.dart';
import '../database/database_helper.dart';
import '../services/shared_prefs_service.dart';

class SettingsRepository {
  SettingsRepository({
    required this.sharedPrefsService,
    required this.databaseHelper,
  });

  final SharedPrefsService sharedPrefsService;
  final DatabaseHelper databaseHelper;

  Future<bool> getDarkMode() => sharedPrefsService.getDarkMode();

  Future<void> setDarkMode(bool value) => sharedPrefsService.setDarkMode(value);

  Future<bool> getNotificationEnabled() =>
      sharedPrefsService.getNotificationEnabled();

  Future<void> setNotificationEnabled(bool value) =>
      sharedPrefsService.setNotificationEnabled(value);

  Future<String?> getReminderTime() => sharedPrefsService.getReminderTime();

  Future<void> setReminderTime(String value) =>
      sharedPrefsService.setReminderTime(value);

  Future<void> clearAllData() async {
    await databaseHelper.clearUserData();
    await sharedPrefsService.setFirstLaunch(false);
    await sharedPrefsService.setReminderTime(AppConstants.defaultReminderTime);
  }

  Future<void> restoreSampleData() async {
    await databaseHelper.restoreSampleData(sharedPrefsService);
    await sharedPrefsService.setReminderTime(AppConstants.defaultReminderTime);
  }
}
