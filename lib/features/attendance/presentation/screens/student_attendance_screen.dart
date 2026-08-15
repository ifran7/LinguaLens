import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' hide normalizeDate;

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../batches/providers/batch_provider.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/attendance_status.dart';
import '../../providers/attendance_provider.dart';
import '../widgets/attendance_calendar_legend.dart';
import '../widgets/attendance_summary_chips.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  const StudentAttendanceScreen({
    super.key,
    required this.studentId,
    this.batchId,
  });

  final String studentId;
  final String? batchId;

  @override
  ConsumerState<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState
    extends ConsumerState<StudentAttendanceScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final today = normalizeDate(DateTime.now());
    _focusedDay = today;
    _selectedDay = today;
  }

  StudentAttendanceCalendarArgs get _calendarArgs {
    final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    return StudentAttendanceCalendarArgs(
      studentId: widget.studentId,
      startDate: start,
      endDate: end,
      batchId: widget.batchId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(
      studentAttendanceSummaryProvider(widget.studentId),
    );
    final calendar = ref.watch(
      studentAttendanceCalendarProvider(_calendarArgs),
    );
    final batchOverviews = ref.watch(
      studentBatchOverviewsProvider(widget.studentId),
    );
    final groups = calendar.when(
      data: (value) => value,
      loading: () => const [],
      error: (_, _) => const [],
    );
    final recordsByDay = <String, List<AttendanceEntity>>{
      for (final group in groups) dateKey(group.date): group.records,
    };
    final selectedRecords =
        recordsByDay[dateKey(_selectedDay ?? _focusedDay)] ?? const [];

    return AppPage(
      title: context.l10n.t('attendance'),
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          summary.when(
            loading: () => const LinearProgressIndicator(minHeight: 3),
            error: (_, _) => const SizedBox.shrink(),
            data: (value) => AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        context.l10n.t('attendanceSummary'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: (value.attendancePercentage / 100).clamp(0, 1),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(99),
                    valueColor: AlwaysStoppedAnimation(
                      _percentageColor(value.attendancePercentage),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AttendanceSummaryChips(
                    present: value.presentCount,
                    absent: value.absentCount,
                    late: value.lateCount,
                    leave: value.leaveCount,
                    unmarked: 0,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          batchOverviews.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (overviews) => overviews.isEmpty
                ? const SizedBox.shrink()
                : AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.t('batches'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        for (final overview in overviews)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: overview.batch.color.withValues(
                                alpha: 0.16,
                              ),
                              child: Icon(
                                Icons.groups_rounded,
                                size: 17,
                                color: overview.batch.color,
                              ),
                            ),
                            title: Text(overview.batch.name),
                            subtitle: Text(
                              '${formatDayMonthYear(overview.enrollment.joiningDate)} · ${formatFee(overview.enrollment.effectiveFee(overview.batch.monthlyFeeDefault))}',
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.all(12),
            child: calendar.when(
              loading: () => const SizedBox(
                height: 360,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(context.l10n.t('errorGeneric')),
              ),
              data: (_) => TableCalendar<AttendanceEntity>(
                firstDay: DateTime(2022),
                lastDay: DateTime(2035),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: (day) => recordsByDay[dateKey(day)] ?? const [],
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = normalizeDate(selectedDay);
                    _focusedDay = normalizeDate(focusedDay);
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = normalizeDate(focusedDay));
                },
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const AttendanceCalendarLegend(),
          const SizedBox(height: 18),
          Text(
            formatDayMonthYear(_selectedDay ?? _focusedDay),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (selectedRecords.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Text(context.l10n.t('noAttendanceForDate')),
            )
          else
            for (final record in selectedRecords)
              _AttendanceRecordTile(record: record),
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

class _AttendanceRecordTile extends StatelessWidget {
  const _AttendanceRecordTile({required this.record});

  final AttendanceEntity record;

  @override
  Widget build(BuildContext context) {
    final status = record.attendanceStatus;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(status.icon, color: status.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.localizedLabel(context),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (record.note.trim().isNotEmpty)
                  Text(
                    record.note,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Text(
            formatDayMonthYear(record.date),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
