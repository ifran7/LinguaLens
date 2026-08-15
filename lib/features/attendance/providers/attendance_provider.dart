import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/date_utils.dart';
import '../../batches/domain/entities/batch_entity.dart';
import '../../batches/providers/batch_provider.dart';
import '../../students/providers/student_provider.dart';
import '../data/repositories/attendance_repository_impl.dart';
import '../domain/entities/attendance_entity.dart';
import '../domain/entities/attendance_session_student.dart';
import '../domain/entities/attendance_status.dart';
import '../domain/entities/attendance_summaries.dart';
import '../domain/repositories/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepositoryImpl(),
);

class AttendanceBatchDateArgs {
  const AttendanceBatchDateArgs({required this.batchId, required this.date});

  final String batchId;
  final DateTime date;

  @override
  bool operator ==(Object other) =>
      other is AttendanceBatchDateArgs &&
      other.batchId == batchId &&
      isSameNormalizedDate(other.date, date);

  @override
  int get hashCode => Object.hash(batchId, dateKey(date));
}

class StudentAttendanceCalendarArgs {
  const StudentAttendanceCalendarArgs({
    required this.studentId,
    required this.startDate,
    required this.endDate,
    this.batchId,
  });

  final String studentId;
  final DateTime startDate;
  final DateTime endDate;
  final String? batchId;

  @override
  bool operator ==(Object other) =>
      other is StudentAttendanceCalendarArgs &&
      other.studentId == studentId &&
      other.batchId == batchId &&
      isSameNormalizedDate(other.startDate, startDate) &&
      isSameNormalizedDate(other.endDate, endDate);

  @override
  int get hashCode =>
      Object.hash(studentId, batchId, dateKey(startDate), dateKey(endDate));
}

class AttendanceHomeState {
  const AttendanceHomeState({
    this.activeBatches = const [],
    this.isLoading = false,
    this.errorMessage,
    required this.selectedDate,
  });

  final List<BatchEntity> activeBatches;
  final bool isLoading;
  final String? errorMessage;
  final DateTime selectedDate;

  AttendanceHomeState copyWith({
    List<BatchEntity>? activeBatches,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    DateTime? selectedDate,
  }) => AttendanceHomeState(
    activeBatches: activeBatches ?? this.activeBatches,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    selectedDate: selectedDate ?? this.selectedDate,
  );
}

final attendanceHomeProvider =
    NotifierProvider<AttendanceHomeNotifier, AttendanceHomeState>(
      AttendanceHomeNotifier.new,
    );

class AttendanceHomeNotifier extends Notifier<AttendanceHomeState> {
  @override
  AttendanceHomeState build() =>
      AttendanceHomeState(selectedDate: normalizeDate(DateTime.now()));

  Future<void> load([DateTime? date]) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedDate: date == null ? null : normalizeDate(date),
    );
    try {
      state = state.copyWith(
        activeBatches: await ref
            .read(batchRepositoryProvider)
            .getActiveBatches(),
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> changeDate(DateTime date) => load(date);
}

final batchExpectedStudentsProvider =
    FutureProvider.family<int, AttendanceBatchDateArgs>((ref, args) async {
      final enrollments = await ref
          .read(enrollmentRepositoryProvider)
          .getEnrollmentsByBatch(args.batchId);
      final activeStudents = await ref
          .read(studentRepositoryProvider)
          .getActiveStudents();
      final activeIds = activeStudents.map((student) => student.id).toSet();
      final date = normalizeDate(args.date);
      return enrollments
          .where(
            (enrollment) =>
                enrollment.isActive &&
                !normalizeDate(enrollment.joiningDate).isAfter(date) &&
                activeIds.contains(enrollment.studentId),
          )
          .length;
    });

final batchAttendanceDaySummaryProvider =
    FutureProvider.family<BatchAttendanceDaySummary, AttendanceBatchDateArgs>((
      ref,
      args,
    ) async {
      final expected = await ref.read(
        batchExpectedStudentsProvider(args).future,
      );
      return ref
          .read(attendanceRepositoryProvider)
          .getBatchAttendanceDaySummary(args.batchId, args.date, expected);
    });

final todayAttendanceCountProvider = FutureProvider<int>(
  (ref) =>
      ref.read(attendanceRepositoryProvider).getTodayMarkedAttendanceCount(),
);

final studentAttendanceSummaryProvider =
    FutureProvider.family<StudentAttendanceSummary, String>(
      (ref, studentId) => ref
          .read(attendanceRepositoryProvider)
          .getStudentAttendanceSummary(studentId),
    );

final studentAttendanceCalendarProvider =
    FutureProvider.family<
      List<StudentDayAttendanceGroup>,
      StudentAttendanceCalendarArgs
    >((ref, args) async {
      var records = await ref
          .read(attendanceRepositoryProvider)
          .getAttendanceByStudentAndDateRange(
            args.studentId,
            args.startDate,
            args.endDate,
          );
      if (args.batchId != null) {
        records = records
            .where((record) => record.batchId == args.batchId)
            .toList();
      }
      final grouped = <String, List<AttendanceEntity>>{};
      for (final record in records) {
        grouped.putIfAbsent(dateKey(record.date), () => []).add(record);
      }
      final groups =
          grouped.entries
              .map(
                (entry) => StudentDayAttendanceGroup(
                  date: DateTime.parse(entry.key),
                  records: List.unmodifiable(entry.value),
                  aggregateStatus: StudentDayAttendanceGroup.aggregate(
                    entry.value,
                  ),
                ),
              )
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));
      return groups;
    });

