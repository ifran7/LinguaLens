import 'package:hive/hive.dart';

import '../../domain/entities/message_entities.dart';
import '../../domain/entities/message_enums.dart';
import '../../domain/repositories/message_repositories.dart';
import '../models/message_log_model.dart';
import '../models/message_template_model.dart';

class MessageTemplateRepositoryImpl implements MessageTemplateRepository {
  Box<MessageTemplateModel> get _box =>
      Hive.box<MessageTemplateModel>('messageTemplatesBox');

  @override
  Future<List<MessageTemplateEntity>> getAllTemplates() async =>
      _box.values.map(MessageTemplateEntity.fromModel).toList()
        ..sort((a, b) => a.category.index.compareTo(b.category.index));

  @override
  Future<List<MessageTemplateEntity>> getTemplatesByCategory(
    MessageCategory category,
  ) async => (await getAllTemplates())
      .where((item) => item.category == category)
      .toList();

  @override
  Future<MessageTemplateEntity?> getTemplateById(String id) async {
    final model = _box.get(id);
    return model == null ? null : MessageTemplateEntity.fromModel(model);
  }

  @override
  Future<void> addTemplate(MessageTemplateEntity template) async =>
      _box.put(template.id, template.toModel());

  @override
  Future<void> updateTemplate(MessageTemplateEntity template) async =>
      _box.put(template.id, template.toModel());

  @override
  Future<void> deleteTemplate(String id) async => _box.delete(id);

  @override
  Future<void> incrementUsageCount(String id) async {
    final model = _box.get(id);
    if (model == null) return;
    model.usageCount += 1;
    model.updatedAt = DateTime.now();
    await model.save();
  }

  @override
  Future<List<MessageTemplateEntity>> getMostUsedTemplates(int limit) async {
    final templates = await getAllTemplates();
    templates.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return templates.take(limit).toList();
  }
}

class MessageLogRepositoryImpl implements MessageLogRepository {
  Box<MessageLogModel> get _box => Hive.box<MessageLogModel>('messageLogsBox');

  List<MessageLogEntity> _sorted(Iterable<MessageLogModel> values) {
    final logs = values.map(MessageLogEntity.fromModel).toList();
    logs.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return logs;
  }

  @override
  Future<List<MessageLogEntity>> getAllLogs() async => _sorted(_box.values);

  @override
  Future<List<MessageLogEntity>> getLogsByStudent(String studentId) async =>
      _sorted(_box.values.where((item) => item.studentId == studentId));

  @override
  Future<List<MessageLogEntity>> getLogsByDateRange(
    DateTime start,
    DateTime end,
  ) async => _sorted(
    _box.values.where(
      (item) => !item.sentAt.isBefore(start) && item.sentAt.isBefore(end),
    ),
  );

  @override
  Future<MessageLogEntity?> getLastMessageForStudent(String studentId) async {
    final logs = await getLogsByStudent(studentId);
    return logs.isEmpty ? null : logs.first;
  }

  @override
  Future<void> addLog(MessageLogEntity log) async =>
      _box.put(log.id, log.toModel());

  @override
  Future<void> deleteLog(String id) async => _box.delete(id);

  @override
  Future<void> deleteLogsByStudent(String studentId) async {
    final ids = _box.values
        .where((item) => item.studentId == studentId)
        .map((item) => item.id)
        .toList();
    await _box.deleteAll(ids);
  }

  @override
  Future<int> getTotalMessagesSent() async => _box.length;

  @override
  Future<List<MessageLogEntity>> getRecentLogs(int limit) async =>
      (await getAllLogs()).take(limit).toList();
}
