import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/batch_entity.dart';
import '../../providers/batch_provider.dart';

class BatchCard extends ConsumerWidget {
  const BatchCard({
    super.key,
    required this.batch,
    required this.onTap,
    required this.onLongPress,
  });

  final BatchEntity batch;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(batchStudentCountProvider(batch.id));
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 8, color: batch.color),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          batch.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _Badge(
                        text: batch.subject,
                        color: batch.color.withValues(alpha: 0.12),
                        foreground: batch.color,
                      ),
                    ],
                  ),
                  if (batch.scheduleText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            batch.scheduleText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt_outlined,
                        size: 18,
                        color: batch.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        count.when(
                          data: (value) =>
                              '$value ${context.l10n.t('students').toLowerCase()}',
                          loading: () =>
                              '… ${context.l10n.t('students').toLowerCase()}',
                          error: (_, _) =>
                              '— ${context.l10n.t('students').toLowerCase()}',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${formatFee(batch.monthlyFeeDefault)}${context.l10n.t('perMonth')}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: batch.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _Badge(
                    text: batch.isActive
                        ? context.l10n.t('batchActive')
                        : context.l10n.t('batchArchivedStatus'),
                    color: batch.isActive
                        ? Colors.green.withValues(alpha: 0.12)
                        : scheme.surfaceContainerHighest,
                    foreground: batch.isActive
                        ? Colors.green.shade700
                        : scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
    required this.foreground,
  });
  final String text;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
    ),
  );
}
