import 'package:flutter/material.dart';
import '../strings/strings.dart';

/// Get full name of the current month or for a given [date]
String getCurrentMonthName([DateTime? date]) {
  final target = date ?? DateTime.now();
  return fullMonths[target.month - 1];
}

/// Get month full name given 1-12
String getMonthName(int month) {
  if (month >= 1 && month <= 12) return fullMonths[month - 1];
  return '';
}

/// Format Date into readable string: e.g. "26 Sep 2026"
String formatDate(DateTime? date, {String fallback = 'N/A'}) {
  if (date == null) return fallback;
  return '${date.day} ${shortMonths[date.month - 1]} ${date.year}';
}

/// Format Date into short slash format: e.g. "26/09/2026"
String formatDateShort(DateTime? date, {String fallback = 'N/A'}) {
  if (date == null) return fallback;
  return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}

/// Format Date into verbose readable string e.g. "Wednesday, 14 Oct 2026"
String formatDateVerbose(DateTime? date, {String fallback = 'N/A'}) {
  if (date == null) return fallback;
  final weekday = weekdays[date.weekday - 1];
  final month = shortMonths[date.month - 1];
  return '$weekday, ${date.day} $month ${date.year}';
}

/// Format DateTime into 12-hour AM/PM string e.g. "09:30 AM"
String formatTime(DateTime? date, {String fallback = 'N/A'}) {
  if (date == null) return fallback;
  final hour =
      date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${hour.toString().padLeft(2, '0')}:$minute $period';
}

/// Format TimeOfDay into 12-hour AM/PM string e.g. "09:30 AM"
String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '${hour.toString().padLeft(2, '0')}:$minute $period';
}

/// Extension on [DateTime] for formatting utilities
extension DateFormattingExtension on DateTime {
  /// Format as readable date e.g. "26 Sep 2026"
  String toFormattedDate({String fallback = 'N/A'}) =>
      formatDate(this, fallback: fallback);

  /// Format as short slash date e.g. "26/09/2026"
  String toFormattedDateShort({String fallback = 'N/A'}) =>
      formatDateShort(this, fallback: fallback);

  /// Format as verbose date e.g. "Wednesday, 14 Oct 2026"
  String toFormattedDateVerbose({String fallback = 'N/A'}) =>
      formatDateVerbose(this, fallback: fallback);

  /// Format as 12-hour AM/PM time e.g. "09:30 AM"
  String toFormattedTime({String fallback = 'N/A'}) =>
      formatTime(this, fallback: fallback);

  /// Get month name
  String get monthFullName => getCurrentMonthName(this);
}
