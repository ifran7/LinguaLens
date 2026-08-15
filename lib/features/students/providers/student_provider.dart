import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/student_repository_impl.dart';
import '../domain/entities/student_entity.dart';
import '../domain/repositories/student_repository.dart';

final studentRepositoryProvider = Provider<StudentRepository>(
  (ref) => StudentRepositoryImpl(),
);

final studentsListProvider = NotifierProvider<StudentsNotifier, StudentsState>(
  StudentsNotifier.new,
);

final studentDetailProvider = FutureProvider.family<StudentEntity?, String>(
  (ref, id) => ref.read(studentRepositoryProvider).getStudentById(id),
);

enum StudentFilterType { all, active, archived }

class StudentsState {
  const StudentsState({
    this.allStudents = const [],
    this.filteredStudents = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.filterType = StudentFilterType.all,
  });

  final List<StudentEntity> allStudents;
  final List<StudentEntity> filteredStudents;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final StudentFilterType filterType;

  int get activeCount =>
      allStudents.where((student) => student.isActive).length;
  int get archivedCount =>
      allStudents.where((student) => !student.isActive).length;

  StudentsState copyWith({
    List<StudentEntity>? allStudents,
    List<StudentEntity>? filteredStudents,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
    StudentFilterType? filterType,
  }) => StudentsState(
    allStudents: allStudents ?? this.allStudents,
    filteredStudents: filteredStudents ?? this.filteredStudents,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    searchQuery: searchQuery ?? this.searchQuery,
    filterType: filterType ?? this.filterType,
  );
}

class StudentsNotifier extends Notifier<StudentsState> {
  late final StudentRepository _repository;

  @override
  StudentsState build() {
    _repository = ref.read(studentRepositoryProvider);
    return const StudentsState();
  }

  Future<void> loadStudents() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final all = await _repository.getAllStudents();
      state = state.copyWith(
        allStudents: all,
        filteredStudents: _applyFilters(
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

  void searchStudents(String query) {
    final normalized = query.trim().toLowerCase();
    state = state.copyWith(
      searchQuery: query,
      filteredStudents: _applyFilters(
        state.allStudents,
        state.filterType,
        normalized,
      ),
    );
  }

  void setFilter(StudentFilterType type) => state = state.copyWith(
    filterType: type,
    filteredStudents: _applyFilters(state.allStudents, type, state.searchQuery),
  );

  Future<void> addStudent(StudentEntity student) async {
    await _repository.addStudent(student);
    await loadStudents();
  }

  Future<void> updateStudent(StudentEntity student) async {
    await _repository.updateStudent(student);
    await loadStudents();
  }

  Future<void> deleteStudent(String id) async {
    await _repository.deleteStudent(id);
    await loadStudents();
  }

  Future<void> archiveStudent(String id) async {
    await _repository.archiveStudent(id);
    await loadStudents();
  }

  Future<void> restoreStudent(String id) async {
    await _repository.restoreStudent(id);
    await loadStudents();
  }

  List<StudentEntity> _applyFilters(
    List<StudentEntity> source,
    StudentFilterType filter,
    String query,
  ) {
    final filteredByStatus = switch (filter) {
      StudentFilterType.all => source,
      StudentFilterType.active =>
        source.where((student) => student.isActive).toList(),
      StudentFilterType.archived =>
        source.where((student) => !student.isActive).toList(),
    };
    if (query.trim().isEmpty) return filteredByStatus;
    final needle = query.trim().toLowerCase();
    return filteredByStatus
        .where(
          (student) => [
            student.fullName,
            student.studentCode,
            student.parentName,
            student.parentPhone,
            student.phone,
          ].any((value) => value.toLowerCase().contains(needle)),
        )
        .toList();
  }
}
