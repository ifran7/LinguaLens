import 'package:hive/hive.dart';

import '../../../../core/utils/hive_adapter_helpers.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'batchId': batchId,
    'title': title,
    'description': description,
    'lessonDate': lessonDate.toIso8601String(),
    'planType': planType,
    'status': status,
    'coveredTopicIds': coveredTopicIds,
    'homework': homework,
    'resourceLinks': resourceLinks,
    'durationMinutes': durationMinutes,
    'teacherNote': teacherNote,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory LessonPlanModel.fromJson(
    Map<String, dynamic> json,
  ) => LessonPlanModel(
    id: json['id'] as String,
    batchId: json['batchId'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    lessonDate:
        DateTime.tryParse(json['lessonDate'] as String? ?? '') ??
        DateTime.now(),
    planType: json['planType'] as String? ?? 'daily',
    status: json['status'] as String? ?? 'planned',
    coveredTopicIds: (json['coveredTopicIds'] as List?)
        ?.whereType<String>()
        .toList(),
    homework: json['homework'] as String? ?? '',
    resourceLinks: json['resourceLinks'] as String? ?? '',
    durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
    teacherNote: json['teacherNote'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class LessonPlanModelAdapter extends TypeAdapter<LessonPlanModel> {
  @override
  final int typeId = 7;

  @override
  LessonPlanModel read(BinaryReader reader) {
    final fields = readHiveFields(reader);
    return LessonPlanModel(
      id: hiveString(fields, 0),
      batchId: hiveString(fields, 1),
      title: hiveString(fields, 2),
      description: hiveString(fields, 3),
      lessonDate: hiveDate(fields, 4),
      planType: hiveString(fields, 5, 'daily'),
      status: hiveString(fields, 6, 'planned'),
      coveredTopicIds: hiveStringList(fields, 7),
      homework: hiveString(fields, 8),
      resourceLinks: hiveString(fields, 9),
      durationMinutes: hiveInt(fields, 10),
      teacherNote: hiveString(fields, 11),
      createdAt: hiveDate(fields, 12),
      updatedAt: hiveDate(fields, 13),
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
