import '../../data/models/fee_record_model.dart';
import 'fee_status.dart';

class FeeRecordEntity {
  FeeRecordEntity({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.monthKey,
    required this.assignedFee,
    this.discountAmount = 0,
    required this.finalFee,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
    this.totalPaid = 0,
    FeeStatus? status,
  }) : status = status ?? FeeRecordEntity._computeStatus(finalFee, totalPaid);

  final String id;
  final String studentId;
  final String batchId;
  final String monthKey;
  final double assignedFee;
  final double discountAmount;
  final double finalFee;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalPaid;
  final FeeStatus status;

  double get dueAmount => (finalFee - totalPaid).clamp(0, double.infinity);

  static FeeStatus _computeStatus(double finalFee, double totalPaid) {
    if (finalFee <= 0) return FeeStatus.paid;
    final due = finalFee - totalPaid;
    if (due <= 0) return FeeStatus.paid;
    if (totalPaid > 0) return FeeStatus.partial;
    return FeeStatus.unpaid;
  }

  static FeeStatus computeStatus(double finalFee, double totalPaid) =>
      _computeStatus(finalFee, totalPaid);

  factory FeeRecordEntity.fromModel(FeeRecordModel model) => FeeRecordEntity(
    id: model.id,
    studentId: model.studentId,
    batchId: model.batchId,
    monthKey: model.monthKey,
    assignedFee: model.assignedFee,
    discountAmount: model.discountAmount,
    finalFee: model.finalFee,
    note: model.note,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
  );

  factory FeeRecordEntity.fromModelWithPayments(
    FeeRecordModel model,
    double totalPaid,
  ) => FeeRecordEntity(
    id: model.id,
    studentId: model.studentId,
    batchId: model.batchId,
    monthKey: model.monthKey,
    assignedFee: model.assignedFee,
    discountAmount: model.discountAmount,
    finalFee: model.finalFee,
    note: model.note,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
    totalPaid: totalPaid,
  );

  FeeRecordEntity copyWith({
    String? id,
    String? studentId,
    String? batchId,
    String? monthKey,
    double? assignedFee,
    double? discountAmount,
    double? finalFee,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalPaid,
    FeeStatus? status,
  }) => FeeRecordEntity(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    batchId: batchId ?? this.batchId,
    monthKey: monthKey ?? this.monthKey,
    assignedFee: assignedFee ?? this.assignedFee,
    discountAmount: discountAmount ?? this.discountAmount,
    finalFee: finalFee ?? this.finalFee,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    totalPaid: totalPaid ?? this.totalPaid,
    status: status ?? this.status,
  );

  FeeRecordModel toModel() => FeeRecordModel(
    id: id,
    studentId: studentId,
    batchId: batchId,
    monthKey: monthKey,
    assignedFee: assignedFee,
    discountAmount: discountAmount,
    finalFee: finalFee,
    note: note,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is FeeRecordEntity &&
      other.id == id &&
      other.updatedAt == updatedAt &&
      other.totalPaid == totalPaid;

  @override
  int get hashCode => Object.hash(id, updatedAt, totalPaid);
}
