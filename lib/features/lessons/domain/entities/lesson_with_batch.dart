import 'lesson_plan_entity.dart';
import 'syllabus_topic_entity.dart';
import '../../../batches/domain/entities/batch_entity.dart';

class LessonWithBatch {
  const LessonWithBatch({
    required this.lesson,
    required this.batch,
    this.coveredTopics = const [],
    this.hasAttendance = false,
    this.attendanceMarkedCount = 0,
  });

  final LessonPlanEntity lesson;
  final BatchEntity batch;
  final List<SyllabusTopicEntity> coveredTopics;
  final bool hasAttendance;
  final int attendanceMarkedCount;
}
