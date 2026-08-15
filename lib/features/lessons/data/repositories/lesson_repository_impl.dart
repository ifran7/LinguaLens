import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/date_utils.dart';
import '../../data/models/lesson_plan_model.dart';
import '../../domain/entities/lesson_plan_entity.dart';
import '../../domain/entities/lesson_stats_summary.dart';
import '../../domain/entities/lesson_status.dart';
import '../../domain/entities/lesson_type.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../../domain/repositories/syllabus_repository.dart';

class LessonRepositoryImpl implements LessonRepository {
  LessonRepositoryImpl(this.syllabusRepository);

  final SyllabusRepository syllabusRepository;
  final Uuid _uuid = const Uuid();

  Box<LessonPlanModel> get _box => Hive.box<LessonPlanModel>('lessonsBox');

  List<LessonPlanEntity> _allSorted({bool descending = true}) {
    final lessons = _box.values.map(LessonPlanEntity.fromModel).toList();
    lessons.sort((a, b) {
      final byDate = a.lessonDate.compareTo(b.lessonDate);
      if (byDate != 0) return descending ? -byDate : byDate;
      final byCreated = a.createdAt.compareTo(b.createdAt);
      return descending ? -byCreated : byCreated;
    });
    return lessons;
  }

  @override
  Future<List<LessonPlanEntity>> getAllLessons() async => _allSorted();

  @override
  Future<List<LessonPlanEntity>> getLessonsByBatch(String batchId) async =>
      _allSorted().where((lesson) => lesson.batchId == batchId).toList();

  @override
  Future<List<LessonPlanEntity>> getLessonsByDate(DateTime date) async {
    final normalized = normalizeDate(date);
    final lessons = _allSorted(descending: false)
        .where((lesson) => isSameNormalizedDate(lesson.lessonDate, normalized))
        .toList();
    lessons.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return lessons;
  }

  @override
  Future<List<LessonPlanEntity>> getLessonsByBatchAndDate(
    String batchId,
    DateTime date,
  ) async =>
      (await getLessonsByDate(date))
          .where((lesson) => lesson.batchId == batchId)
          .toList();

