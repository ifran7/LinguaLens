import 'package:hive/hive.dart';

import '../../../../core/utils/hive_adapter_helpers.dart';

@HiveType(typeId: 3)
class BatchEnrollmentModel extends HiveObject {
  BatchEnrollmentModel({
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

  @HiveField(0)
  String id;
  @HiveField(1)
  String studentId;
  @HiveField(2)
  String batchId;
  @HiveField(3)
  DateTime joiningDate;
  @HiveField(4)
  double customFee;
  @HiveField(5)
  bool isActive;
  @HiveField(6)
  String note;
  @HiveField(7)
  DateTime createdAt;
  @HiveField(8)
  DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'batchId': batchId,
    'joiningDate': joiningDate.toIso8601String(),
    'customFee': customFee,
    'isActive': isActive,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory BatchEnrollmentModel.fromJson(
    Map<String, dynamic> json,
  ) => BatchEnrollmentModel(
    id: json['id'] as String,
    studentId: json['studentId'] as String,
    batchId: json['batchId'] as String,
    joiningDate:
        DateTime.tryParse(json['joiningDate'] as String? ?? '') ??
        DateTime.now(),
    customFee: (json['customFee'] as num?)?.toDouble() ?? 0,
    isActive: json['isActive'] as bool? ?? true,
    note: json['note'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class BatchEnrollmentModelAdapter extends TypeAdapter<BatchEnrollmentModel> {
  @override
  final int typeId = 3;

  @override
  BatchEnrollmentModel read(BinaryReader reader) {
    final fields = readHiveFields(reader);
    return BatchEnrollmentModel(
      id: hiveString(fields, 0),
      studentId: hiveString(fields, 1),
      batchId: hiveString(fields, 2),
      joiningDate: hiveDate(fields, 3),
      customFee: hiveDouble(fields, 4),
      isActive: hiveBool(fields, 5, true),
      note: hiveString(fields, 6),
      createdAt: hiveDate(fields, 7),
      updatedAt: hiveDate(fields, 8),
    );
  }

  @override
  void write(BinaryWriter writer, BatchEnrollmentModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.batchId)
      ..writeByte(3)
      ..write(obj.joiningDate)
      ..writeByte(4)
      ..write(obj.customFee)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }
}
