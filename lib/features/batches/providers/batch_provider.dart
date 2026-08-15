import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/batch_enrollment_repository_impl.dart';
import '../data/repositories/batch_repository_impl.dart';
import '../domain/entities/batch_entity.dart';
import '../domain/entities/batch_enrollment_entity.dart';
import '../domain/repositories/batch_enrollment_repository.dart';
import '../domain/repositories/batch_repository.dart';

final batchRepositoryProvider = Provider<BatchRepository>(
  (ref) => BatchRepositoryImpl(),
);

final enrollmentRepositoryProvider = Provider<BatchEnrollmentRepository>(
  (ref) => BatchEnrollmentRepositoryImpl(),
);

enum BatchFilterType { all, active, archived }

class BatchesState {
  const BatchesState({
    this.allBatches = const [],
    this.filteredBatches = const [],
    this.isLoading = false,
    this.errorMessage,
    this.filterType = BatchFilterType.all,
    this.searchQuery = '',
  });

  final List<BatchEntity> allBatches;
  final List<BatchEntity> filteredBatches;
  final bool isLoading;
  final String? errorMessage;
  final BatchFilterType filterType;
  final String searchQuery;

  int get activeCount => allBatches.where((batch) => batch.isActive).length;
  int get archivedCount => allBatches.where((batch) => !batch.isActive).length;

  BatchesState copyWith({
    List<BatchEntity>? allBatches,
    List<BatchEntity>? filteredBatches,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    BatchFilterType? filterType,
    String? searchQuery,
  }) => BatchesState(
    allBatches: allBatches ?? this.allBatches,
    filteredBatches: filteredBatches ?? this.filteredBatches,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    filterType: filterType ?? this.filterType,
    searchQuery: searchQuery ?? this.searchQuery,
  );
}

final batchesListProvider = NotifierProvider<BatchesNotifier, BatchesState>(
  BatchesNotifier.new,
);

class BatchesNotifier extends Notifier<BatchesState> {
  late final BatchRepository _repository;

  @override
  BatchesState build() {
    _repository = ref.read(batchRepositoryProvider);
    return const BatchesState();
  }

  Future<void> loadBatches() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final all = await _repository.getAllBatches();
      state = state.copyWith(
        allBatches: all,
        filteredBatches: _applyFilters(
          all,
          state.filterType,
          state.searchQuery,
        ),
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  void searchBatches(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredBatches: _applyFilters(state.allBatches, state.filterType, query),
    );
  }

  void setFilter(BatchFilterType filter) {
    state = state.copyWith(
      filterType: filter,
      filteredBatches: _applyFilters(
        state.allBatches,
        filter,
        state.searchQuery,
      ),
    );
  }

  Future<void> addBatch(BatchEntity batch) async {
    await _repository.addBatch(batch);
    await loadBatches();
  }

  Future<void> updateBatch(BatchEntity batch) async {
    await _repository.updateBatch(batch);
    await loadBatches();
  }

  Future<void> deleteBatch(String id) async {
    await _repository.deleteBatch(id);
    await loadBatches();
  }

  Future<void> archiveBatch(String id) async {
    await _repository.archiveBatch(id);
    await loadBatches();
  }

  Future<void> restoreBatch(String id) async {
    await _repository.restoreBatch(id);
    await loadBatches();
  }

  List<BatchEntity> _applyFilters(
    List<BatchEntity> source,
    BatchFilterType filter,
    String query,
  ) {
    final statusFiltered = switch (filter) {
      BatchFilterType.all => source,
      BatchFilterType.active =>
        source.where((batch) => batch.isActive).toList(),
      BatchFilterType.archived =>
        source.where((batch) => !batch.isActive).toList(),
    };
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return statusFiltered;
    return statusFiltered
        .where(
          (batch) =>
              batch.name.toLowerCase().contains(needle) ||
              batch.subject.toLowerCase().contains(needle),
        )
        .toList();
  }
}

class BatchEnrollmentState {
  const BatchEnrollmentState({
    this.enrollments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<BatchEnrollmentEntity> enrollments;
  final bool isLoading;
  final String? errorMessage;

  BatchEnrollmentState copyWith({
    List<BatchEnrollmentEntity>? enrollments,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) => BatchEnrollmentState(
    enrollments: enrollments ?? this.enrollments,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

final batchEnrollmentsProvider =
    NotifierProvider.family<
      BatchEnrollmentNotifier,
      BatchEnrollmentState,
      String
    >(BatchEnrollmentNotifier.new);

class BatchEnrollmentNotifier extends Notifier<BatchEnrollmentState> {
  BatchEnrollmentNotifier(this.batchId);

  final String batchId;
  late final BatchEnrollmentRepository _repository;

  @override
  BatchEnrollmentState build() {
    _repository = ref.read(enrollmentRepositoryProvider);
    return const BatchEnrollmentState();
  }

  Future<void> loadEnrollmentsForBatch([String? requestedBatchId]) async {
    final id = requestedBatchId ?? batchId;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      state = state.copyWith(
        enrollments: await _repository.getEnrollmentsByBatch(id),
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> loadEnrollmentsForStudent(String studentId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      state = state.copyWith(
        enrollments: await _repository.getEnrollmentsByStudent(studentId),
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> enrollStudent(BatchEnrollmentEntity enrollment) async {
    await _repository.enrollStudent(enrollment);
    await loadEnrollmentsForBatch(enrollment.batchId);
  }

  Future<void> updateEnrollment(BatchEnrollmentEntity enrollment) async {
    await _repository.updateEnrollment(enrollment);
    await loadEnrollmentsForBatch(enrollment.batchId);
  }

  Future<void> removeStudent(String enrollmentId) async {
    await _repository.removeStudentFromBatch(enrollmentId);
    await loadEnrollmentsForBatch();
  }

  Future<void> deleteEnrollment(String enrollmentId) async {
    await _repository.deleteEnrollment(enrollmentId);
    await loadEnrollmentsForBatch();
  }
}

final batchStudentCountProvider = FutureProvider.family<int, String>(
  (ref, batchId) =>
      ref.read(enrollmentRepositoryProvider).getEnrolledStudentCount(batchId),
);

final batchDetailProvider = FutureProvider.family<BatchEntity?, String>(
  (ref, id) => ref.read(batchRepositoryProvider).getBatchById(id),
);

class StudentBatchOverview {
  const StudentBatchOverview({required this.batch, required this.enrollment});

  final BatchEntity batch;
  final BatchEnrollmentEntity enrollment;
}

final studentBatchOverviewsProvider =
    FutureProvider.family<List<StudentBatchOverview>, String>((
      ref,
      studentId,
    ) async {
      final enrollmentRepository = ref.read(enrollmentRepositoryProvider);
      final batchRepository = ref.read(batchRepositoryProvider);
      final enrollments = await enrollmentRepository.getEnrollmentsByStudent(
        studentId,
      );
      final overviews = <StudentBatchOverview>[];
      for (final enrollment in enrollments) {
        final batch = await batchRepository.getBatchById(enrollment.batchId);
        if (batch != null) {
          overviews.add(
            StudentBatchOverview(batch: batch, enrollment: enrollment),
          );
        }
      }
      return overviews;
    });
