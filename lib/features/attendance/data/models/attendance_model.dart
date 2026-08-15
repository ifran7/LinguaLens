import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class AttendanceModel extends HiveObject {
  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.date,
    required this.status,
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
  DateTime date;
  @HiveField(4)
  String status;
  @HiveField(5)
  String note;
  @HiveField(6)
  DateTime createdAt;
  @HiveField(7)
  DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'batchId': batchId,
    'date': date.toIso8601String(),
    'status': status,
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory AttendanceModel.fromJson(
    Map<String, dynamic> json,
  ) => AttendanceModel(
    id: json['id'] as String,
    studentId: json['studentId'] as String,
    batchId: json['batchId'] as String,
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    status: json['status'] as String? ?? 'present',
    note: json['note'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class AttendanceModelAdapter extends TypeAdapter<AttendanceModel> {
  @override
  final int typeId = 4;

  @override
  AttendanceModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return AttendanceModel(
      id: fields[0] as String,
      studentId: fields[1] as String,
      batchId: fields[2] as String,
      date: fields[3] as DateTime,
      status: fields[4] as String,
      note: fields[5] as String? ?? '',
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.batchId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }
}
