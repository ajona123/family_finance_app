import 'package:intl/intl.dart';

class DateHelper {
  /// Format date as "d MMMM yyyy" (e.g., "15 Desember 2024")
  static String formatDate(DateTime date, {String locale = 'id_ID'}) {
    try {
      final format = DateFormat('d MMMM yyyy', locale);
      return format.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  /// Format date as "EEEE, d MMMM yyyy" (e.g., "Minggu, 15 Desember 2024")
  static String formatDateLong(DateTime date, {String locale = 'id_ID'}) {
    try {
      final format = DateFormat('EEEE, d MMMM yyyy', locale);
      return format.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  /// Format date as short date (e.g., "15/12/24")
  static String formatDateShort(DateTime date) {
    try {
      final format = DateFormat('dd/MM/yy');
      return format.format(date);
    } catch (e) {
      return date.toString();
    }
  }

  /// Format time as "HH:mm" (e.g., "14:30")
  static String formatTime(DateTime dateTime) {
    try {
      final format = DateFormat('HH:mm');
      return format.format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }

  /// Format date and time as "d MMMM yyyy HH:mm"
  static String formatDateTime(DateTime dateTime, {String locale = 'id_ID'}) {
    try {
      final format = DateFormat('d MMMM yyyy HH:mm', locale);
      return format.format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get start of month (first day at 00:00:00)
  static DateTime getStartOfMonth([DateTime? date]) {
    date ??= DateTime.now();
    return DateTime(date.year, date.month, 1, 0, 0, 0);
  }

  /// Get end of month (last day at 23:59:59)
  static DateTime getEndOfMonth([DateTime? date]) {
    date ??= DateTime.now();
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Get start of day (00:00:00)
  static DateTime getStartOfDay([DateTime? date]) {
    date ??= DateTime.now();
    return DateTime(date.year, date.month, date.day, 0, 0, 0);
  }

  /// Get end of day (23:59:59)
  static DateTime getEndOfDay([DateTime? date]) {
    date ??= DateTime.now();
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of week (Monday 00:00:00)
  static DateTime getStartOfWeek([DateTime? date]) {
    date ??= DateTime.now();
    final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day, 0, 0, 0);
  }

  /// Get end of week (Sunday 23:59:59)
  static DateTime getEndOfWeek([DateTime? date]) {
    date ??= DateTime.now();
    final lastDayOfWeek = date.add(Duration(days: DateTime.sunday - date.weekday));
    return DateTime(lastDayOfWeek.year, lastDayOfWeek.month, lastDayOfWeek.day, 23, 59, 59);
  }

  /// Get number of days in month
  static int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Get difference in days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays;
  }

  /// Add months to date
  static DateTime addMonths(DateTime date, int months) {
    final newMonth = date.month + months;
    var newYear = date.year;
    
    if (newMonth > 12) {
      newYear += (newMonth - 1) ~/ 12;
    }
    
    final finalMonth = ((newMonth - 1) % 12) + 1;
    final maxDay = DateTime(newYear, finalMonth + 1, 0).day;
    final day = date.day > maxDay ? maxDay : date.day;
    
    return DateTime(newYear, finalMonth, day, date.hour, date.minute, date.second);
  }

  /// Subtract months from date
  static DateTime subtractMonths(DateTime date, int months) {
    return addMonths(date, -months);
  }
}
