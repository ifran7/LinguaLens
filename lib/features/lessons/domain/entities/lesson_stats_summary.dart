class LessonStatsSummary {
  const LessonStatsSummary({
    this.totalLessons = 0,
    this.plannedCount = 0,
    this.completedCount = 0,
    this.skippedCount = 0,
    this.postponedCount = 0,
    this.todayLessonCount = 0,
    this.upcomingLessonCount = 0,
  });

  final int totalLessons;
  final int plannedCount;
  final int completedCount;
  final int skippedCount;
  final int postponedCount;
  final int todayLessonCount;
  final int upcomingLessonCount;
}
