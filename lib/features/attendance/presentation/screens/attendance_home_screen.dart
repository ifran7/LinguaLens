import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../providers/attendance_provider.dart';
import '../widgets/attendance_batch_card.dart';

class AttendanceHomeScreen extends ConsumerStatefulWidget {
  const AttendanceHomeScreen({super.key});

  @override
  ConsumerState<AttendanceHomeScreen> createState() =>
      _AttendanceHomeScreenState();
}

class _AttendanceHomeScreenState extends ConsumerState<AttendanceHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(attendanceHomeProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceHomeProvider);
    final notifier = ref.read(attendanceHomeProvider.notifier);
    final today = normalizeDate(DateTime.now());
    return AppPage(
      title: context.l10n.t('attendance'),
      action: IconButton(
        tooltip: context.l10n.t('attendanceCalendar'),
        onPressed: () => context.push('/attendance/calendar'),
        icon: const Icon(Icons.calendar_month_rounded),
      ),
      child: RefreshIndicator(
        onRefresh: () => notifier.load(state.selectedDate),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _DateNavigator(
              date: state.selectedDate,
              isToday: isSameNormalizedDate(state.selectedDate, today),
              onDateChanged: notifier.changeDate,
            ),
            const SizedBox(height: 18),
            if (state.isLoading && state.activeBatches.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 56),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.errorMessage != null && state.activeBatches.isEmpty)
              _ErrorBlock(
                message: state.errorMessage!,
                onRetry: () => notifier.load(state.selectedDate),
              )
            else if (state.activeBatches.isEmpty)
              EmptyState(
                icon: Icons.fact_check_outlined,
                title: context.l10n.t('noActiveBatches'),
                body: context.l10n.t('createBatchToMarkAttendance'),
                cta: context.l10n.t('createBatch'),
                onPressed: () => context.push('/batches/add'),
              )
            else ...[
              Text(
                context.l10n.t('activeBatches'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              for (final batch in state.activeBatches) ...[
                AttendanceBatchCard(
                  batch: batch,
                  date: state.selectedDate,
                  onMark: () => context.push(
                    '/attendance/batch/${batch.id}',
                    extra: state.selectedDate,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.date,
    required this.isToday,
    required this.onDateChanged,
  });

  final DateTime date;
  final bool isToday;
  final ValueChanged<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            tooltip: context.l10n.t('previousDay'),
            onPressed: () =>
                onDateChanged(date.subtract(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2022),
                  lastDate: DateTime(2035),
                  initialDate: date,
                );
                if (picked != null) onDateChanged(picked);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      isToday
                          ? context.l10n.t('today')
                          : formatShortWeekdayDate(date),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (isToday)
                      Text(
                        formatShortWeekdayDate(date),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.t('nextDay'),
            onPressed: () => onDateChanged(date.add(const Duration(days: 1))),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onRetry,
            child: Text(context.l10n.t('retry')),
          ),
        ],
      ),
    ),
  );
}
