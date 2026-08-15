import 'package:hive/hive.dart';

@HiveType(typeId: 7)
class LessonPlanModel extends HiveObject {
  LessonPlanModel({
    required this.id,
    required this.batchId,
    this.title = '',
    this.description = '',
    required this.lessonDate,
    this.planType = 'daily',
    this.status = 'planned',
    List<String>? coveredTopicIds,
    this.homework = '',
    this.resourceLinks = '',
    this.durationMinutes = 0,
    this.teacherNote = '',
    required this.createdAt,
    required this.updatedAt,
  }) : coveredTopicIds = List<String>.from(coveredTopicIds ?? const []);

  @HiveField(0)
  String id;
  @HiveField(1)
  String batchId;
  @HiveField(2)
  String title;
  @HiveField(3)
  String description;
  @HiveField(4)
  DateTime lessonDate;
  @HiveField(5)
  String planType;
  @HiveField(6)
  String status;
  @HiveField(7)
  List<String> coveredTopicIds;
  @HiveField(8)
  String homework;
  @HiveField(9)
  String resourceLinks;
  @HiveField(10)
  int durationMinutes;
  @HiveField(11)
  String teacherNote;
  @HiveField(12)
  DateTime createdAt;
  @HiveField(13)
  DateTime updatedAt;
}

class LessonPlanModelAdapter extends TypeAdapter<LessonPlanModel> {
  @override
  final int typeId = 7;

  @override
  LessonPlanModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return LessonPlanModel(
      id: fields[0] as String? ?? '',
      batchId: fields[1] as String? ?? '',
      title: fields[2] as String? ?? '',
      description: fields[3] as String? ?? '',
      lessonDate: fields[4] is DateTime
          ? fields[4] as DateTime
          : DateTime.now(),
      planType: fields[5] as String? ?? 'daily',
      status: fields[6] as String? ?? 'planned',
      coveredTopicIds:
          (fields[7] as List?)?.whereType<String>().toList() ?? const [],
      homework: fields[8] as String? ?? '',
      resourceLinks: fields[9] as String? ?? '',
      durationMinutes: (fields[10] as num?)?.toInt() ?? 0,
      teacherNote: fields[11] as String? ?? '',
      createdAt: fields[12] is DateTime
          ? fields[12] as DateTime
          : DateTime.now(),
      updatedAt: fields[13] is DateTime
          ? fields[13] as DateTime
          : DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, LessonPlanModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.batchId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.lessonDate)
      ..writeByte(5)
      ..write(obj.planType)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.coveredTopicIds)
      ..writeByte(8)
      ..write(obj.homework)
      ..writeByte(9)
      ..write(obj.resourceLinks)
      ..writeByte(10)
      ..write(obj.durationMinutes)
      ..writeByte(11)
      ..write(obj.teacherNote)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }
}
