import '../../data/models/payment_model.dart';
import 'payment_method.dart';

class PaymentEntity {
  const PaymentEntity({
    required this.id,
    required this.feeRecordId,
    required this.studentId,
    required this.batchId,
    required this.monthKey,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String feeRecordId;
  final String studentId;
  final String batchId;
  final String monthKey;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethod get method => PaymentMethodX.fromValue(paymentMethod);

  PaymentEntity copyWith({
    String? id,
    String? feeRecordId,
    String? studentId,
    String? batchId,
    String? monthKey,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PaymentEntity(
    id: id ?? this.id,
    feeRecordId: feeRecordId ?? this.feeRecordId,
    studentId: studentId ?? this.studentId,
    batchId: batchId ?? this.batchId,
    monthKey: monthKey ?? this.monthKey,
    amount: amount ?? this.amount,
    paymentDate: paymentDate ?? this.paymentDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory PaymentEntity.fromModel(PaymentModel model) => PaymentEntity(
    id: model.id,
    feeRecordId: model.feeRecordId,
    studentId: model.studentId,
    batchId: model.batchId,
    monthKey: model.monthKey,
    amount: model.amount,
    paymentDate: model.paymentDate,
    paymentMethod: model.paymentMethod,
    note: model.note,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
  );

  PaymentModel toModel() => PaymentModel(
    id: id,
    feeRecordId: feeRecordId,
    studentId: studentId,
    batchId: batchId,
    monthKey: monthKey,
    amount: amount,
    paymentDate: paymentDate,
    paymentMethod: paymentMethod,
    note: note,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is PaymentEntity && other.id == id && other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, updatedAt);
}
