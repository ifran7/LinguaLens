import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../../core/services/local_storage_service.dart';
import '../../attendance/data/models/attendance_model.dart';
import '../../batches/data/models/batch_enrollment_model.dart';
import '../../batches/data/models/batch_model.dart';
import '../../fees/data/models/fee_record_model.dart';
import '../../fees/data/models/payment_model.dart';
import '../../students/data/models/student_model.dart';

class MessageVariables {
  static const studentName = '{student_name}';
  static const parentName = '{parent_name}';
  static const studentCode = '{student_code}';
  static const batchName = '{batch_name}';
  static const subject = '{subject}';
  static const teacherName = '{teacher_name}';
  static const feeAmount = '{fee_amount}';
  static const amountPaid = '{amount_paid}';
  static const amountDue = '{amount_due}';
  static const attendancePercentage = '{attendance_percentage}';
  static const attendancePresentDays = '{attendance_present_days}';
  static const attendanceTotalDays = '{attendance_total_days}';
  static const month = '{month}';
  static const teacherNote = '{teacher_note}';

  static const all = <String>[
    studentName,
    parentName,
    studentCode,
    batchName,
    subject,
    teacherName,
    feeAmount,
    amountPaid,
    amountDue,
    attendancePercentage,
    attendancePresentDays,
    attendanceTotalDays,
    month,
    teacherNote,
  ];
}

class ResolvedMessage {
  const ResolvedMessage({required this.text, this.unresolved = const []});

  final String text;
  final List<String> unresolved;

  bool get hasUnresolved => unresolved.isNotEmpty;
}

class MessageVariableResolver {
  const MessageVariableResolver();

  Future<ResolvedMessage> resolve({
    required String body,
    required String studentId,
    String? batchId,
    String? teacherNote,
    String? monthKey,
  }) async {
    final students = Hive.box<StudentModel>('studentsBox');
    final batches = Hive.box<BatchModel>('batchesBox');
    final enrollments = Hive.box<BatchEnrollmentModel>('batchEnrollmentsBox');
    final fees = Hive.box<FeeRecordModel>('feeRecordsBox');
    final payments = Hive.box<PaymentModel>('paymentsBox');
    final attendance = Hive.box<AttendanceModel>('attendanceBox');
    final student = students.get(studentId);
    if (student == null) {
      return ResolvedMessage(
        text: body,
        unresolved: const [MessageVariables.studentName],
      );
    }

    BatchModel? batch;
    if (batchId != null && batchId.isNotEmpty) {
      batch = batches.get(batchId);
    } else {
      final enrollment = enrollments.values
          .cast<BatchEnrollmentModel?>()
          .firstWhere(
            (item) =>
                item != null && item.studentId == studentId && item.isActive,
            orElse: () => null,
          );
      if (enrollment != null) batch = batches.get(enrollment.batchId);
    }

    final month = monthKey ?? DateFormat('yyyy-MM').format(DateTime.now());
    final selectedBatchId = batch?.id;
    final fee = fees.values.cast<FeeRecordModel?>().firstWhere(
      (item) =>
          item != null &&
          item.studentId == studentId &&
          (selectedBatchId == null || item.batchId == selectedBatchId) &&
          item.monthKey == month,
      orElse: () => null,
    );
    final paid = fee == null
        ? 0.0
        : payments.values
              .where((item) => item.feeRecordId == fee.id)
              .fold<double>(0, (sum, item) => sum + item.amount);
    final attendanceRows = attendance.values.where(
      (item) =>
          item.studentId == studentId &&
          (selectedBatchId == null || item.batchId == selectedBatchId),
    );
    final totalAttendance = attendanceRows.length;
    final presentAttendance = attendanceRows
        .where((item) => item.status == 'present')
        .length;
    final percentage = totalAttendance == 0
        ? 0.0
        : presentAttendance / totalAttendance * 100;
    final settings = LocalStorageService.instance;
    final teacherName = settings.teacherName;

    final values = <String, String>{
      MessageVariables.studentName: student.fullName,
      MessageVariables.parentName: student.parentName.isEmpty
          ? 'Parent'
          : student.parentName,
      MessageVariables.studentCode: student.studentCode,
      MessageVariables.batchName: batch?.name ?? 'your class',
      MessageVariables.subject: batch?.subject ?? '',
      MessageVariables.teacherName: teacherName.isEmpty
          ? 'Teacher'
          : teacherName,
      MessageVariables.feeAmount: fee?.finalFee.toStringAsFixed(0) ?? '0',
      MessageVariables.amountPaid: paid.toStringAsFixed(0),
      MessageVariables.amountDue: ((fee?.finalFee ?? 0) - paid)
          .clamp(0, double.infinity)
          .toStringAsFixed(0),
      MessageVariables.attendancePercentage: percentage.toStringAsFixed(0),
      MessageVariables.attendancePresentDays: presentAttendance.toString(),
      MessageVariables.attendanceTotalDays: totalAttendance.toString(),
      MessageVariables.month: month,
      MessageVariables.teacherNote: teacherNote ?? '',
    };

    var resolved = body;
    final unresolved = <String>[];
    for (final variable in MessageVariables.all) {
      if (resolved.contains(variable)) {
        final value = values[variable] ?? '';
        if (value.isEmpty) unresolved.add(variable);
        resolved = resolved.replaceAll(variable, value);
      }
    }
    return ResolvedMessage(text: resolved, unresolved: unresolved);
  }
}
