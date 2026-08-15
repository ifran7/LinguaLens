import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../batches/domain/entities/batch_entity.dart';
import '../../domain/entities/attendance_status.dart';
import '../../providers/attendance_provider.dart';

class AttendanceBatchCard extends ConsumerWidget {
  const AttendanceBatchCard({
    super.key,
    required this.batch,
    required this.date,
    required this.onMark,
  });

  final BatchEntity batch;
  final DateTime date;
  final VoidCallback onMark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = AttendanceBatchDateArgs(batchId: batch.id, date: date);
    final summary = ref.watch(batchAttendanceDaySummaryProvider(args));
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 5,
                height: 66,
                decoration: BoxDecoration(
                  color: batch.color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      batch.subject,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (batch.scheduleText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 15),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              batch.scheduleText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onMark,
                icon: const Icon(Icons.edit_calendar_rounded, size: 17),
                label: Text(context.l10n.t('markAttendance')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          summary.when(
            loading: () => const LinearProgressIndicator(minHeight: 3),
            error: (_, _) => Text(context.l10n.t('errorGeneric')),
            data: (value) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${context.l10n.t('marked')} ${value.markedCount}/${value.expectedStudentCount}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const Spacer(),
                    Text(
                      '${context.l10n.t('unmarked')}: ${value.unmarkedCount}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: value.unmarkedCount == 0
                            ? AttendanceStatus.present.color
                            : AttendanceStatus.absent.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: value.expectedStudentCount == 0
                        ? 0
                        : value.markedCount / value.expectedStudentCount,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      value.unmarkedCount == 0
                          ? AttendanceStatus.present.color
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    _TinyCount(
                      status: AttendanceStatus.present,
                      count: value.presentCount,
                      context: context,
                    ),
                    _TinyCount(
                      status: AttendanceStatus.absent,
                      count: value.absentCount,
                      context: context,
                    ),
                    _TinyCount(
                      status: AttendanceStatus.late,
                      count: value.lateCount,
                      context: context,
                    ),
                    _TinyCount(
                      status: AttendanceStatus.leave,
                      count: value.leaveCount,
                      context: context,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyCount extends StatelessWidget {
  const _TinyCount({
    required this.status,
    required this.count,
    required this.context,
  });

  final AttendanceStatus status;
  final int count;
  final BuildContext context;

  @override
  Widget build(BuildContext _) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(status.icon, size: 14, color: status.color),
      const SizedBox(width: 3),
      Text('$count', style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}
