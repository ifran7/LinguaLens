import 'package:hive/hive.dart';

@HiveType(typeId: 10)
class MessageLogModel extends HiveObject {
  MessageLogModel({
    required this.id,
    required this.studentId,
    this.batchId = '',
    required this.channel,
    required this.recipientPhone,
    required this.messageBody,
    this.templateId = '',
    this.category = 'custom',
    this.teacherNote = '',
    required this.sentAt,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  String studentId;
  @HiveField(2)
  String batchId;
  @HiveField(3)
  String channel;
  @HiveField(4)
  String recipientPhone;
  @HiveField(5)
  String messageBody;
  @HiveField(6)
  String templateId;
  @HiveField(7)
  String category;
  @HiveField(8)
  String teacherNote;
  @HiveField(9)
  DateTime sentAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'batchId': batchId,
    'channel': channel,
    'recipientPhone': recipientPhone,
    'messageBody': messageBody,
    'templateId': templateId,
    'category': category,
    'teacherNote': teacherNote,
    'sentAt': sentAt.toIso8601String(),
  };

  factory MessageLogModel.fromJson(Map<String, dynamic> json) =>
      MessageLogModel(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        batchId: json['batchId'] as String? ?? '',
        channel: json['channel'] as String? ?? 'whatsapp',
        recipientPhone: json['recipientPhone'] as String? ?? '',
        messageBody: json['messageBody'] as String? ?? '',
        templateId: json['templateId'] as String? ?? '',
        category: json['category'] as String? ?? 'custom',
        teacherNote: json['teacherNote'] as String? ?? '',
        sentAt:
            DateTime.tryParse(json['sentAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class MessageLogModelAdapter extends TypeAdapter<MessageLogModel> {
  @override
  final int typeId = 10;

  @override
  MessageLogModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return MessageLogModel(
      id: fields[0] as String,
      studentId: fields[1] as String,
      batchId: fields[2] as String? ?? '',
      channel: fields[3] as String? ?? 'whatsapp',
      recipientPhone: fields[4] as String? ?? '',
      messageBody: fields[5] as String? ?? '',
      templateId: fields[6] as String? ?? '',
      category: fields[7] as String? ?? 'custom',
      teacherNote: fields[8] as String? ?? '',
      sentAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MessageLogModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.studentId)
      ..writeByte(2)
      ..write(obj.batchId)
      ..writeByte(3)
      ..write(obj.channel)
      ..writeByte(4)
      ..write(obj.recipientPhone)
      ..writeByte(5)
      ..write(obj.messageBody)
      ..writeByte(6)
      ..write(obj.templateId)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.teacherNote)
      ..writeByte(9)
      ..write(obj.sentAt);
  }
}
