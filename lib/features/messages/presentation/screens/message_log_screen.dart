import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/message_entities.dart';
import '../../domain/entities/message_enums.dart';
import '../../providers/message_provider.dart';

class MessageLogScreen extends ConsumerStatefulWidget {
  const MessageLogScreen({super.key, this.studentId});
  final String? studentId;

  @override
  ConsumerState<MessageLogScreen> createState() => _MessageLogScreenState();
}

class _MessageLogScreenState extends ConsumerState<MessageLogScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search.addListener(
      () => setState(() => _query = _search.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final logs = ref.watch(
      widget.studentId == null
          ? messageLogsProvider
          : studentMessageLogsProvider(widget.studentId!),
    );
    return AppPage(
      title: l10n.t('messageHistory'),
      showBack: true,
      child: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.t('couldNotLoad'))),
        data: (items) {
          final filtered = items
              .where(
                (item) =>
                    item.messageBody.toLowerCase().contains(_query) ||
                    item.recipientPhone.contains(_query) ||
                    item.category.label(l10n).toLowerCase().contains(_query),
              )
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: TextField(
                  controller: _search,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search_rounded),
                    labelText: l10n.t('searchMessages'),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: _search.clear,
                            icon: const Icon(Icons.clear_rounded),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.history_rounded,
                        title: l10n.t('noMessagesYet'),
                        body: l10n.t('noMessagesBody'),
                        cta: l10n.t('composeMessage'),
                        onPressed: () => context.push('/messages/compose'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _LogCard(
                          log: filtered[index],
                          onDelete: () async {
                            await ref
                                .read(messageLogRepositoryProvider)
                                .deleteLog(filtered[index].id);
                            ref.invalidate(messageLogsProvider);
                            if (widget.studentId != null) {
                              ref.invalidate(
                                studentMessageLogsProvider(widget.studentId!),
                              );
                            }
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.log, required this.onDelete});
  final MessageLogEntity log;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconBadge(
              icon: log.channel.icon,
              color: log.channel.color,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.category.label(context.l10n),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    '${log.channel.label(context.l10n)} • ${log.recipientPhone}',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(log.messageBody),
        const SizedBox(height: 8),
        Text(
          '${log.sentAt.day}/${log.sentAt.month}/${log.sentAt.year} ${log.sentAt.hour.toString().padLeft(2, '0')}:${log.sentAt.minute.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.muted),
        ),
      ],
    ),
  );
}
