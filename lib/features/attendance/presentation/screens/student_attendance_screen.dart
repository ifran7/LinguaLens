import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' hide normalizeDate;

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/premium_widgets.dart';
import '../../../batches/providers/batch_provider.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/attendance_summaries.dart';
import '../../domain/entities/attendance_status.dart';
import '../../providers/attendance_provider.dart';

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
    final l = context.l10n;
    final summary = ref.watch(
      studentAttendanceSummaryProvider(widget.studentId),
    );
    final calendar = ref.watch(
      studentAttendanceCalendarProvider(_calendarArgs),
    );
    final batchOverviews = ref.watch(
      studentBatchOverviewsProvider(widget.studentId),
    );
    final groups =
        calendar.asData?.value ?? const <StudentDayAttendanceGroup>[];
    final recordsByDay = <String, List<AttendanceEntity>>{
      for (final group in groups) dateKey(group.date): group.records,
    };
    final selectedDate = _selectedDay ?? _focusedDay;
    final selectedRecords = recordsByDay[dateKey(selectedDate)] ?? const [];
    final overviewList =
        batchOverviews.asData?.value ?? <StudentBatchOverview>[];
    final batchMap = <String, StudentBatchOverview>{
      for (final overview in overviewList) overview.batch.id: overview,
    };
    final markedRecords = groups.expand((group) => group.records).toList();
    final monthPresent = markedRecords
        .where((record) => record.attendanceStatus == AttendanceStatus.present)
        .length;
    final monthAbsent = markedRecords
        .where((record) => record.attendanceStatus == AttendanceStatus.absent)
        .length;
    final monthPercentage = markedRecords.isEmpty
        ? 0
        : (monthPresent / markedRecords.length * 100).round();

    return AppPage(
      title: l.t('attendanceOverview'),
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.hero,
        ),
        children: [
          _ProfileHeader(
            summary: summary,
            studentId: widget.studentId,
            batchId: widget.batchId,
          ),
          const SizedBox(height: AppSpacing.lg),
          PremiumSection(
            title: l.t('attendanceAnalytics'),
            subtitle: formatMonthYear(_focusedDay),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  PremiumStatPill(
                    icon: Icons.percent_rounded,
                    value: '$monthPercentage%',
                    label: l.t('attendancePercentage'),
                    color: AppColors.primary,
                    compact: true,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  PremiumStatPill(
                    icon: Icons.event_available_rounded,
                    value: '${groups.length}',
                    label: l.t('markedDays'),
                    color: AttendanceStatus.present.color,
                    compact: true,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  PremiumStatPill(
                    icon: Icons.event_busy_rounded,
                    value: '$monthAbsent',
                    label: l.t('absentDays'),
                    color: AttendanceStatus.absent.color,
                    compact: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _CalendarCard(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            recordsByDay: recordsByDay,
            onPreviousMonth: () => setState(() {
              _focusedDay = DateTime(
                _focusedDay.year,
                _focusedDay.month - 1,
                1,
              );
            }),
            onNextMonth: () => setState(() {
              _focusedDay = DateTime(
                _focusedDay.year,
                _focusedDay.month + 1,
                1,
              );
            }),
            onDaySelected: (selectedDay, focusedDay) => setState(() {
              _selectedDay = normalizeDate(selectedDay);
              _focusedDay = normalizeDate(focusedDay);
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          _PremiumLegend(),
          const SizedBox(height: AppSpacing.lg),
          PremiumSection(
            title: l.t('selectedDateDetails'),
            subtitle: formatFullDate(selectedDate),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              child: selectedRecords.isEmpty
                  ? PremiumCard(
                      key: ValueKey('empty-${dateKey(selectedDate)}'),
                      compact: true,
                      child: Text(l.t('noAttendanceForDate')),
                    )
                  : Column(
                      key: ValueKey('records-${dateKey(selectedDate)}'),
                      children: [
                        for (final record in selectedRecords)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _AttendanceRecordTile(
                              record: record,
                              batch: batchMap[record.batchId],
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.summary, this.studentId, this.batchId});

  final AsyncValue<StudentAttendanceSummary> summary;
  final String? studentId;
  final String? batchId;

  @override
  Widget build(BuildContext context) => summary.when(
    loading: () => const PremiumCard(
      child: SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
    ),
    error: (error, _) =>
        PremiumCard(child: AppErrorState(message: error.toString())),
    data: (value) => PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.person_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.t('studentAttendance'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.l10n.t('attendanceSummary'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    PremiumStatPill(
                      icon: Icons.check_circle_rounded,
                      value: '${value.presentCount}',
                      label: context.l10n.t('present'),
                      color: AttendanceStatus.present.color,
                      compact: true,
                    ),
                    PremiumStatPill(
                      icon: Icons.cancel_rounded,
                      value: '${value.absentCount}',
                      label: context.l10n.t('absent'),
                      color: AttendanceStatus.absent.color,
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${value.attendancePercentage.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _percentageColor(value.attendancePercentage),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );

  Color _percentageColor(double percentage) {
    if (percentage >= 80) return AttendanceStatus.present.color;
    if (percentage >= 60) return AttendanceStatus.late.color;
    return AttendanceStatus.absent.color;
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedDay,
    required this.selectedDay,
    required this.recordsByDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDaySelected,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Map<String, List<AttendanceEntity>> recordsByDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final void Function(DateTime, DateTime) onDaySelected;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final weekdayLabels = <int, String>{
      DateTime.saturday: l.t('saturdayShort'),
      DateTime.sunday: l.t('sundayShort'),
      DateTime.monday: l.t('mondayShort'),
      DateTime.tuesday: l.t('tuesdayShort'),
      DateTime.wednesday: l.t('wednesdayShort'),
      DateTime.thursday: l.t('thursdayShort'),
      DateTime.friday: l.t('fridayShort'),
    };
    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l.t('previousMonth'),
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      formatMonthYear(focusedDay),
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      l.t('attendanceOverview'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l.t('nextMonth'),
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          TableCalendar<AttendanceEntity>(
            firstDay: DateTime(2022),
            lastDay: DateTime(2035),
            focusedDay: focusedDay,
            headerVisible: false,
            daysOfWeekHeight: 28,
            rowHeight: 54,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            eventLoader: (day) => recordsByDay[dateKey(day)] ?? const [],
            onDaySelected: onDaySelected,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: const EdgeInsets.all(3),
              cellPadding: EdgeInsets.zero,
              defaultTextStyle: Theme.of(context).textTheme.bodySmall!,
              weekendTextStyle: Theme.of(context).textTheme.bodySmall!,
              todayTextStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
              selectedTextStyle: Theme.of(context).textTheme.bodySmall!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            calendarBuilders: CalendarBuilders<AttendanceEntity>(
              dowBuilder: (context, day) => Center(
                child: Text(
                  weekdayLabels[day.weekday] ?? '',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              defaultBuilder: (context, day, focusedDay) => _DayCell(
                day: day,
                records: recordsByDay[dateKey(day)] ?? const [],
              ),
              todayBuilder: (context, day, focusedDay) => _DayCell(
                day: day,
                records: recordsByDay[dateKey(day)] ?? const [],
                isToday: true,
              ),
              selectedBuilder: (context, day, focusedDay) => _DayCell(
                day: day,
                records: recordsByDay[dateKey(day)] ?? const [],
                isSelected: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.records,
    this.isToday = false,
    this.isSelected = false,
  });

  final DateTime day;
  final List<AttendanceEntity> records;
  final bool isToday;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final aggregate = _aggregateStatus(records);
    final markerColor = aggregate?.color ?? Colors.transparent;
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : isToday
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.field),
        border: isToday && !isSelected
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isToday || isSelected
                  ? FontWeight.w800
                  : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 20,
            decoration: BoxDecoration(
              color: markerColor,
              borderRadius: BorderRadius.circular(AppRadii.chip),
            ),
          ),
        ],
      ),
    );
  }

  AttendanceStatus? _aggregateStatus(List<AttendanceEntity> records) {
    if (records.isEmpty) return null;
    if (records.any(
      (record) => record.attendanceStatus == AttendanceStatus.absent,
    )) {
      return AttendanceStatus.absent;
    }
    if (records.any(
      (record) => record.attendanceStatus == AttendanceStatus.late,
    )) {
      return AttendanceStatus.late;
    }
    if (records.any(
      (record) => record.attendanceStatus == AttendanceStatus.leave,
    )) {
      return AttendanceStatus.leave;
    }
    return AttendanceStatus.present;
  }
}

class _PremiumLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.sm,
    children: AttendanceStatus.values
        .map(
          (status) => Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadii.chip),
              border: Border.all(color: status.color.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, size: 14, color: status.color),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  status.localizedLabel(context),
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: status.color),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

class _AttendanceRecordTile extends StatelessWidget {
  const _AttendanceRecordTile({required this.record, this.batch});

  final AttendanceEntity record;
  final StudentBatchOverview? batch;

  @override
  Widget build(BuildContext context) {
    final status = record.attendanceStatus;
    final batchColor =
        batch?.batch.color ?? Theme.of(context).colorScheme.primary;
    return PremiumCard(
      compact: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      accentColor: batchColor,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 38,
            decoration: BoxDecoration(
              color: batchColor,
              borderRadius: BorderRadius.circular(AppRadii.chip),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(status.icon, color: status.color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch?.batch.name ?? context.l10n.t('attendance'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  record.note.trim().isEmpty
                      ? status.localizedLabel(context)
                      : '${status.localizedLabel(context)} · ${record.note}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.chip),
            ),
            child: Text(
              status.localizedLabel(context),
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: status.color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
