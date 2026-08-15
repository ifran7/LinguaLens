import '../../../batches/domain/entities/batch_enrollment_entity.dart';
import '../../../students/domain/entities/student_entity.dart';
import 'attendance_entity.dart';
import 'attendance_status.dart';

class AttendanceSessionStudent {
  const AttendanceSessionStudent({
    required this.student,
    required this.enrollment,
    this.existingAttendance,
    this.draftStatus,
    this.note = '',
  });

  final StudentEntity student;
  final BatchEnrollmentEntity enrollment;
  final AttendanceEntity? existingAttendance;
  final AttendanceStatus? draftStatus;
  final String note;

  AttendanceStatus? get effectiveStatus =>
      draftStatus ?? existingAttendance?.attendanceStatus;

  AttendanceSessionStudent copyWith({
    AttendanceEntity? existingAttendance,
    bool clearExistingAttendance = false,
    AttendanceStatus? draftStatus,
    bool clearDraftStatus = false,
    String? note,
  }) => AttendanceSessionStudent(
    student: student,
    enrollment: enrollment,
    existingAttendance: clearExistingAttendance
        ? null
        : existingAttendance ?? this.existingAttendance,
    draftStatus: clearDraftStatus ? null : draftStatus ?? this.draftStatus,
    note: note ?? this.note,
  );
}
