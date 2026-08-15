import 'package:hive/hive.dart';

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
}

class BatchEnrollmentModelAdapter extends TypeAdapter<BatchEnrollmentModel> {
  @override
  final int typeId = 3;

  @override
  BatchEnrollmentModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return BatchEnrollmentModel(
      id: fields[0] as String,
      studentId: fields[1] as String,
      batchId: fields[2] as String,
      joiningDate: fields[3] as DateTime,
      customFee: (fields[4] as num?)?.toDouble() ?? 0,
      isActive: fields[5] as bool? ?? true,
      note: fields[6] as String? ?? '',
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
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