class AttendanceSessionState {
  const AttendanceSessionState({
    this.batch,
    required this.selectedDate,
    this.students = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.searchQuery = '',
  });

  final BatchEntity? batch;
  final DateTime selectedDate;
  final List<AttendanceSessionStudent> students;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String searchQuery;

  List<AttendanceSessionStudent> get visibleStudents {
    final needle = searchQuery.trim().toLowerCase();
    if (needle.isEmpty) return students;
    return students
        .where(
          (item) =>
              item.student.fullName.toLowerCase().contains(needle) ||
              item.student.studentCode.toLowerCase().contains(needle),
        )
        .toList();
  }

  int get presentCount => _count(AttendanceStatus.present);
  int get absentCount => _count(AttendanceStatus.absent);
  int get lateCount => _count(AttendanceStatus.late);
  int get leaveCount => _count(AttendanceStatus.leave);
  int get markedCount =>
      students.where((item) => item.effectiveStatus != null).length;
  int get unmarkedCount => students.length - markedCount;

  int _count(AttendanceStatus status) =>
      students.where((item) => item.effectiveStatus == status).length;

  AttendanceSessionState copyWith({
    BatchEntity? batch,
    DateTime? selectedDate,
    List<AttendanceSessionStudent>? students,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    String? searchQuery,
  }) => AttendanceSessionState(
    batch: batch ?? this.batch,
    selectedDate: selectedDate ?? this.selectedDate,
    students: students ?? this.students,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    searchQuery: searchQuery ?? this.searchQuery,
  );
}

final attendanceSessionProvider = NotifierProvider.autoDispose
    .family<AttendanceSessionNotifier, AttendanceSessionState, String>(
      AttendanceSessionNotifier.new,
    );

class AttendanceSessionNotifier extends Notifier<AttendanceSessionState> {
  AttendanceSessionNotifier(this.batchId);

  final String batchId;
  final Uuid _uuid = const Uuid();

  @override
  AttendanceSessionState build() =>
      AttendanceSessionState(selectedDate: normalizeDate(DateTime.now()));

