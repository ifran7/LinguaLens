import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/message_enums.dart';
import '../../providers/message_provider.dart';

class MessagesCenterScreen extends ConsumerWidget {
  const MessagesCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stats = ref.watch(messageStatsProvider);
    final templates = ref.watch(messageTemplatesProvider);
    final logs = ref.watch(recentMessageLogsProvider);
    return AppPage(
      title: l10n.t('messages'),
      action: IconButton(
        tooltip: l10n.t('messageTemplates'),
        onPressed: () => context.push('/messages/templates'),
        icon: const Icon(Icons.tune_rounded),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(messageStatsProvider);
          ref.invalidate(messageTemplatesProvider);
          ref.invalidate(recentMessageLogsProvider);
          await ref.read(messageStatsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              l10n.t('messageCenterTitle'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.t('messageCenterSubtitle'),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            stats.when(
              data: (value) => Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: l10n.t('messagesSent'),
                      value: '${value.total}',
                      icon: Icons.send_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      label: l10n.t('whatsapp'),
                      value: '${value.whatsapp}',
                      icon: Icons.chat_rounded,
                      color: const Color(0xFF25D366),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      label: l10n.t('sms'),
                      value: '${value.sms}',
                      icon: Icons.sms_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: l10n.t('quickMessage'),
              actionLabel: l10n.t('viewHistory'),
              onAction: () => context.push('/messages/logs'),
            ),
            AppCard(
              child: Column(
                children: [
                  _MessageAction(
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFFF59E0B),
                    label: l10n.t('feeReminder'),
                    onTap: () => _openComposer(context),
                  ),
                  const Divider(height: 8),
                  _MessageAction(
                    icon: Icons.fact_check_rounded,
                    color: const Color(0xFFEF4444),
                    label: l10n.t('attendanceAlert'),
                    onTap: () => _openComposer(context),
                  ),
                  const Divider(height: 8),
                  _MessageAction(
                    icon: Icons.trending_up_rounded,
                    color: AppColors.secondary,
                    label: l10n.t('progressUpdate'),
                    onTap: () => _openComposer(context),
                  ),
                  const Divider(height: 8),
                  _MessageAction(
                    icon: Icons.edit_note_rounded,
                    color: AppColors.primary,
                    label: l10n.t('customMessage'),
                    onTap: () => _openComposer(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: l10n.t('messageTemplates'),
              actionLabel: l10n.t('seeAll'),
              onAction: () => context.push('/messages/templates'),
            ),
            templates.when(
              data: (items) => items.isEmpty
                  ? Text(
                      l10n.t('noTemplates'),
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.muted),
                    )
                  : SizedBox(
                      height: 132,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.take(5).length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return SizedBox(
                            width: 220,
                            child: AppCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    item.category.icon,
                                    color: item.category.color,
                                  ),
                                  const Spacer(),
                                  Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.category.label(l10n),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => Text(
                l10n.t('couldNotLoad'),
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: l10n.t('recentMessages'),
              actionLabel: l10n.t('seeAll'),
              onAction: () => context.push('/messages/logs'),
            ),
            logs.when(
              data: (items) => items.isEmpty
                  ? Text(
                      l10n.t('noMessagesYet'),
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.muted),
                    )
                  : AppCard(
                      child: Column(
                        children: [
                          for (final item in items.take(5)) _LogRow(log: item),
                        ],
                      ),
                    ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => Text(
                l10n.t('couldNotLoad'),
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openComposer(BuildContext context) => context.push('/messages/compose');
}

class _MessageAction extends StatelessWidget {
  const _MessageAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: IconBadge(icon: icon, color: color, size: 42),
    title: Text(label),
    trailing: const Icon(Icons.chevron_right_rounded),
    onTap: onTap,
  );
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.log});
  final dynamic log;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: IconBadge(
      icon: log.channel.icon,
      color: log.channel.color,
      size: 40,
    ),
    title: Text(log.category.label(context.l10n)),
    subtitle: Text(
      log.messageBody,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: Text(
      '${log.sentAt.day}/${log.sentAt.month}',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}
