import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../providers/attendance_provider.dart';
import '../widgets/attendance_student_tile.dart';
import '../widgets/attendance_summary_chips.dart';

class AttendanceSessionScreen extends ConsumerStatefulWidget {
  const AttendanceSessionScreen({
    super.key,
    required this.batchId,
    this.initialDate,
  });

  final String batchId;
  final DateTime? initialDate;

  @override
  ConsumerState<AttendanceSessionScreen> createState() =>
      _AttendanceSessionScreenState();
}

class _AttendanceSessionScreenState
    extends ConsumerState<AttendanceSessionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(attendanceSessionProvider(widget.batchId).notifier)
          .loadSession(widget.initialDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = attendanceSessionProvider(widget.batchId);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(state.batch?.name ?? context.l10n.t('markAttendance')),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'all') notifier.markAllPresent();
              if (value == 'clear') notifier.clearAllStatuses();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Text(context.l10n.t('markAllPresent')),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text(context.l10n.t('clearAll')),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading && state.students.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null && state.students.isEmpty
            ? Center(child: Text(state.errorMessage!))
            : Column(
                children: [
                  _SessionHeader(
                    date: state.selectedDate,
                    isSaving: state.isSaving,
                    onDateChanged: notifier.changeDate,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: notifier.searchStudents,
                          decoration: InputDecoration(
                            hintText: context.l10n.t('searchStudents'),
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AttendanceSummaryChips(
                            present: state.presentCount,
                            absent: state.absentCount,
                            late: state.lateCount,
                            leave: state.leaveCount,
                            unmarked: state.unmarkedCount,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: state.students.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Text(
                                context.l10n.t('noEligibleStudents'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                            itemCount: state.visibleStudents.length,
                            itemBuilder: (context, index) {
                              final item = state.visibleStudents[index];
                              return AttendanceStudentTile(
                                item: item,
                                onStatusChanged: (status) => notifier
                                    .setStudentStatus(item.student.id, status),
                                onClearStatus: () => notifier
                                    .clearStudentStatus(item.student.id),
                                onNoteChanged: (note) => notifier
                                    .setStudentNote(item.student.id, note),
                                enabled: !state.isSaving,
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: FilledButton.icon(
          onPressed: state.isSaving || state.students.isEmpty
              ? null
              : () async {
                  await notifier.saveSession();
                  if (!context.mounted) return;
                  final updated = ref.read(provider);
                  if (updated.errorMessage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.t('attendanceSaved')),
                      ),
                    );
                    context.pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(updated.errorMessage!)),
                    );
                  }
                },
          icon: state.isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_rounded),
          label: Text(context.l10n.t('saveAttendance')),
        ),
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.date,
    required this.isSaving,
    required this.onDateChanged,
  });

  final DateTime date;
  final bool isSaving;
  final ValueChanged<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            IconButton(
              onPressed: isSaving
                  ? null
                  : () => onDateChanged(date.subtract(const Duration(days: 1))),
              tooltip: context.l10n.t('previousDay'),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    formatShortWeekdayDate(date),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    context.l10n.t('attendanceDetails'),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: isSaving
                  ? null
                  : () => onDateChanged(date.add(const Duration(days: 1))),
              tooltip: context.l10n.t('nextDay'),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
