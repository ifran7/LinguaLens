import 'package:hive/hive.dart';

@HiveType(typeId: 8)
class SyllabusTopicModel extends HiveObject {
  SyllabusTopicModel({
    required this.id,
    required this.batchId,
    this.title = '',
    this.description = '',
    this.orderIndex = 0,
    this.isCompleted = false,
    this.completedDate,
    this.chapterName = '',
    int estimatedClasses = 1,
    required this.createdAt,
    required this.updatedAt,
  }) : estimatedClasses = estimatedClasses < 1 ? 1 : estimatedClasses;

  @HiveField(0)
  String id;
  @HiveField(1)
  String batchId;
  @HiveField(2)
  String title;
  @HiveField(3)
  String description;
  @HiveField(4)
  int orderIndex;
  @HiveField(5)
  bool isCompleted;
  @HiveField(6)
  DateTime? completedDate;
  @HiveField(7)
  String chapterName;
  @HiveField(8)
  int estimatedClasses;
  @HiveField(9)
  DateTime createdAt;
  @HiveField(10)
  DateTime updatedAt;
}

class SyllabusTopicModelAdapter extends TypeAdapter<SyllabusTopicModel> {
  @override
  final int typeId = 8;

  @override
  SyllabusTopicModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return SyllabusTopicModel(
      id: fields[0] as String? ?? '',
      batchId: fields[1] as String? ?? '',
      title: fields[2] as String? ?? '',
      description: fields[3] as String? ?? '',
      orderIndex: (fields[4] as num?)?.toInt() ?? 0,
      isCompleted: fields[5] as bool? ?? false,
      completedDate: fields[6] is DateTime ? fields[6] as DateTime : null,
      chapterName: fields[7] as String? ?? '',
      estimatedClasses: (fields[8] as num?)?.toInt() ?? 1,
      createdAt: fields[9] is DateTime ? fields[9] as DateTime : DateTime.now(),
      updatedAt: fields[10] is DateTime
          ? fields[10] as DateTime
          : DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, SyllabusTopicModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.orderIndex)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.completedDate)
      ..writeByte(7)
      ..write(obj.chapterName)
      ..writeByte(8)
      ..write(obj.estimatedClasses)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }
}
