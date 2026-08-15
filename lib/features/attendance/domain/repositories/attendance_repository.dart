import '../entities/attendance_entity.dart';
import '../entities/attendance_summaries.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getAllAttendance();
  Future<List<AttendanceEntity>> getAttendanceByStudent(String studentId);
  Future<List<AttendanceEntity>> getAttendanceByBatch(String batchId);
  Future<List<AttendanceEntity>> getAttendanceByBatchAndDate(
    String batchId,
    DateTime date,
  );
  Future<List<AttendanceEntity>> getAttendanceByStudentAndDateRange(
    String studentId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<AttendanceEntity?> getAttendanceRecord(
    String studentId,
    String batchId,
    DateTime date,
  );
  Future<void> upsertAttendance(AttendanceEntity attendance);
  Future<void> upsertBulkAttendance(List<AttendanceEntity> records);
  Future<void> deleteAttendance(String attendanceId);
  Future<void> deleteAttendanceRecord(
    String studentId,
    String batchId,
    DateTime date,
  );
  Future<void> deleteAttendanceByStudent(String studentId);
  Future<void> deleteAttendanceByBatch(String batchId);
  Future<StudentAttendanceSummary> getStudentAttendanceSummary(
    String studentId,
  );
  Future<BatchAttendanceDaySummary> getBatchAttendanceDaySummary(
    String batchId,
    DateTime date,
    int expectedStudentCount,
  );
  Future<int> getTodayMarkedAttendanceCount();
}
