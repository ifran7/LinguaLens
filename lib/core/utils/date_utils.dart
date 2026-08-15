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
