import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../batches/providers/batch_provider.dart';
import '../lessons/providers/lesson_provider.dart';
import '../students/providers/student_provider.dart';

final globalSearchProvider =
    NotifierProvider.autoDispose<GlobalSearchNotifier, GlobalSearchState>(
      GlobalSearchNotifier.new,
    );

class GlobalSearchState {
  const GlobalSearchState({
    this.query = '',
    this.isLoading = false,
    this.results = const [],
    this.errorMessage,
  });

  final String query;
  final bool isLoading;
  final List<GlobalSearchResult> results;
  final String? errorMessage;

  GlobalSearchState copyWith({
    String? query,
    bool? isLoading,
    List<GlobalSearchResult>? results,
    String? errorMessage,
    bool clearError = false,
  }) => GlobalSearchState(
    query: query ?? this.query,
    isLoading: isLoading ?? this.isLoading,
    results: results ?? this.results,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

class GlobalSearchResult {
  const GlobalSearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final GlobalSearchResultType type;
  final String id;
  final String title;
  final String subtitle;
  final String route;
}

enum GlobalSearchResultType { student, batch, lesson }

class GlobalSearchNotifier extends Notifier<GlobalSearchState> {
  Timer? _debounce;

  @override
  GlobalSearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const GlobalSearchState();
  }

  void setQuery(String value) {
    _debounce?.cancel();
    state = state.copyWith(query: value, isLoading: value.trim().isNotEmpty);
    if (value.trim().isEmpty) {
      state = state.copyWith(isLoading: false, results: const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(_search(value));
    });
  }

  Future<void> refresh() async {
    if (state.query.trim().isNotEmpty) await _search(state.query);
  }

  Future<void> _search(String rawQuery) async {
    final query = rawQuery.trim().toLowerCase();
    if (query.isEmpty) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final studentsFuture = ref
          .read(studentRepositoryProvider)
          .getAllStudents();
      final batchesFuture = ref.read(batchRepositoryProvider).getAllBatches();
      final lessonsFuture = ref.read(lessonRepositoryProvider).getAllLessons();
      final students = await studentsFuture;
      final batches = await batchesFuture;
      final lessons = await lessonsFuture;
      final results = <GlobalSearchResult>[];

      for (final student in students) {
        final haystack = [
          student.fullName,
          student.studentCode,
          student.parentName,
          student.parentPhone,
          student.phone,
        ].join(' ').toLowerCase();
        if (haystack.contains(query)) {
          results.add(
            GlobalSearchResult(
              type: GlobalSearchResultType.student,
              id: student.id,
              title: student.fullName,
              subtitle: student.parentName.isEmpty
                  ? student.studentCode
                  : student.parentName,
              route: '/students/${student.id}',
            ),
          );
        }
      }
      for (final batch in batches) {
        final haystack = '${batch.name} ${batch.subject}'.toLowerCase();
        if (haystack.contains(query)) {
          results.add(
            GlobalSearchResult(
              type: GlobalSearchResultType.batch,
              id: batch.id,
              title: batch.name,
              subtitle: batch.subject,
              route: '/batches/${batch.id}',
            ),
          );
        }
      }
      for (final lesson in lessons) {
        final haystack =
            '${lesson.title} ${lesson.description} ${lesson.homework}'
                .toLowerCase();
        if (haystack.contains(query)) {
          results.add(
            GlobalSearchResult(
              type: GlobalSearchResultType.lesson,
              id: lesson.id,
              title: lesson.title,
              subtitle: lesson.description.isEmpty
                  ? lesson.status
                  : lesson.description,
              route: '/lessons/${lesson.id}',
            ),
          );
        }
      }
      state = state.copyWith(isLoading: false, results: results);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }
}
