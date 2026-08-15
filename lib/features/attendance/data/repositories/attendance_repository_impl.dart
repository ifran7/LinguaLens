import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/attendance_summaries.dart';
import '../../domain/entities/attendance_status.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl({Box<AttendanceModel>? box})
    : _box = box ?? Hive.box<AttendanceModel>('attendanceBox');

  final Box<AttendanceModel> _box;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<AttendanceEntity>> getAllAttendance() async =>
      _sorted(_box.values.map(AttendanceEntity.fromModel).toList());

  @override
  Future<List<AttendanceEntity>> getAttendanceByStudent(
    String studentId,
  ) async => _sorted(
    _box.values
        .where((item) => item.studentId == studentId)
        .map(AttendanceEntity.fromModel)
        .toList(),
  );

  @override
  Future<List<AttendanceEntity>> getAttendanceByBatch(String batchId) async =>
      _sorted(
        _box.values
            .where((item) => item.batchId == batchId)
            .map(AttendanceEntity.fromModel)
            .toList(),
      );

  @override
  Future<List<AttendanceEntity>> getAttendanceByBatchAndDate(
    String batchId,
    DateTime date,
  ) async {
    final normalized = normalizeDate(date);
    final records =
        _box.values
            .where(
              (item) =>
                  item.batchId == batchId &&
                  isSameNormalizedDate(item.date, normalized),
            )
            .map(AttendanceEntity.fromModel)
            .toList()
          ..sort((a, b) => a.studentId.compareTo(b.studentId));
    return records;
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceByStudentAndDateRange(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = normalizeDate(startDate);
    final end = normalizeDate(endDate);
    final records =
        _box.values
            .where((item) {
              final date = normalizeDate(item.date);
              return item.studentId == studentId &&
                  !date.isBefore(start) &&
                  !date.isAfter(end);
            })
            .map(AttendanceEntity.fromModel)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    return records;
  }

  @override
  Future<AttendanceEntity?> getAttendanceRecord(
    String studentId,
    String batchId,
    DateTime date,
  ) async {
    final normalized = normalizeDate(date);
    final records =
        _box.values
            .where(
              (item) =>
                  item.studentId == studentId &&
                  item.batchId == batchId &&
                  isSameNormalizedDate(item.date, normalized),
            )
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return records.isEmpty ? null : AttendanceEntity.fromModel(records.first);
  }

  @override
  Future<void> upsertAttendance(AttendanceEntity attendance) async {
    final normalized = normalizeDate(attendance.date);
    final matches =
        _box.values
            .where(
              (item) =>
                  item.studentId == attendance.studentId &&
                  item.batchId == attendance.batchId &&
                  isSameNormalizedDate(item.date, normalized),
            )
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final now = DateTime.now();
    final existing = matches.isEmpty ? null : matches.first;
    final model = attendance
        .copyWith(
          id:
              existing?.id ??
              (attendance.id.isEmpty ? _uuid.v4() : attendance.id),
          date: normalized,
          createdAt: existing?.createdAt ?? attendance.createdAt,
          updatedAt: now,
        )
        .toModel();

    if (existing != null) {
      await _box.put(existing.key, model);
      for (final duplicate in matches.skip(1)) {
        await duplicate.delete();
      }
    } else {
      await _box.put(model.id, model);
    }
  }

  @override
  Future<void> upsertBulkAttendance(List<AttendanceEntity> records) async {
    for (final record in records) {
      await upsertAttendance(record);
    }
  }

  @override
  Future<void> deleteAttendance(String attendanceId) async {
    final matches = _box.values.where((item) => item.id == attendanceId);
    for (final record in matches.toList()) {
      await record.delete();
    }
  }

  @override
  Future<void> deleteAttendanceRecord(
    String studentId,
    String batchId,
    DateTime date,
  ) async {
    final normalized = normalizeDate(date);
    for (final record
        in _box.values
            .where(
              (item) =>
                  item.studentId == studentId &&
                  item.batchId == batchId &&
                  isSameNormalizedDate(item.date, normalized),
            )
            .toList()) {
      await record.delete();
    }
  }

  @override
  Future<void> deleteAttendanceByStudent(String studentId) async {
    for (final record
        in _box.values.where((item) => item.studentId == studentId).toList()) {
      await record.delete();
    }
  }

  @override
  Future<void> deleteAttendanceByBatch(String batchId) async {
    for (final record
        in _box.values.where((item) => item.batchId == batchId).toList()) {
      await record.delete();
    }
  }

  @override
  Future<StudentAttendanceSummary> getStudentAttendanceSummary(
    String studentId,
  ) async {
    final records = await getAttendanceByStudent(studentId);
    final present = records
        .where((r) => r.attendanceStatus == AttendanceStatus.present)
        .length;
    final absent = records
        .where((r) => r.attendanceStatus == AttendanceStatus.absent)
        .length;
    final late = records
        .where((r) => r.attendanceStatus == AttendanceStatus.late)
        .length;
    final leave = records
        .where((r) => r.attendanceStatus == AttendanceStatus.leave)
        .length;
    final total = records.length;
    return StudentAttendanceSummary(
      studentId: studentId,
      totalMarkedDays: total,
      presentCount: present,
      absentCount: absent,
      lateCount: late,
      leaveCount: leave,
      attendancePercentage: total == 0 ? 0 : ((present + late) / total) * 100,
    );
  }

  @override
  Future<BatchAttendanceDaySummary> getBatchAttendanceDaySummary(
    String batchId,
    DateTime date,
    int expectedStudentCount,
  ) async {
    final records = await getAttendanceByBatchAndDate(batchId, date);
    final present = records
        .where((r) => r.attendanceStatus == AttendanceStatus.present)
        .length;
    final absent = records
        .where((r) => r.attendanceStatus == AttendanceStatus.absent)
        .length;
    final late = records
        .where((r) => r.attendanceStatus == AttendanceStatus.late)
        .length;
    final leave = records
        .where((r) => r.attendanceStatus == AttendanceStatus.leave)
        .length;
    final marked = records.length;
    return BatchAttendanceDaySummary(
      batchId: batchId,
      date: normalizeDate(date),
      expectedStudentCount: expectedStudentCount,
      markedCount: marked,
      presentCount: present,
      absentCount: absent,
      lateCount: late,
      leaveCount: leave,
      unmarkedCount: (expectedStudentCount - marked).clamp(
        0,
        expectedStudentCount,
      ),
    );
  }

  @override
  Future<int> getTodayMarkedAttendanceCount() async {
    final today = normalizeDate(DateTime.now());
    return _box.values
        .where((item) => isSameNormalizedDate(item.date, today))
        .length;
  }

  List<AttendanceEntity> _sorted(List<AttendanceEntity> records) {
    records.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate == 0 ? b.createdAt.compareTo(a.createdAt) : byDate;
    });
    return records;
  }
}