  @override
  Future<List<LessonPlanEntity>> getLessonsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final from = normalizeDate(start);
    final to = normalizeDate(end);
    return _allSorted(descending: false).where((lesson) {
      return !lesson.lessonDate.isBefore(from) &&
          !lesson.lessonDate.isAfter(to);
    }).toList();
  }

  @override
  Future<List<LessonPlanEntity>> getLessonsByType(LessonType type) async =>
      _allSorted().where((lesson) => lesson.type == type).toList();

  @override
  Future<List<LessonPlanEntity>> getLessonsByStatus(
    LessonStatus status,
  ) async =>
      _allSorted().where((lesson) => lesson.lessonStatus == status).toList();

  @override
  Future<List<LessonPlanEntity>> getTodayLessons() =>
      getLessonsByDate(DateTime.now());

  @override
  Future<List<LessonPlanEntity>> getUpcomingLessons(int limit) async {
    final today = normalizeDate(DateTime.now());
    final lessons = _allSorted(descending: false)
        .where(
          (lesson) =>
              lesson.lessonDate.isAfter(today) &&
              lesson.lessonStatus == LessonStatus.planned,
        )
        .toList();
    return lessons.take(limit).toList();
  }

  @override
  Future<LessonPlanEntity?> getLessonById(String id) async {
    final model = _box.get(id);
    return model == null ? null : LessonPlanEntity.fromModel(model);
  }

  @override
  Future<void> addLesson(LessonPlanEntity lesson) async {
    final normalized = lesson.copyWith(
      lessonDate: normalizeDate(lesson.lessonDate),
    );
    await _box.put(normalized.id, normalized.toModel());
    if (normalized.lessonStatus == LessonStatus.completed) {
      await _markTopicsCompleted(normalized.coveredTopicIds);
    }
  }

  @override
  Future<void> updateLesson(LessonPlanEntity lesson) async {
    final previous = await getLessonById(lesson.id);
    final updated = lesson.copyWith(
      lessonDate: normalizeDate(lesson.lessonDate),
      updatedAt: DateTime.now(),
    );
    await _box.put(updated.id, updated.toModel());

    if (updated.lessonStatus == LessonStatus.completed) {
      await _markTopicsCompleted(updated.coveredTopicIds);
    }
    if (previous != null && previous.lessonStatus == LessonStatus.completed) {
      final removedIds = previous.coveredTopicIds
          .where((id) => !updated.coveredTopicIds.contains(id))
          .toList();
      if (updated.lessonStatus != LessonStatus.completed) {
        await _reevaluateTopics(previous.coveredTopicIds);
      } else if (removedIds.isNotEmpty) {
        await _reevaluateTopics(removedIds);
      }
    }
  }

  @override
  Future<void> updateLessonStatus(String lessonId, LessonStatus status) async {
    final lesson = await getLessonById(lessonId);
    if (lesson == null) return;
    await updateLesson(lesson.copyWith(status: status.value));
  }

  @override
  Future<void> deleteLesson(String id) async {
    final lesson = await getLessonById(id);
    await _box.delete(id);
    if (lesson?.lessonStatus == LessonStatus.completed) {
      await _reevaluateTopics(lesson!.coveredTopicIds);
    }
  }

  @override
  Future<void> deleteLessonsByBatch(String batchId) async {
    final keys = _box.values
        .where((lesson) => lesson.batchId == batchId)
        .map((lesson) => lesson.key)
        .toList();
    await _box.deleteAll(keys);
  }

  @override
  Future<void> duplicateLesson(String lessonId, DateTime newDate) async {
    final lesson = await getLessonById(lessonId);
    if (lesson == null) return;
    final now = DateTime.now();
    await addLesson(
      lesson.copyWith(
        id: _uuid.v4(),
        lessonDate: normalizeDate(newDate),
        status: LessonStatus.planned.value,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<LessonStatsSummary> getLessonStats() async => _stats(_allSorted());

  @override
  Future<LessonStatsSummary> getLessonStatsByBatch(String batchId) async =>
      _stats((await getLessonsByBatch(batchId)));

  @override
  Future<int> getCompletedLessonCountByBatch(String batchId) async =>
      (await getLessonsByBatch(batchId))
          .where((lesson) => lesson.lessonStatus == LessonStatus.completed)
          .length;

  LessonStatsSummary _stats(List<LessonPlanEntity> lessons) {
    final today = normalizeDate(DateTime.now());
    return LessonStatsSummary(
      totalLessons: lessons.length,
      plannedCount: lessons
          .where((item) => item.lessonStatus == LessonStatus.planned)
          .length,
      completedCount: lessons
          .where((item) => item.lessonStatus == LessonStatus.completed)
          .length,
      skippedCount: lessons
          .where((item) => item.lessonStatus == LessonStatus.skipped)
          .length,
      postponedCount: lessons
          .where((item) => item.lessonStatus == LessonStatus.postponed)
          .length,
      todayLessonCount: lessons
          .where((item) => isSameNormalizedDate(item.lessonDate, today))
          .length,
      upcomingLessonCount: lessons
          .where(
            (item) =>
                item.lessonDate.isAfter(today) &&
                item.lessonStatus == LessonStatus.planned,
          )
          .length,
    );
  }

  Future<void> _markTopicsCompleted(List<String> topicIds) async {
    for (final topicId in topicIds) {
      await syllabusRepository.toggleTopicCompletion(topicId, true);
    }
  }

  Future<void> _reevaluateTopics(List<String> topicIds) async {
    final lessons = await getAllLessons();
    for (final topicId in topicIds.toSet()) {
      final isCovered = lessons.any(
        (lesson) =>
            lesson.lessonStatus == LessonStatus.completed &&
            lesson.coveredTopicIds.contains(topicId),
      );
      if (!isCovered) {
        await syllabusRepository.toggleTopicCompletion(topicId, false);
      }
    }
  }
}
