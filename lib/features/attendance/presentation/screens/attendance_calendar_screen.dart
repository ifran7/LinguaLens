import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' hide normalizeDate;

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/premium_widgets.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/attendance_status.dart';
import '../../providers/attendance_provider.dart';

class AttendanceCalendarScreen extends ConsumerStatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  ConsumerState<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState
    extends ConsumerState<AttendanceCalendarScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final today = normalizeDate(DateTime.now());
    _focusedDay = today;
    _selectedDay = today;
  }

  AttendanceCalendarMonthArgs get _args =>
      AttendanceCalendarMonthArgs(month: _focusedDay);

  void _moveMonth(int offset) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + offset, 1);
      _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = ref.watch(attendanceCalendarMonthProvider(_args));
    return AppPage(
      title: l.t('attendanceOverview'),
      showBack: true,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(attendanceCalendarMonthProvider(_args));
          await ref.read(attendanceCalendarMonthProvider(_args).future);
        },
        child: state.when(
          loading: () => const AppLoading(),
          error: (error, _) => AppErrorState(
            message: error.toString(),
            onRetry: () =>
                ref.invalidate(attendanceCalendarMonthProvider(_args)),
          ),
          data: (data) => _CalendarContent(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            data: data,
            onPreviousMonth: () => _moveMonth(-1),
            onNextMonth: () => _moveMonth(1),
            onDaySelected: (selected, focused) => setState(() {
              _selectedDay = normalizeDate(selected);
              _focusedDay = normalizeDate(focused);
            }),
          ),
        ),
      ),
    );
  }
}

