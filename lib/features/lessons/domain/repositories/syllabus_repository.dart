import '../entities/batch_syllabus_progress.dart';
import '../entities/syllabus_chapter_group.dart';
import '../entities/syllabus_topic_entity.dart';

abstract class SyllabusRepository {
  Future<List<SyllabusTopicEntity>> getAllTopics();
  Future<List<SyllabusTopicEntity>> getTopicsByBatch(String batchId);
  Future<List<SyllabusTopicEntity>> getTopicsByIds(List<String> ids);
  Future<List<SyllabusChapterGroup>> getGroupedTopicsByBatch(String batchId);
  Future<SyllabusTopicEntity?> getTopicById(String id);
  Future<void> addTopic(SyllabusTopicEntity topic);
  Future<void> addBulkTopics(List<SyllabusTopicEntity> topics);
  Future<void> updateTopic(SyllabusTopicEntity topic);
  Future<void> toggleTopicCompletion(String topicId, bool isCompleted);
  Future<void> reorderTopics(String batchId, List<String> orderedIds);
  Future<void> deleteTopic(String id);
  Future<void> deleteTopicsByBatch(String batchId);
  Future<BatchSyllabusProgress> getBatchSyllabusProgress(String batchId);
  Future<int> getNextOrderIndex(String batchId);
}
