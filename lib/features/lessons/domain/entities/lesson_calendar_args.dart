import '../../../../core/utils/date_utils.dart';

class LessonCalendarArgs {
  const LessonCalendarArgs({
    required this.startDate,
    required this.endDate,
    this.batchId,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String? batchId;

  DateTime get normalizedStart => normalizeDate(startDate);
  DateTime get normalizedEnd => normalizeDate(endDate);

  @override
  bool operator ==(Object other) =>
      other is LessonCalendarArgs &&
      dateKey(other.normalizedStart) == dateKey(normalizedStart) &&
      dateKey(other.normalizedEnd) == dateKey(normalizedEnd) &&
      other.batchId == batchId;

  @override
  int get hashCode =>
      Object.hash(dateKey(normalizedStart), dateKey(normalizedEnd), batchId);
}
