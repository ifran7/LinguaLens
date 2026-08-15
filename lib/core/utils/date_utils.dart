import 'package:intl/intl.dart';

DateTime normalizeDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

String formatDayMonthYear(DateTime date) =>
    DateFormat('dd MMM yyyy').format(normalizeDate(date));

String formatMonthYear(DateTime date) =>
    DateFormat('MMMM yyyy').format(normalizeDate(date));

String formatShortWeekdayDate(DateTime date) =>
    DateFormat('EEE, dd MMM').format(normalizeDate(date));

String dateKey(DateTime date) =>
    DateFormat('yyyy-MM-dd').format(normalizeDate(date));

bool isSameNormalizedDate(DateTime a, DateTime b) => dateKey(a) == dateKey(b);

String monthKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}';

DateTime monthKeyToDate(String key) {
  final parts = key.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]));
}

String formatMonthKeyDisplay(String key) =>
    DateFormat('MMMM yyyy').format(monthKeyToDate(key));

DateTime monthStart(String key) => monthKeyToDate(key);

DateTime monthEnd(String key) {
  final start = monthKeyToDate(key);
  return DateTime(start.year, start.month + 1, 0);
}

DateTime startOfWeek(DateTime date) {
  final normalized = normalizeDate(date);
  final daysSinceSaturday = (normalized.weekday % 7);
  return normalized.subtract(Duration(days: daysSinceSaturday));
}

DateTime endOfWeek(DateTime date) =>
    startOfWeek(date).add(const Duration(days: 6));

DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

DateTime endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);

String formatWeekRange(DateTime date) {
  final start = startOfWeek(date);
  final end = endOfWeek(date);
  if (start.year == end.year && start.month == end.month) {
    return '${DateFormat('dd').format(start)}–${DateFormat('dd MMM yyyy').format(end)}';
  }
  return '${DateFormat('dd MMM').format(start)}–${DateFormat('dd MMM yyyy').format(end)}';
}

String formatFullDate(DateTime date) =>
    DateFormat('EEEE, d MMMM yyyy').format(normalizeDate(date));
