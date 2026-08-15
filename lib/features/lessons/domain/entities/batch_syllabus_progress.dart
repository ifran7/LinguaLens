class BatchSyllabusProgress {
  const BatchSyllabusProgress({
    required this.batchId,
    required this.totalTopics,
    required this.completedTopics,
    required this.totalEstimatedClasses,
    required this.completedLessonCount,
  });

  final String batchId;
  final int totalTopics;
  final int completedTopics;
  final int totalEstimatedClasses;
  final int completedLessonCount;

  int get remainingTopics =>
      (totalTopics - completedTopics).clamp(0, totalTopics);
  double get progressPercentage =>
      totalTopics == 0 ? 0 : (completedTopics / totalTopics) * 100;
}
