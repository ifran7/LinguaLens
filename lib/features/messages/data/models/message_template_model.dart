import 'package:hive/hive.dart';

import '../../../../core/utils/hive_adapter_helpers.dart';

@HiveType(typeId: 9)
class MessageTemplateModel extends HiveObject {
  MessageTemplateModel({
    required this.id,
    required this.title,
    required this.bodyEn,
    required this.bodyBn,
    required this.category,
    this.isDefault = false,
    this.usageCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String bodyEn;
  @HiveField(3)
  String bodyBn;
  @HiveField(4)
  String category;
  @HiveField(5)
  bool isDefault;
  @HiveField(6)
  int usageCount;
  @HiveField(7)
  DateTime createdAt;
  @HiveField(8)
  DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'bodyEn': bodyEn,
    'bodyBn': bodyBn,
    'category': category,
    'isDefault': isDefault,
    'usageCount': usageCount,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MessageTemplateModel.fromJson(
    Map<String, dynamic> json,
  ) => MessageTemplateModel(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    bodyEn: json['bodyEn'] as String? ?? '',
    bodyBn: json['bodyBn'] as String? ?? '',
    category: json['category'] as String? ?? 'custom',
    isDefault: json['isDefault'] as bool? ?? false,
    usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class MessageTemplateModelAdapter extends TypeAdapter<MessageTemplateModel> {
  @override
  final int typeId = 9;

  @override
  MessageTemplateModel read(BinaryReader reader) {
    final fields = readHiveFields(reader);
    return MessageTemplateModel(
      id: hiveString(fields, 0),
      title: hiveString(fields, 1),
      bodyEn: hiveString(fields, 2),
      bodyBn: hiveString(fields, 3),
      category: hiveString(fields, 4, 'custom'),
      isDefault: hiveBool(fields, 5),
      usageCount: hiveInt(fields, 6),
      createdAt: hiveDate(fields, 7),
      updatedAt: hiveDate(fields, 8),
    );
  }

  @override
  void write(BinaryWriter writer, MessageTemplateModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.bodyEn)
      ..writeByte(3)
      ..write(obj.bodyBn)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.isDefault)
      ..writeByte(6)
      ..write(obj.usageCount)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }
}