class _CalendarContent extends StatelessWidget {
  const _CalendarContent({
    required this.focusedDay,
    required this.selectedDay,
    required this.data,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDaySelected,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final AttendanceCalendarMonthData data;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final void Function(DateTime, DateTime) onDaySelected;

  @override
  Widget build(BuildContext context) {
    final selected = selectedDay ?? focusedDay;
    final selectedRecords = data.recordsByDay[dateKey(selected)] ?? const [];
    final present = data.records
        .where((record) => record.attendanceStatus == AttendanceStatus.present)
        .length;
    final absent = data.records
        .where((record) => record.attendanceStatus == AttendanceStatus.absent)
        .length;
    final late = data.records
        .where((record) => record.attendanceStatus == AttendanceStatus.late)
        .length;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.hero,
      ),
      children: [
        PremiumCard(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? 0.34 : 0.6,
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              IconBadge(
                icon: Icons.calendar_month_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.t('attendanceAnalytics'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.t('attendanceOverview'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${data.records.length}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                icon: Icons.check_circle_rounded,
                value: '$present',
                label: context.l10n.t('present'),
                color: AttendanceStatus.present.color,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SummaryTile(
                icon: Icons.cancel_rounded,
                value: '$absent',
                label: context.l10n.t('absent'),
                color: AttendanceStatus.absent.color,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SummaryTile(
                icon: Icons.schedule_rounded,
                value: '$late',
                label: context.l10n.t('late'),
                color: AttendanceStatus.late.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _MonthCalendar(
          focusedDay: focusedDay,
          selectedDay: selectedDay,
          recordsByDay: data.recordsByDay,
          onPreviousMonth: onPreviousMonth,
          onNextMonth: onNextMonth,
          onDaySelected: onDaySelected,
        ),
        const SizedBox(height: AppSpacing.md),
        const _CalendarLegend(),
        const SizedBox(height: AppSpacing.lg),
        PremiumSection(
          title: context.l10n.t('selectedDateDetails'),
          subtitle: formatFullDate(selected),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            child: selectedRecords.isEmpty
                ? PremiumCard(
                    key: ValueKey('empty-${dateKey(selected)}'),
                    compact: true,
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(context.l10n.t('noAttendanceForDate')),
                        ),
                      ],
                    ),
                  )
                : Column(
                    key: ValueKey('records-${dateKey(selected)}'),
                    children: [
                      for (final record in selectedRecords)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _AttendanceListTile(
                            record: record,
                            studentName:
                                data.studentsById[record.studentId]?.fullName ??
                                record.studentId,
                            batchName:
                                data.batchesById[record.batchId]?.name ??
                                record.batchId,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({
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
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MonthButton(
                icon: Icons.chevron_left_rounded,
                tooltip: l.t('previousMonth'),
                onPressed: onPreviousMonth,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      formatMonthYear(focusedDay),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.t('attendanceOverview'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _MonthButton(
                icon: Icons.chevron_right_rounded,
                tooltip: l.t('nextMonth'),
                onPressed: onNextMonth,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TableCalendar<AttendanceEntity>(
            firstDay: DateTime(2022),
            lastDay: DateTime(2035),
            focusedDay: focusedDay,
            headerVisible: false,
            daysOfWeekHeight: 34,
            rowHeight: 62,
            sixWeekMonthsEnforced: false,
            calendarFormat: CalendarFormat.month,
            availableGestures: AvailableGestures.horizontalSwipe,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            eventLoader: (day) => recordsByDay[dateKey(day)] ?? const [],
            onDaySelected: onDaySelected,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: const EdgeInsets.all(3),
              cellPadding: EdgeInsets.zero,
              defaultTextStyle: Theme.of(context).textTheme.bodyMedium!,
              weekendTextStyle: Theme.of(context).textTheme.bodyMedium!
                  .copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              todayTextStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
              selectedTextStyle: Theme.of(context).textTheme.bodyMedium!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            calendarBuilders: CalendarBuilders<AttendanceEntity>(
              dowBuilder: (context, day) => Center(
                child: Text(
                  weekdayLabels[day.weekday] ?? '',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              defaultBuilder: (context, day, focused) => _GlobalDayCell(
                day: day,
                records: recordsByDay[dateKey(day)] ?? const [],
              ),
              todayBuilder: (context, day, focused) => _GlobalDayCell(
                day: day,
                records: recordsByDay[dateKey(day)] ?? const [],
                isToday: true,
              ),
              selectedBuilder: (context, day, focused) => _GlobalDayCell(
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

class _GlobalDayCell extends StatelessWidget {
  const _GlobalDayCell({
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
    final statuses = records.map((record) => record.attendanceStatus).toSet();
    final mainColor = statuses.contains(AttendanceStatus.present)
        ? AttendanceStatus.present.color
        : statuses.contains(AttendanceStatus.late)
        ? AttendanceStatus.late.color
        : statuses.contains(AttendanceStatus.absent)
        ? AttendanceStatus.absent.color
        : AttendanceStatus.leave.color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : isToday
            ? Theme.of(context).colorScheme.primaryContainer
                  .withValues(alpha: 0.55)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.field),
        border: isToday && !isSelected
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.2,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: isToday || isSelected
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          if (records.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final status in statuses.take(3))
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : status.color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            )
          else
            const SizedBox(height: 6),
          if (records.isNotEmpty)
            Container(
              width: 22,
              height: 2.5,
              margin: const EdgeInsets.only(top: 3),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : mainColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon),
    constraints: const BoxConstraints.tightFor(width: 44, height: 44),
    padding: EdgeInsets.zero,
  );
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    final items = [
      AttendanceStatus.present,
      AttendanceStatus.absent,
      AttendanceStatus.late,
      AttendanceStatus.leave,
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final status in items)
          DecoratedBox(
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadii.chip),
              border: Border.all(color: status.color.withValues(alpha: 0.28)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(status.icon, size: 15, color: status.color),
                  const SizedBox(width: 6),
                  Text(
                    status.localizedLabel(context),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: status.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => PremiumCard(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    child: Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    ),
  );
}

class _AttendanceListTile extends StatelessWidget {
  const _AttendanceListTile({
    required this.record,
    required this.studentName,
    required this.batchName,
  });

  final AttendanceEntity record;
  final String studentName;
  final String batchName;

  @override
  Widget build(BuildContext context) {
    final status = record.attendanceStatus;
    return PremiumCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: status.color,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(status.icon, color: status.color, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  batchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            status.localizedLabel(context),
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: status.color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
