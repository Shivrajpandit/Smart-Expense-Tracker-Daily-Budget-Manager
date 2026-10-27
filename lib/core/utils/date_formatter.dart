import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dayMonthYear = DateFormat('dd MMM yyyy');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _shortMonthYear = DateFormat('MMM yyyy');
  static final DateFormat _dayOfWeek = DateFormat('EEEE');
  static final DateFormat _time12h = DateFormat('hh:mm a');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  static String formatDate(DateTime date) {
    return _dayMonthYear.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  static String formatShortMonthYear(DateTime date) {
    return _shortMonthYear.format(date);
  }

  static String formatDayOfWeek(DateTime date) {
    return _dayOfWeek.format(date);
  }

  static String formatTime(DateTime date) {
    return _time12h.format(date);
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return _time12h.format(dt);
  }

  static String toIsoDate(DateTime date) {
    return _isoDate.format(date);
  }

  static String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = today.difference(target).inDays;
    if (diff == 0) {
      return 'Today';
    } else if (diff == 1) {
      return 'Yesterday';
    } else if (diff == -1) {
      return 'Tomorrow';
    } else if (diff > 1 && diff <= 6) {
      return DateFormat('EEEE').format(date);
    } else {
      return _dayMonthYear.format(date);
    }
  }

  /// Normalizes a DateTime to start of day (00:00:00)
  static DateTime startOfDay(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  /// Normalizes a DateTime to end of day (23:59:59.999)
  static DateTime endOfDay(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);
  }
}
