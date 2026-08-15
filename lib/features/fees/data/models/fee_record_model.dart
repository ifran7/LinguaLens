import 'package:hive/hive.dart';

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
}

class FeeRecordModelAdapter extends TypeAdapter<FeeRecordModel> {
  @override
  final int typeId = 5;

  @override
  FeeRecordModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return FeeRecordModel(
      id: fields[0] as String,
      studentId: fields[1] as String,
      batchId: fields[2] as String,
      monthKey: fields[3] as String,
      assignedFee: (fields[4] as num).toDouble(),
      discountAmount: (fields[5] as num?)?.toDouble() ?? 0,
      finalFee: (fields[6] as num).toDouble(),
      note: fields[7] as String? ?? '',
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
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
