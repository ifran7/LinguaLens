import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/date_utils.dart';
import '../../attendance/providers/attendance_provider.dart';
import '../../batches/providers/batch_provider.dart';
import '../data/repositories/lesson_repository_impl.dart';
import '../data/repositories/syllabus_repository_impl.dart';
import '../domain/entities/batch_syllabus_progress.dart';
import '../domain/entities/lesson_calendar_args.dart';
import '../domain/entities/lesson_plan_entity.dart';
import '../domain/entities/lesson_stats_summary.dart';
import '../domain/entities/lesson_status.dart';
import '../domain/entities/lesson_with_batch.dart';
import '../domain/entities/syllabus_chapter_group.dart';
import '../domain/entities/syllabus_topic_entity.dart';
import '../domain/repositories/lesson_repository.dart';
import '../domain/repositories/syllabus_repository.dart';

final syllabusRepositoryProvider = Provider<SyllabusRepository>(
  (ref) => SyllabusRepositoryImpl(),
);

final lessonRepositoryProvider = Provider<LessonRepository>(
  (ref) => LessonRepositoryImpl(ref.read(syllabusRepositoryProvider)),
);

Future<List<LessonWithBatch>> _composeLessons(
  Ref ref,
  List<LessonPlanEntity> lessons,
) async {
  final batches = await ref.read(batchRepositoryProvider).getAllBatches();
  final batchesById = {for (final batch in batches) batch.id: batch};
  final attendanceRepo = ref.read(attendanceRepositoryProvider);
  final syllabusRepo = ref.read(syllabusRepositoryProvider);
  final result = <LessonWithBatch>[];
  for (final lesson in lessons) {
    final batch = batchesById[lesson.batchId];
    if (batch == null) continue;
    final attendance = await attendanceRepo.getAttendanceByBatchAndDate(
      lesson.batchId,
      lesson.lessonDate,
    );
    final topics = await syllabusRepo.getTopicsByIds(lesson.coveredTopicIds);
    result.add(
      LessonWithBatch(
        lesson: lesson,
        batch: batch,
        coveredTopics: topics,
        hasAttendance: attendance.isNotEmpty,
        attendanceMarkedCount: attendance.length,
      ),
    );
  }
  return result;
}

final batchLessonsProvider =
    FutureProvider.family<List<LessonWithBatch>, String>((ref, batchId) async {
      final lessons = await ref
          .read(lessonRepositoryProvider)
          .getLessonsByBatch(batchId);
      return _composeLessons(ref, lessons);
    });

final batchSyllabusProvider =
    FutureProvider.family<List<SyllabusTopicEntity>, String>(
      (ref, batchId) =>
          ref.read(syllabusRepositoryProvider).getTopicsByBatch(batchId),
    );

final batchSyllabusGroupsProvider =
    FutureProvider.family<List<SyllabusChapterGroup>, String>(
      (ref, batchId) =>
          ref.read(syllabusRepositoryProvider).getGroupedTopicsByBatch(batchId),
    );

final batchSyllabusProgressProvider =
    FutureProvider.family<BatchSyllabusProgress, String>(
      (ref, batchId) => ref
          .read(syllabusRepositoryProvider)
          .getBatchSyllabusProgress(batchId),
    );

final lessonDetailProvider = FutureProvider.family<LessonWithBatch?, String>((
  ref,
  lessonId,
) async {
  final lesson = await ref
      .read(lessonRepositoryProvider)
      .getLessonById(lessonId);
  if (lesson == null) return null;
  final composed = await _composeLessons(ref, [lesson]);
  return composed.isEmpty ? null : composed.first;
});

final todayLessonsProvider = FutureProvider<List<LessonWithBatch>>(
  (ref) async => _composeLessons(
    ref,
    await ref.read(lessonRepositoryProvider).getTodayLessons(),
  ),
);

final upcomingLessonsProvider = FutureProvider<List<LessonWithBatch>>(
  (ref) async => _composeLessons(
    ref,
    await ref.read(lessonRepositoryProvider).getUpcomingLessons(10),
  ),
);

