import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required this.settingsRepository,
    required this.notificationService,
  });

  final SettingsRepository settingsRepository;
  final NotificationService notificationService;

  bool darkMode = false;
  bool notificationEnabled = true;
  String reminderTime = AppConstants.defaultReminderTime;
  bool isLoading = false;

  Future<void> loadSettings() async {
    isLoading = true;
    notifyListeners();
    try {
      darkMode = await settingsRepository.getDarkMode();
      notificationEnabled = await settingsRepository.getNotificationEnabled();
      reminderTime =
          await settingsRepository.getReminderTime() ??
          AppConstants.defaultReminderTime;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    await settingsRepository.setDarkMode(value);
  }

  Future<void> toggleNotification(bool value) async {
    notificationEnabled = value;
    notifyListeners();
    await settingsRepository.setNotificationEnabled(value);
    if (value) {
      await notificationService.requestPermissionIfNeeded();
      final time = _parseReminderTime(reminderTime);
      await notificationService.scheduleDailyReminder(
        hour: time.$1,
        minute: time.$2,
      );
    } else {
      await notificationService.cancelAllNotifications();
    }
  }

  Future<void> updateReminderTime(String time) async {
    reminderTime = time;
    notifyListeners();
    await settingsRepository.setReminderTime(time);
    if (notificationEnabled) {
      final parsedTime = _parseReminderTime(time);
      await notificationService.scheduleDailyReminder(
        hour: parsedTime.$1,
        minute: parsedTime.$2,
      );
    }
  }

  Future<void> clearAllData() async {
    await settingsRepository.clearAllData();
  }

  Future<void> restoreSampleData() async {
    await settingsRepository.restoreSampleData();
  }

  Future<void> testNotification() async {
    await notificationService.showInstantNotification(
      'MemoQuest Reminder',
      'You have flashcards ready to review today.',
    );
  }

  (int, int) _parseReminderTime(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 19;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return (hour, minute);
  }
}
