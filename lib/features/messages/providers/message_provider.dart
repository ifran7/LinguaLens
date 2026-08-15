import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/message_repository_impl.dart';
import '../domain/entities/message_entities.dart';
import '../domain/entities/message_enums.dart';
import '../domain/repositories/message_repositories.dart';

final messageTemplateRepositoryProvider = Provider<MessageTemplateRepository>(
  (_) => MessageTemplateRepositoryImpl(),
);

final messageLogRepositoryProvider = Provider<MessageLogRepository>(
  (_) => MessageLogRepositoryImpl(),
);

final messageTemplatesProvider = FutureProvider<List<MessageTemplateEntity>>((
  ref,
) async {
  return ref.read(messageTemplateRepositoryProvider).getAllTemplates();
});

final messageTemplatesByCategoryProvider =
    FutureProvider.family<List<MessageTemplateEntity>, MessageCategory>((
      ref,
      category,
    ) async {
      return ref
          .read(messageTemplateRepositoryProvider)
          .getTemplatesByCategory(category);
    });

final messageLogsProvider = FutureProvider<List<MessageLogEntity>>((ref) async {
  return ref.read(messageLogRepositoryProvider).getAllLogs();
});

final recentMessageLogsProvider = FutureProvider<List<MessageLogEntity>>((
  ref,
) async {
  return ref.read(messageLogRepositoryProvider).getRecentLogs(12);
});

final studentMessageLogsProvider =
    FutureProvider.family<List<MessageLogEntity>, String>((
      ref,
      studentId,
    ) async {
      return ref.read(messageLogRepositoryProvider).getLogsByStudent(studentId);
    });

final lastMessageForStudentProvider =
    FutureProvider.family<MessageLogEntity?, String>((ref, studentId) async {
      return ref
          .read(messageLogRepositoryProvider)
          .getLastMessageForStudent(studentId);
    });

final messageStatsProvider = FutureProvider<MessageStats>((ref) async {
  final logs = await ref.read(messageLogRepositoryProvider).getAllLogs();
  final whatsapp = logs
      .where((item) => item.channel == MessageChannel.whatsapp)
      .length;
  final sms = logs.where((item) => item.channel == MessageChannel.sms).length;
  return MessageStats(total: logs.length, whatsapp: whatsapp, sms: sms);
});

class MessageStats {
  const MessageStats({
    required this.total,
    required this.whatsapp,
    required this.sms,
  });

  final int total;
  final int whatsapp;
  final int sms;
}

void invalidateMessageProviders(dynamic ref, {String? studentId}) {
  ref.invalidate(messageTemplatesProvider);
  ref.invalidate(messageLogsProvider);
  ref.invalidate(recentMessageLogsProvider);
  ref.invalidate(messageStatsProvider);
  if (studentId != null) {
    ref.invalidate(studentMessageLogsProvider(studentId));
    ref.invalidate(lastMessageForStudentProvider(studentId));
  }
}
