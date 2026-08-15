import 'syllabus_topic_entity.dart';

class SyllabusChapterGroup {
  const SyllabusChapterGroup({
    required this.chapterName,
    required this.topics,
    required this.completedCount,
  });

  final String chapterName;
  final List<SyllabusTopicEntity> topics;
  final int completedCount;

  double get progressPercentage =>
      topics.isEmpty ? 0 : (completedCount / topics.length) * 100;
}