  Future<void> loadSession([DateTime? requestedDate]) async {
    final date = normalizeDate(requestedDate ?? state.selectedDate);
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedDate: date,
    );
    try {
      final batch = await ref
          .read(batchRepositoryProvider)
          .getBatchById(batchId);
      if (batch == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Batch not found',
        );
        return;
      }
      final enrollments = await ref
          .read(enrollmentRepositoryProvider)
          .getEnrollmentsByBatch(batchId);
      final students = await ref
          .read(studentRepositoryProvider)
          .getActiveStudents();
      final studentsById = {
        for (final student in students) student.id: student,
      };
      final existing = await ref
          .read(attendanceRepositoryProvider)
          .getAttendanceByBatchAndDate(batchId, date);
      final existingByStudent = {
        for (final record in existing) record.studentId: record,
      };
      final session =
          enrollments
              .where(
                (enrollment) =>
                    enrollment.isActive &&
                    !normalizeDate(enrollment.joiningDate).isAfter(date) &&
                    studentsById.containsKey(enrollment.studentId),
              )
              .map((enrollment) {
                final student = studentsById[enrollment.studentId]!;
                final record = existingByStudent[student.id];
                return AttendanceSessionStudent(
                  student: student,
                  enrollment: enrollment,
                  existingAttendance: record,
                  note: record?.note ?? '',
                );
              })
              .toList()
            ..sort((a, b) => a.student.fullName.compareTo(b.student.fullName));
      state = state.copyWith(batch: batch, students: session, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> changeDate(DateTime date) => loadSession(date);

  void searchStudents(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStudentStatus(String studentId, AttendanceStatus status) {
    state = state.copyWith(
      students: [
        for (final item in state.students)
          if (item.student.id == studentId)
            item.copyWith(draftStatus: status)
          else
            item,
      ],
    );
  }

  void clearStudentStatus(String studentId) {
    state = state.copyWith(
      students: [
        for (final item in state.students)
          if (item.student.id == studentId)
            item.copyWith(clearDraftStatus: true)
          else
            item,
      ],
    );
  }

  void setStudentNote(String studentId, String note) {
    state = state.copyWith(
      students: [
        for (final item in state.students)
          if (item.student.id == studentId) item.copyWith(note: note) else item,
      ],
    );
  }

  void markAllPresent() {
    state = state.copyWith(
      students: [
        for (final item in state.students)
          item.copyWith(draftStatus: AttendanceStatus.present),
      ],
    );
  }

  void clearAllStatuses() {
    state = state.copyWith(
      students: [
        for (final item in state.students)
          item.copyWith(clearDraftStatus: true),
      ],
    );
  }

  Future<void> saveSession() async {
    if (state.isSaving) return;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final repo = ref.read(attendanceRepositoryProvider);
      final now = DateTime.now();
      final toUpsert = <AttendanceEntity>[];
      final toDelete = <AttendanceEntity>[];
      for (final item in state.students) {
        final status = item.effectiveStatus;
        if (status == null) {
          if (item.existingAttendance != null) {
            toDelete.add(item.existingAttendance!);
          }
          continue;
        }
        toUpsert.add(
          AttendanceEntity(
            id: item.existingAttendance?.id ?? _uuid.v4(),
            studentId: item.student.id,
            batchId: batchId,
            date: state.selectedDate,
            status: status.value,
            note: item.note.trim(),
            createdAt: item.existingAttendance?.createdAt ?? now,
            updatedAt: now,
          ),
        );
      }
      await repo.upsertBulkAttendance(toUpsert);
      for (final record in toDelete) {
        await repo.deleteAttendance(record.id);
      }
      ref.invalidate(todayAttendanceCountProvider);
      ref.invalidate(attendanceDailySummaryProvider);
      ref.invalidate(batchAttendanceDaySummaryProvider);
      ref.invalidate(studentAttendanceSummaryProvider);
      ref.invalidate(studentAttendanceCalendarProvider);
      ref.invalidate(attendanceHomeProvider);
      state = state.copyWith(isSaving: false);
      await loadSession();
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
    }
  }
}

final attendanceDailySummaryProvider =
    FutureProvider.family<DailyAttendanceSummary, DateTime>((ref, date) async {
      final normalized = normalizeDate(date);
      final batches = await ref
          .read(batchRepositoryProvider)
          .getActiveBatches();
      final activeStudents = await ref
          .read(studentRepositoryProvider)
          .getActiveStudents();
      final activeStudentIds = activeStudents
          .map((student) => student.id)
          .toSet();
      final eligiblePairs = <String>{};

      for (final batch in batches) {
        final enrollments = await ref
            .read(enrollmentRepositoryProvider)
            .getEnrollmentsByBatch(batch.id);
        for (final enrollment in enrollments) {
          if (enrollment.isActive &&
              !normalizeDate(enrollment.joiningDate).isAfter(normalized) &&
              activeStudentIds.contains(enrollment.studentId)) {
            eligiblePairs.add('${batch.id}:${enrollment.studentId}');
          }
        }
      }

      final records = await ref
          .read(attendanceRepositoryProvider)
          .getAllAttendance();
      final relevant = records
          .where(
            (record) =>
                isSameNormalizedDate(record.date, normalized) &&
                eligiblePairs.contains('${record.batchId}:${record.studentId}'),
          )
          .toList();
      int count(AttendanceStatus status) =>
          relevant.where((record) => record.attendanceStatus == status).length;
      final marked = relevant.length;
      final expected = eligiblePairs.length;
      return DailyAttendanceSummary(
        date: normalized,
        expectedStudentCount: expected,
        markedCount: marked,
        presentCount: count(AttendanceStatus.present),
        absentCount: count(AttendanceStatus.absent),
        lateCount: count(AttendanceStatus.late),
        leaveCount: count(AttendanceStatus.leave),
        unmarkedCount: (expected - marked).clamp(0, expected),
      );
    });
