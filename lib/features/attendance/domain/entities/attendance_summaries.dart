import 'attendance_entity.dart';
import 'attendance_status.dart';

class StudentAttendanceSummary {
  const StudentAttendanceSummary({
    required this.studentId,
    required this.totalMarkedDays,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.leaveCount,
    required this.attendancePercentage,
  });

  final String studentId;
  final int totalMarkedDays;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int leaveCount;
  final double attendancePercentage;

  factory StudentAttendanceSummary.empty(String studentId) =>
      StudentAttendanceSummary(
        studentId: studentId,
        totalMarkedDays: 0,
        presentCount: 0,
        absentCount: 0,
        lateCount: 0,
        leaveCount: 0,
        attendancePercentage: 0,
      );
}

class BatchAttendanceDaySummary {
  const BatchAttendanceDaySummary({
    required this.batchId,
    required this.date,
    required this.expectedStudentCount,
    required this.markedCount,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.leaveCount,
    required this.unmarkedCount,
  });

  final String batchId;
  final DateTime date;
  final int expectedStudentCount;
  final int markedCount;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int leaveCount;
  final int unmarkedCount;
}

class StudentDayAttendanceGroup {
  const StudentDayAttendanceGroup({
    required this.date,
    required this.records,
    required this.aggregateStatus,
  });

  final DateTime date;
  final List<AttendanceEntity> records;
  final AttendanceStatus? aggregateStatus;

  static AttendanceStatus? aggregate(List<AttendanceEntity> records) {
    if (records.any(
      (record) => record.attendanceStatus == AttendanceStatus.absent,
    )) {
      return AttendanceStatus.absent;
    }
    if (records.any(
      (record) => record.attendanceStatus == AttendanceStatus.late,
    )) {
      return AttendanceStatus.late;
    }
    if (records.any(
      (record) => record.attendanceStatus == AttendanceStatus.leave,
    )) {
      return AttendanceStatus.leave;
    }
    if (records.any(
      (record) => record.attendanceStatus == AttendanceStatus.present,
    )) {
      return AttendanceStatus.present;
    }
    return null;
  }
}

class DailyAttendanceSummary {
  const DailyAttendanceSummary({
    required this.date,
    required this.expectedStudentCount,
    required this.markedCount,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.leaveCount,
    required this.unmarkedCount,
  });

  final DateTime date;
  final int expectedStudentCount;
  final int markedCount;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int leaveCount;
  final int unmarkedCount;
}
