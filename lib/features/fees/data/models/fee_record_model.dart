import 'package:hive/hive.dart';

import '../../../../core/utils/hive_adapter_helpers.dart';

@HiveType(typeId: 5)
class FeeRecordModel extends HiveObject {
  FeeRecordModel({
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
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  String studentId;
  @HiveField(2)
  String batchId;
  @HiveField(3)
  String monthKey;
  @HiveField(4)
  double assignedFee;
  @HiveField(5)
  double discountAmount;
  @HiveField(6)
  double finalFee;
  @HiveField(7)
  String note;
  @HiveField(8)
  DateTime createdAt;
  @HiveField(9)
  DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'batchId': batchId,
    'monthKey': monthKey,
    'assignedFee': assignedFee,
    'discountAmount': discountAmount,
    'finalFee': finalFee,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory FeeRecordModel.fromJson(Map<String, dynamic> json) => FeeRecordModel(
    id: json['id'] as String,
    studentId: json['studentId'] as String,
    batchId: json['batchId'] as String,
    monthKey: json['monthKey'] as String,
    assignedFee: (json['assignedFee'] as num?)?.toDouble() ?? 0,
    discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
    finalFee: (json['finalFee'] as num?)?.toDouble() ?? 0,
    note: json['note'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class FeeRecordModelAdapter extends TypeAdapter<FeeRecordModel> {
  @override
  final int typeId = 5;

  @override
  FeeRecordModel read(BinaryReader reader) {
    final fields = readHiveFields(reader);
    return FeeRecordModel(
      id: hiveString(fields, 0),
      studentId: hiveString(fields, 1),
      batchId: hiveString(fields, 2),
      monthKey: hiveString(fields, 3),
      assignedFee: hiveDouble(fields, 4),
      discountAmount: hiveDouble(fields, 5),
      finalFee: hiveDouble(fields, 6),
      note: hiveString(fields, 7),
      createdAt: hiveDate(fields, 8),
      updatedAt: hiveDate(fields, 9),
    );
  }

  @override
  void write(BinaryWriter writer, FeeRecordModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.batchId)
      ..writeByte(3)
      ..write(obj.monthKey)
      ..writeByte(4)
      ..write(obj.assignedFee)
      ..writeByte(5)
      ..write(obj.discountAmount)
      ..writeByte(6)
      ..write(obj.finalFee)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }
}
