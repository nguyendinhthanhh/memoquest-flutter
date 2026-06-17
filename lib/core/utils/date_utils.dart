import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatDateTime(DateTime dateTime) =>
      _dateTimeFormat.format(dateTime);

  static DateTime normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isYesterday(DateTime lastStudyDate, DateTime today) {
    return normalize(today)
            .difference(normalize(lastStudyDate))
            .inDays ==
        1;
  }

  static String formatTimeOfDay(int hour, int minute) {
    final hourString = hour.toString().padLeft(2, '0');
    final minuteString = minute.toString().padLeft(2, '0');
    return '$hourString:$minuteString';
  }
}
