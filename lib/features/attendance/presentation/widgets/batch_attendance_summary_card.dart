import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/attendance_status.dart';
import '../../providers/attendance_provider.dart';

class BatchAttendanceSummaryCard extends ConsumerWidget {
  const BatchAttendanceSummaryCard({super.key, required this.batchId});

  final String batchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = normalizeDate(DateTime.now());
    final args = AttendanceBatchDateArgs(batchId: batchId, date: date);
    final summary = ref.watch(batchAttendanceDaySummaryProvider(args));
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.t('attendanceSummary'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: () =>
                    context.push('/attendance/batch/$batchId', extra: date),
                icon: const Icon(Icons.edit_calendar_rounded, size: 17),
                label: Text(context.l10n.t('markAttendance')),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _Count(
                      status: AttendanceStatus.present,
                      count: value.presentCount,
                    ),
                    _Count(
                      status: AttendanceStatus.absent,
                      count: value.absentCount,
                    ),
                    _Count(
                      status: AttendanceStatus.late,
                      count: value.lateCount,
                    ),
                    _Count(
                      status: AttendanceStatus.leave,
                      count: value.leaveCount,
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

class _Count extends StatelessWidget {
  const _Count({required this.status, required this.count});

  final AttendanceStatus status;
  final int count;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(status.icon, size: 15, color: status.color),
      const SizedBox(width: 4),
      Text('$count'),
    ],
  );
}
