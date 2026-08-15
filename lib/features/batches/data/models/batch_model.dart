import 'package:hive/hive.dart';

import '../../../../core/utils/hive_adapter_helpers.dart';

@HiveType(typeId: 2)
class BatchModel extends HiveObject {
  BatchModel({
    required this.id,
    required this.name,
    required this.subject,
    this.description = '',
    this.scheduleText = '',
    this.monthlyFeeDefault = 0,
    this.colorTagIndex = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String subject;
  @HiveField(3)
  String description;
  @HiveField(4)
  String scheduleText;
  @HiveField(5)
  double monthlyFeeDefault;
  @HiveField(6)
  int colorTagIndex;
  @HiveField(7)
  bool isActive;
  @HiveField(8)
  DateTime createdAt;
  @HiveField(9)
  DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subject': subject,
    'description': description,
    'scheduleText': scheduleText,
    'monthlyFeeDefault': monthlyFeeDefault,
    'colorTagIndex': colorTagIndex,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory BatchModel.fromJson(Map<String, dynamic> json) => BatchModel(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    subject: json['subject'] as String? ?? '',
    description: json['description'] as String? ?? '',
    scheduleText: json['scheduleText'] as String? ?? '',
    monthlyFeeDefault: (json['monthlyFeeDefault'] as num?)?.toDouble() ?? 0,
    colorTagIndex: (json['colorTagIndex'] as num?)?.toInt() ?? 0,
    isActive: json['isActive'] as bool? ?? true,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class BatchModelAdapter extends TypeAdapter<BatchModel> {
  @override
  final int typeId = 2;

  @override
  BatchModel read(BinaryReader reader) {
    final fields = readHiveFields(reader);
    return BatchModel(
      id: hiveString(fields, 0),
      name: hiveString(fields, 1),
      subject: hiveString(fields, 2),
      description: hiveString(fields, 3),
      scheduleText: hiveString(fields, 4),
      monthlyFeeDefault: (fields[5] as num?)?.toDouble() ?? 0,
      colorTagIndex: hiveInt(fields, 6),
      isActive: hiveBool(fields, 7, true),
      createdAt: hiveDate(fields, 8),
      updatedAt: hiveDate(fields, 9),
    );
  }

  @override
  void write(BinaryWriter writer, BatchModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.subject)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.scheduleText)
      ..writeByte(5)
      ..write(obj.monthlyFeeDefault)
      ..writeByte(6)
      ..write(obj.colorTagIndex)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }
}
