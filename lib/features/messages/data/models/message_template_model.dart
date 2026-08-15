import 'package:hive/hive.dart';

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
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return MessageTemplateModel(
      id: fields[0] as String,
      title: fields[1] as String,
      bodyEn: fields[2] as String,
      bodyBn: fields[3] as String,
      category: fields[4] as String? ?? 'custom',
      isDefault: fields[5] as bool? ?? false,
      usageCount: fields[6] as int? ?? 0,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
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
