import '../../data/models/batch_enrollment_model.dart';

class BatchEnrollmentEntity {
  const BatchEnrollmentEntity({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.joiningDate,
    this.customFee = 0,
    this.isActive = true,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String studentId;
  final String batchId;
  final DateTime joiningDate;
  final double customFee;
  final bool isActive;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  double effectiveFee(double batchDefaultFee) =>
      customFee > 0 ? customFee : batchDefaultFee;

  BatchEnrollmentEntity copyWith({
    String? id,
    String? studentId,
    String? batchId,
    DateTime? joiningDate,
    double? customFee,
    bool? isActive,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BatchEnrollmentEntity(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    batchId: batchId ?? this.batchId,
    joiningDate: joiningDate ?? this.joiningDate,
    customFee: customFee ?? this.customFee,
    isActive: isActive ?? this.isActive,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  BatchEnrollmentModel toModel() => BatchEnrollmentModel(
    id: id,
    studentId: studentId,
    batchId: batchId,
    joiningDate: joiningDate,
    customFee: customFee,
    isActive: isActive,
    note: note,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static BatchEnrollmentEntity fromModel(BatchEnrollmentModel model) =>
      BatchEnrollmentEntity(
        id: model.id,
        studentId: model.studentId,
        batchId: model.batchId,
        joiningDate: model.joiningDate,
        customFee: model.customFee,
        isActive: model.isActive,
        note: model.note,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      other is BatchEnrollmentEntity &&
      other.id == id &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, updatedAt);
}
