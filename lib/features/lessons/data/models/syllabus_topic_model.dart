import 'package:hive/hive.dart';

import '../../../../core/utils/hive_adapter_helpers.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'batchId': batchId,
    'title': title,
    'description': description,
    'orderIndex': orderIndex,
    'isCompleted': isCompleted,
    'completedDate': completedDate?.toIso8601String(),
    'chapterName': chapterName,
    'estimatedClasses': estimatedClasses,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory SyllabusTopicModel.fromJson(
    Map<String, dynamic> json,
  ) => SyllabusTopicModel(
    id: json['id'] as String,
    batchId: json['batchId'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
    isCompleted: json['isCompleted'] as bool? ?? false,
    completedDate: DateTime.tryParse(json['completedDate'] as String? ?? ''),
    chapterName: json['chapterName'] as String? ?? '',
    estimatedClasses: (json['estimatedClasses'] as num?)?.toInt() ?? 1,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class SyllabusTopicModelAdapter extends TypeAdapter<SyllabusTopicModel> {
  @override
  final int typeId = 8;

  @override
  SyllabusTopicModel read(BinaryReader reader) {
    final fields = readHiveFields(reader);
    return SyllabusTopicModel(
      id: hiveString(fields, 0),
      batchId: hiveString(fields, 1),
      title: hiveString(fields, 2),
      description: hiveString(fields, 3),
      orderIndex: hiveInt(fields, 4),
      isCompleted: hiveBool(fields, 5),
      completedDate: hiveNullableDate(fields, 6),
      chapterName: hiveString(fields, 7),
      estimatedClasses: hiveInt(fields, 8, 1),
      createdAt: hiveDate(fields, 9),
      updatedAt: hiveDate(fields, 10),
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
