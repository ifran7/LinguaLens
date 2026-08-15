import 'package:flutter/foundation.dart';

import '../../data/models/message_log_model.dart';
import '../../data/models/message_template_model.dart';
import 'message_enums.dart';

class MessageTemplateEntity {
  const MessageTemplateEntity({
    required this.id,
    required this.title,
    required this.bodyEn,
    required this.bodyBn,
    required this.category,
    required this.isDefault,
    required this.usageCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String bodyEn;
  final String bodyBn;
  final MessageCategory category;
  final bool isDefault;
  final int usageCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  String bodyFor(String languageCode) => languageCode == 'bn' ? bodyBn : bodyEn;

  MessageTemplateEntity copyWith({
    String? title,
    String? bodyEn,
    String? bodyBn,
    MessageCategory? category,
    bool? isDefault,
    int? usageCount,
  }) => MessageTemplateEntity(
    id: id,
    title: title ?? this.title,
    bodyEn: bodyEn ?? this.bodyEn,
    bodyBn: bodyBn ?? this.bodyBn,
    category: category ?? this.category,
    isDefault: isDefault ?? this.isDefault,
    usageCount: usageCount ?? this.usageCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory MessageTemplateEntity.fromModel(MessageTemplateModel model) =>
      MessageTemplateEntity(
        id: model.id,
        title: model.title,
        bodyEn: model.bodyEn,
        bodyBn: model.bodyBn,
        category: MessageCategoryX.fromValue(model.category),
        isDefault: model.isDefault,
        usageCount: model.usageCount,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  MessageTemplateModel toModel() => MessageTemplateModel(
    id: id,
    title: title,
    bodyEn: bodyEn,
    bodyBn: bodyBn,
    category: category.value,
    isDefault: isDefault,
    usageCount: usageCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class MessageLogEntity {
  const MessageLogEntity({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.channel,
    required this.recipientPhone,
    required this.messageBody,
    required this.templateId,
    required this.category,
    required this.teacherNote,
    required this.sentAt,
  });

  final String id;
  final String studentId;
  final String batchId;
  final MessageChannel channel;
  final String recipientPhone;
  final String messageBody;
  final String templateId;
  final MessageCategory category;
  final String teacherNote;
  final DateTime sentAt;

  factory MessageLogEntity.fromModel(MessageLogModel model) => MessageLogEntity(
    id: model.id,
    studentId: model.studentId,
    batchId: model.batchId,
    channel: MessageChannelX.fromValue(model.channel),
    recipientPhone: model.recipientPhone,
    messageBody: model.messageBody,
    templateId: model.templateId,
    category: MessageCategoryX.fromValue(model.category),
    teacherNote: model.teacherNote,
    sentAt: model.sentAt,
  );

  MessageLogModel toModel() => MessageLogModel(
    id: id,
    studentId: studentId,
    batchId: batchId,
    channel: channel.value,
    recipientPhone: recipientPhone,
    messageBody: messageBody,
    templateId: templateId,
    category: category.value,
    teacherNote: teacherNote,
    sentAt: sentAt,
  );

  @override
  bool operator ==(Object other) => other is MessageLogEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class MessageLogView {
  const MessageLogView({
    required this.log,
    this.studentName = '',
    this.parentName = '',
  });

  final MessageLogEntity log;
  final String studentName;
  final String parentName;
}

bool sameMessageTemplate(MessageTemplateEntity a, MessageTemplateEntity b) =>
    listEquals([a.id], [b.id]);
