import '../entities/message_entities.dart';
import '../entities/message_enums.dart';

abstract class MessageTemplateRepository {
  Future<List<MessageTemplateEntity>> getAllTemplates();
  Future<List<MessageTemplateEntity>> getTemplatesByCategory(
    MessageCategory category,
  );
  Future<MessageTemplateEntity?> getTemplateById(String id);
  Future<void> addTemplate(MessageTemplateEntity template);
  Future<void> updateTemplate(MessageTemplateEntity template);
  Future<void> deleteTemplate(String id);
  Future<void> incrementUsageCount(String id);
  Future<List<MessageTemplateEntity>> getMostUsedTemplates(int limit);
}

abstract class MessageLogRepository {
  Future<List<MessageLogEntity>> getAllLogs();
  Future<List<MessageLogEntity>> getLogsByStudent(String studentId);
  Future<List<MessageLogEntity>> getLogsByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<MessageLogEntity?> getLastMessageForStudent(String studentId);
  Future<void> addLog(MessageLogEntity log);
  Future<void> deleteLog(String id);
  Future<void> deleteLogsByStudent(String studentId);
  Future<int> getTotalMessagesSent();
  Future<List<MessageLogEntity>> getRecentLogs(int limit);
}
