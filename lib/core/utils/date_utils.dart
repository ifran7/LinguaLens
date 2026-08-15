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
