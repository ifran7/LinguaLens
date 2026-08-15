import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/attendance_status.dart';
import '../../providers/attendance_provider.dart';

class StudentAttendanceSummaryCard extends ConsumerWidget {
  const StudentAttendanceSummaryCard({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(studentAttendanceSummaryProvider(studentId));
    return AppCard(
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
                    context.push('/students/$studentId/attendance'),
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: Text(context.l10n.t('viewAll')),
              ),
            ],
          ),
          const SizedBox(height: 10),
          summary.when(
            loading: () => const LinearProgressIndicator(minHeight: 3),
            error: (_, _) => Text(context.l10n.t('errorGeneric')),
            data: (value) {
              if (value.totalMarkedDays == 0) {
                return Text(context.l10n.t('noAttendanceRecordsYet'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${value.attendancePercentage.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: _percentageColor(
                                value.attendancePercentage,
                              ),
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${value.totalMarkedDays} ${context.l10n.t('marked').toLowerCase()}',
                        style: Theme.of(context).textTheme.bodySmall,
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
              );
            },
          ),
        ],
      ),
    );
  }

  Color _percentageColor(double percentage) {
    if (percentage >= 80) return AttendanceStatus.present.color;
    if (percentage >= 60) return AttendanceStatus.late.color;
    return AttendanceStatus.absent.color;
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
