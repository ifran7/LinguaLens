import '../entities/lesson_plan_entity.dart';
import '../entities/lesson_stats_summary.dart';
import '../entities/lesson_status.dart';
import '../entities/lesson_type.dart';

abstract class LessonRepository {
  Future<List<LessonPlanEntity>> getAllLessons();
  Future<List<LessonPlanEntity>> getLessonsByBatch(String batchId);
  Future<List<LessonPlanEntity>> getLessonsByDate(DateTime date);
  Future<List<LessonPlanEntity>> getLessonsByBatchAndDate(
    String batchId,
    DateTime date,
  );
  Future<List<LessonPlanEntity>> getLessonsByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<LessonPlanEntity>> getLessonsByType(LessonType type);
  Future<List<LessonPlanEntity>> getLessonsByStatus(LessonStatus status);
  Future<List<LessonPlanEntity>> getTodayLessons();
  Future<List<LessonPlanEntity>> getUpcomingLessons(int limit);
  Future<LessonPlanEntity?> getLessonById(String id);
  Future<void> addLesson(LessonPlanEntity lesson);
  Future<void> updateLesson(LessonPlanEntity lesson);
  Future<void> updateLessonStatus(String lessonId, LessonStatus status);
  Future<void> deleteLesson(String id);
  Future<void> deleteLessonsByBatch(String batchId);
  Future<void> duplicateLesson(String lessonId, DateTime newDate);
  Future<LessonStatsSummary> getLessonStats();
  Future<LessonStatsSummary> getLessonStatsByBatch(String batchId);
  Future<int> getCompletedLessonCountByBatch(String batchId);
}
