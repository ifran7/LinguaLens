import 'package:hive/hive.dart';

import '../../data/models/lesson_plan_model.dart';
import '../../data/models/syllabus_topic_model.dart';
import '../../domain/entities/batch_syllabus_progress.dart';
import '../../domain/entities/lesson_status.dart';
import '../../domain/entities/syllabus_chapter_group.dart';
import '../../domain/entities/syllabus_topic_entity.dart';
import '../../domain/repositories/syllabus_repository.dart';

class SyllabusRepositoryImpl implements SyllabusRepository {
  Box<SyllabusTopicModel> get _box =>
      Hive.box<SyllabusTopicModel>('syllabusTopicsBox');

  Box<LessonPlanModel> get _lessonBox =>
      Hive.box<LessonPlanModel>('lessonsBox');

  @override
  Future<List<SyllabusTopicEntity>> getAllTopics() async {
    final topics = _box.values.map(SyllabusTopicEntity.fromModel).toList();
    topics.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return topics;
  }

  @override
  Future<List<SyllabusTopicEntity>> getTopicsByBatch(String batchId) async {
    final topics = (await getAllTopics())
        .where((topic) => topic.batchId == batchId)
        .toList();
    topics.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return topics;
  }

  @override
  Future<List<SyllabusTopicEntity>> getTopicsByIds(List<String> ids) async {
    final byId = <String, SyllabusTopicEntity>{
      for (final topic in await getAllTopics()) topic.id: topic,
    };
    return ids.map((id) => byId[id]).whereType<SyllabusTopicEntity>().toList();
  }

  @override
  Future<List<SyllabusChapterGroup>> getGroupedTopicsByBatch(
    String batchId,
  ) async {
    final topics = await getTopicsByBatch(batchId);
    final grouped = <String, List<SyllabusTopicEntity>>{};
    for (final topic in topics) {
      grouped.putIfAbsent(topic.chapterName.trim(), () => []).add(topic);
    }
    final groups = grouped.entries.map((entry) {
      final groupTopics = entry.value
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return SyllabusChapterGroup(
        chapterName: entry.key,
        topics: List.unmodifiable(groupTopics),
        completedCount: groupTopics.where((topic) => topic.isCompleted).length,
      );
    }).toList();
    groups.sort((a, b) {
      final aIndex = a.topics.isEmpty ? 0 : a.topics.first.orderIndex;
      final bIndex = b.topics.isEmpty ? 0 : b.topics.first.orderIndex;
      return aIndex.compareTo(bIndex);
    });
    return groups;
  }

  @override
  Future<SyllabusTopicEntity?> getTopicById(String id) async {
    final model = _box.get(id);
    return model == null ? null : SyllabusTopicEntity.fromModel(model);
  }

  @override
  Future<void> addTopic(SyllabusTopicEntity topic) async {
    final existing = await getTopicsByBatch(topic.batchId);
    final shouldAssign =
        topic.orderIndex < 0 || (topic.orderIndex == 0 && existing.isNotEmpty);
    final now = DateTime.now();
    final normalized = topic.copyWith(
      orderIndex: shouldAssign
          ? await getNextOrderIndex(topic.batchId)
          : topic.orderIndex,
      estimatedClasses: topic.estimatedClasses < 1 ? 1 : topic.estimatedClasses,
      updatedAt: now,
    );
    await _box.put(normalized.id, normalized.toModel());
  }

  @override
  Future<void> addBulkTopics(List<SyllabusTopicEntity> topics) async {
    if (topics.isEmpty) return;
    var nextIndex = await getNextOrderIndex(topics.first.batchId);
    final now = DateTime.now();
    for (final topic in topics) {
      final normalized = topic.copyWith(
        orderIndex: nextIndex++,
        estimatedClasses: topic.estimatedClasses < 1
            ? 1
            : topic.estimatedClasses,
        updatedAt: now,
      );
      await _box.put(normalized.id, normalized.toModel());
    }
  }

  @override
  Future<void> updateTopic(SyllabusTopicEntity topic) async {
    final normalized = topic.copyWith(
      estimatedClasses: topic.estimatedClasses < 1 ? 1 : topic.estimatedClasses,
      updatedAt: DateTime.now(),
    );
    await _box.put(normalized.id, normalized.toModel());
  }

  @override
  Future<void> toggleTopicCompletion(String topicId, bool isCompleted) async {
    final topic = await getTopicById(topicId);
    if (topic == null) return;
    final now = DateTime.now();
    await updateTopic(
      topic.copyWith(
        isCompleted: isCompleted,
        completedDate: isCompleted ? now : null,
        clearCompletedDate: !isCompleted,
      ),
    );
  }

  @override
  Future<void> reorderTopics(String batchId, List<String> orderedIds) async {
    var order = 0;
    for (final id in orderedIds) {
      final topic = await getTopicById(id);
      if (topic == null || topic.batchId != batchId) continue;
      await updateTopic(topic.copyWith(orderIndex: order++));
    }
  }

  @override
  Future<void> deleteTopic(String id) async => _box.delete(id);

  @override
  Future<void> deleteTopicsByBatch(String batchId) async {
    final keys = _box.values
        .where((topic) => topic.batchId == batchId)
        .map((topic) => topic.key)
        .toList();
    await _box.deleteAll(keys);
  }

  @override
  Future<BatchSyllabusProgress> getBatchSyllabusProgress(String batchId) async {
    final topics = await getTopicsByBatch(batchId);
    final completedLessons = _lessonBox.values
        .where(
          (lesson) =>
              lesson.batchId == batchId &&
              lesson.status == LessonStatus.completed.value,
        )
        .length;
    return BatchSyllabusProgress(
      batchId: batchId,
      totalTopics: topics.length,
      completedTopics: topics.where((topic) => topic.isCompleted).length,
      totalEstimatedClasses: topics.fold<int>(
        0,
        (total, topic) => total + topic.estimatedClasses,
      ),
      completedLessonCount: completedLessons,
    );
  }

  @override
  Future<int> getNextOrderIndex(String batchId) async {
    final topics = await getTopicsByBatch(batchId);
    if (topics.isEmpty) return 0;
    return topics
            .map((topic) => topic.orderIndex)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }
}