final lessonCalendarProvider =
    FutureProvider.family<List<LessonWithBatch>, LessonCalendarArgs>((
      ref,
      args,
    ) async {
      final lessons = await ref
          .read(lessonRepositoryProvider)
          .getLessonsByDateRange(args.normalizedStart, args.normalizedEnd);
      final filtered = args.batchId == null
          ? lessons
          : lessons.where((lesson) => lesson.batchId == args.batchId).toList();
      return _composeLessons(ref, filtered);
    });

final lessonStatsProvider = FutureProvider<LessonStatsSummary>(
  (ref) => ref.read(lessonRepositoryProvider).getLessonStats(),
);

final batchLessonStatsProvider =
    FutureProvider.family<LessonStatsSummary, String>(
      (ref, batchId) =>
          ref.read(lessonRepositoryProvider).getLessonStatsByBatch(batchId),
    );

final lessonByBatchDateProvider =
    FutureProvider.family<List<LessonWithBatch>, AttendanceBatchDateArgs>(
      (ref, args) async => _composeLessons(
        ref,
        await ref
            .read(lessonRepositoryProvider)
            .getLessonsByBatchAndDate(args.batchId, args.date),
      ),
    );

enum LessonViewMode { daily, weekly, monthly }

class LessonPlannerState {
  const LessonPlannerState({
    required this.selectedDate,
    this.viewMode = LessonViewMode.daily,
    this.selectedBatchId,
    this.statusFilter,
    this.searchQuery = '',
    this.lessons = const [],
    this.dailyCount = 0,
    this.weeklyCount = 0,
    this.monthlyCount = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  final DateTime selectedDate;
  final LessonViewMode viewMode;
  final String? selectedBatchId;
  final LessonStatus? statusFilter;
  final String searchQuery;
  final List<LessonWithBatch> lessons;
  final int dailyCount;
  final int weeklyCount;
  final int monthlyCount;
  final bool isLoading;
  final String? errorMessage;

  LessonPlannerState copyWith({
    DateTime? selectedDate,
    LessonViewMode? viewMode,
    String? selectedBatchId,
    bool clearBatch = false,
    LessonStatus? statusFilter,
    bool clearStatus = false,
    String? searchQuery,
    List<LessonWithBatch>? lessons,
    int? dailyCount,
    int? weeklyCount,
    int? monthlyCount,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) => LessonPlannerState(
    selectedDate: selectedDate ?? this.selectedDate,
    viewMode: viewMode ?? this.viewMode,
    selectedBatchId: clearBatch
        ? null
        : selectedBatchId ?? this.selectedBatchId,
    statusFilter: clearStatus ? null : statusFilter ?? this.statusFilter,
    searchQuery: searchQuery ?? this.searchQuery,
    lessons: lessons ?? this.lessons,
    dailyCount: dailyCount ?? this.dailyCount,
    weeklyCount: weeklyCount ?? this.weeklyCount,
    monthlyCount: monthlyCount ?? this.monthlyCount,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

final lessonPlannerProvider =
    NotifierProvider<LessonPlannerNotifier, LessonPlannerState>(
      LessonPlannerNotifier.new,
    );

class LessonPlannerNotifier extends Notifier<LessonPlannerState> {
  @override
  LessonPlannerState build() =>
      LessonPlannerState(selectedDate: normalizeDate(DateTime.now()));

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final all = await ref.read(lessonRepositoryProvider).getAllLessons();
      final filtered = _applyCommonFilters(all);
      final daily = await _rangeLessons(all, LessonViewMode.daily);
      final weekly = await _rangeLessons(all, LessonViewMode.weekly);
      final monthly = await _rangeLessons(all, LessonViewMode.monthly);
      state = state.copyWith(
        lessons: await _composeLessons(ref, _rangeFilter(filtered)),
        dailyCount: _applyCommonFilters(daily).length,
        weeklyCount: _applyCommonFilters(weekly).length,
        monthlyCount: _applyCommonFilters(monthly).length,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> setViewMode(LessonViewMode mode) async {
    state = state.copyWith(viewMode: mode);
    await load();
  }

  Future<void> setSelectedDate(DateTime date) async {
    state = state.copyWith(selectedDate: normalizeDate(date));
    await load();
  }

  Future<void> shiftDate(int amount) async {
    final next = switch (state.viewMode) {
      LessonViewMode.daily => state.selectedDate.add(Duration(days: amount)),
      LessonViewMode.weekly => state.selectedDate.add(
        Duration(days: amount * 7),
      ),
      LessonViewMode.monthly => DateTime(
        state.selectedDate.year,
        state.selectedDate.month + amount,
        1,
      ),
    };
    await setSelectedDate(next);
  }

  Future<void> setBatch(String? batchId) async {
    state = batchId == null
        ? state.copyWith(clearBatch: true)
        : state.copyWith(selectedBatchId: batchId);
    await load();
  }

  Future<void> setStatus(LessonStatus? status) async {
    state = status == null
        ? state.copyWith(clearStatus: true)
        : state.copyWith(statusFilter: status);
    await load();
  }

  Future<void> setSearch(String query) async {
    state = state.copyWith(searchQuery: query);
    await load();
  }

  List<LessonPlanEntity> _applyCommonFilters(List<LessonPlanEntity> lessons) {
    final query = state.searchQuery.trim().toLowerCase();
    return lessons.where((lesson) {
      final matchesBatch =
          state.selectedBatchId == null ||
          lesson.batchId == state.selectedBatchId;
      final matchesStatus =
          state.statusFilter == null ||
          lesson.lessonStatus == state.statusFilter;
      final matchesQuery =
          query.isEmpty ||
          lesson.title.toLowerCase().contains(query) ||
          lesson.description.toLowerCase().contains(query);
      return matchesBatch && matchesStatus && matchesQuery;
    }).toList();
  }

  Future<List<LessonPlanEntity>> _rangeLessons(
    List<LessonPlanEntity> source,
    LessonViewMode mode,
  ) async {
    final date = state.selectedDate;
    final start = switch (mode) {
      LessonViewMode.daily => normalizeDate(date),
      LessonViewMode.weekly => startOfWeek(date),
      LessonViewMode.monthly => startOfMonth(date),
    };
    final end = switch (mode) {
      LessonViewMode.daily => normalizeDate(date),
      LessonViewMode.weekly => endOfWeek(date),
      LessonViewMode.monthly => endOfMonth(date),
    };
    return source
        .where(
          (lesson) =>
              !lesson.lessonDate.isBefore(start) &&
              !lesson.lessonDate.isAfter(end),
        )
        .toList();
  }

  List<LessonPlanEntity> _rangeFilter(List<LessonPlanEntity> source) {
    final start = switch (state.viewMode) {
      LessonViewMode.daily => normalizeDate(state.selectedDate),
      LessonViewMode.weekly => startOfWeek(state.selectedDate),
      LessonViewMode.monthly => startOfMonth(state.selectedDate),
    };
    final end = switch (state.viewMode) {
      LessonViewMode.daily => normalizeDate(state.selectedDate),
      LessonViewMode.weekly => endOfWeek(state.selectedDate),
      LessonViewMode.monthly => endOfMonth(state.selectedDate),
    };
    return source
        .where(
          (lesson) =>
              !lesson.lessonDate.isBefore(start) &&
              !lesson.lessonDate.isAfter(end),
        )
        .toList();
  }
}

class SyllabusEditState {
  const SyllabusEditState({
    required this.batchId,
    this.topics = const [],
    this.groups = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.reorderMode = false,
    this.errorMessage,
  });

  final String batchId;
  final List<SyllabusTopicEntity> topics;
  final List<SyllabusChapterGroup> groups;
  final bool isLoading;
  final bool isSaving;
  final bool reorderMode;
  final String? errorMessage;

  SyllabusEditState copyWith({
    List<SyllabusTopicEntity>? topics,
    List<SyllabusChapterGroup>? groups,
    bool? isLoading,
    bool? isSaving,
    bool? reorderMode,
    String? errorMessage,
    bool clearError = false,
  }) => SyllabusEditState(
    batchId: batchId,
    topics: topics ?? this.topics,
    groups: groups ?? this.groups,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    reorderMode: reorderMode ?? this.reorderMode,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

final syllabusEditProvider = NotifierProvider.autoDispose
    .family<SyllabusEditNotifier, SyllabusEditState, String>(
      SyllabusEditNotifier.new,
    );

class SyllabusEditNotifier extends Notifier<SyllabusEditState> {
  SyllabusEditNotifier(this.batchId);

  final String batchId;
  final Uuid _uuid = const Uuid();

  @override
  SyllabusEditState build() => SyllabusEditState(batchId: batchId);

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(syllabusRepositoryProvider);
      state = state.copyWith(
        topics: await repo.getTopicsByBatch(batchId),
        groups: await repo.getGroupedTopicsByBatch(batchId),
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> saveTopic(SyllabusTopicEntity topic) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final repo = ref.read(syllabusRepositoryProvider);
      final existing = await repo.getTopicById(topic.id);
      if (existing == null) {
        await repo.addTopic(topic);
      } else {
        await repo.updateTopic(topic);
      }
      state = state.copyWith(isSaving: false);
      _invalidateSyllabus();
      await load();
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
    }
  }

  Future<int> addBulkFromText(String text, {String chapterName = ''}) async {
    final titles = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (titles.isEmpty) return 0;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final now = DateTime.now();
      final topics = [
        for (final title in titles)
          SyllabusTopicEntity(
            id: _uuid.v4(),
            batchId: batchId,
            title: title,
            chapterName: chapterName.trim(),
            orderIndex: 0,
            createdAt: now,
            updatedAt: now,
          ),
      ];
      await ref.read(syllabusRepositoryProvider).addBulkTopics(topics);
      state = state.copyWith(isSaving: false);
      _invalidateSyllabus();
      await load();
      return topics.length;
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
      return 0;
    }
  }

  Future<void> toggleCompletion(String topicId) async {
    final topic = state.topics.where((item) => item.id == topicId).firstOrNull;
    if (topic == null) return;
    await ref
        .read(syllabusRepositoryProvider)
        .toggleTopicCompletion(topicId, !topic.isCompleted);
    _invalidateSyllabus();
    await load();
  }

  Future<void> deleteTopic(String topicId) async {
    await ref.read(syllabusRepositoryProvider).deleteTopic(topicId);
    _invalidateSyllabus();
    await load();
  }

  Future<void> reorder(List<String> orderedIds) async {
    await ref
        .read(syllabusRepositoryProvider)
        .reorderTopics(batchId, orderedIds);
    _invalidateSyllabus();
    await load();
  }

  void toggleReorderMode() {
    state = state.copyWith(reorderMode: !state.reorderMode);
  }

  void _invalidateSyllabus() {
    ref.invalidate(batchSyllabusProvider(batchId));
    ref.invalidate(batchSyllabusGroupsProvider(batchId));
    ref.invalidate(batchSyllabusProgressProvider(batchId));
    ref.invalidate(batchLessonsProvider(batchId));
    ref.invalidate(lessonDetailProvider);
    ref.invalidate(lessonPlannerProvider);
    ref.invalidate(todayLessonsProvider);
    ref.invalidate(upcomingLessonsProvider);
    ref.invalidate(lessonStatsProvider);
  }
}

void invalidateAllLessonProviders(
  dynamic ref, {
  required String batchId,
  String? lessonId,
}) {
  ref.invalidate(lessonPlannerProvider);
  ref.invalidate(batchLessonsProvider(batchId));
  ref.invalidate(batchSyllabusProvider(batchId));
  ref.invalidate(batchSyllabusGroupsProvider(batchId));
  ref.invalidate(batchSyllabusProgressProvider(batchId));
  ref.invalidate(todayLessonsProvider);
  ref.invalidate(upcomingLessonsProvider);
  ref.invalidate(lessonCalendarProvider);
  ref.invalidate(lessonStatsProvider);
  if (lessonId != null) ref.invalidate(lessonDetailProvider(lessonId));
}
