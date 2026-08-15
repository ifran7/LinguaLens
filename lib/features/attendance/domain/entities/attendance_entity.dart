import '../../../../core/utils/date_utils.dart';
import '../../data/models/attendance_model.dart';
import 'attendance_status.dart';

class AttendanceEntity {
  const AttendanceEntity({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.date,
    required this.status,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String studentId;
  final String batchId;
  final DateTime date;
  final String status;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceStatus get attendanceStatus => AttendanceStatusX.fromValue(status);

  AttendanceEntity copyWith({
    String? id,
    String? studentId,
    String? batchId,
    DateTime? date,
    String? status,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AttendanceEntity(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    batchId: batchId ?? this.batchId,
    date: date == null ? this.date : normalizeDate(date),
    status: status ?? this.status,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  AttendanceModel toModel() => AttendanceModel(
    id: id,
    studentId: studentId,
    batchId: batchId,
    date: normalizeDate(date),
    status: status,
    note: note,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static AttendanceEntity fromModel(AttendanceModel model) => AttendanceEntity(
    id: model.id,
    studentId: model.studentId,
    batchId: model.batchId,
    date: normalizeDate(model.date),
    status: model.status,
    note: model.note,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is AttendanceEntity &&
      other.id == id &&
      other.updatedAt == updatedAt &&
      other.status == status;

  @override
  int get hashCode => Object.hash(id, updatedAt, status);
}
