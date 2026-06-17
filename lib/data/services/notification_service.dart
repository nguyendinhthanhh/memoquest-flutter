import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'memoquest_reminders';
  static const _channelName = 'MemoQuest Reminders';
  static const _channelDescription = 'Daily study reminders';

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    try {
      await _plugin.initialize(settings: settings);
    } catch (_) {}
  }

  Future<void> requestPermissionIfNeeded() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {}
  }

  Future<void> showInstantNotification(String title, String body) async {
    try {
      await _plugin.show(
        id: 1001,
        title: title,
        body: body,
        notificationDetails: _notificationDetails(),
      );
    } catch (_) {}
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    try {
      await _plugin.cancel(id: 1002);
      // This currently uses the plugin's repeating daily interval API.
      await _plugin.periodicallyShow(
        id: 1002,
        title: 'MemoQuest Reminder',
        body: 'You have flashcards ready to review today.',
        repeatInterval: RepeatInterval.daily,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  NotificationDetails _notificationDetails() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );
    return const NotificationDetails(android: android);
  }
}
