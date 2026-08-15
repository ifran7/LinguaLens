import 'package:hive/hive.dart';

import '../../../../core/utils/hive_adapter_helpers.dart';

@HiveType(typeId: 6)
class PaymentModel extends HiveObject {
  PaymentModel({
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

  @HiveField(0)
  String id;
  @HiveField(1)
  String feeRecordId;
  @HiveField(2)
  String studentId;
  @HiveField(3)
  String batchId;
  @HiveField(4)
  String monthKey;
  @HiveField(5)
  double amount;
  @HiveField(6)
  DateTime paymentDate;
  @HiveField(7)
  String paymentMethod;
  @HiveField(8)
  String note;
  @HiveField(9)
  DateTime createdAt;
  @HiveField(10)
  DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'feeRecordId': feeRecordId,
    'studentId': studentId,
    'batchId': batchId,
    'monthKey': monthKey,
    'amount': amount,
    'paymentDate': paymentDate.toIso8601String(),
    'paymentMethod': paymentMethod,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'] as String,
    feeRecordId: json['feeRecordId'] as String,
    studentId: json['studentId'] as String,
    batchId: json['batchId'] as String,
    monthKey: json['monthKey'] as String,
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    paymentDate:
        DateTime.tryParse(json['paymentDate'] as String? ?? '') ??
        DateTime.now(),
    paymentMethod: json['paymentMethod'] as String? ?? 'cash',
    note: json['note'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class PaymentModelAdapter extends TypeAdapter<PaymentModel> {
  @override
  final int typeId = 6;

  @override
  PaymentModel read(BinaryReader reader) {
    final fields = readHiveFields(reader);
    return PaymentModel(
      id: hiveString(fields, 0),
      feeRecordId: hiveString(fields, 1),
      studentId: hiveString(fields, 2),
      batchId: hiveString(fields, 3),
      monthKey: hiveString(fields, 4),
      amount: hiveDouble(fields, 5),
      paymentDate: hiveDate(fields, 6),
      paymentMethod: hiveString(fields, 7, 'cash'),
      note: hiveString(fields, 8),
      createdAt: hiveDate(fields, 9),
      updatedAt: hiveDate(fields, 10),
    );
  }

  @override
  void write(BinaryWriter writer, PaymentModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.feeRecordId)
      ..writeByte(2)
      ..write(obj.studentId)
      ..writeByte(3)
      ..write(obj.batchId)
      ..writeByte(4)
      ..write(obj.monthKey)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.paymentDate)
      ..writeByte(7)
      ..write(obj.paymentMethod)
      ..writeByte(8)
      ..write(obj.note)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }
}
