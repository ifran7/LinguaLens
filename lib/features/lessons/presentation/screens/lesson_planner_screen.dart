import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../batches/providers/batch_provider.dart';
import '../../domain/entities/lesson_status.dart';
import '../../providers/lesson_provider.dart';
import '../widgets/lesson_card.dart';

class LessonPlannerScreen extends ConsumerStatefulWidget {
  const LessonPlannerScreen({super.key});

  @override
  ConsumerState<LessonPlannerScreen> createState() =>
      _LessonPlannerScreenState();
}

class _LessonPlannerScreenState extends ConsumerState<LessonPlannerScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(batchesListProvider.notifier).loadBatches();
      ref.read(lessonPlannerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonPlannerProvider);
    final batches = ref.watch(batchesListProvider).allBatches;
    final l10n = context.l10n;
    return AppPage(
      title: l10n.t('lessons'),
      action: FilledButton.icon(
        onPressed: () => context.push('/lessons/new'),
        icon: const Icon(Icons.add, size: 18),
        label: Text(l10n.t('addLesson')),
      ),
      child: RefreshIndicator(
        onRefresh: () => ref.read(lessonPlannerProvider.notifier).load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _PlannerHeader(state: state),
            const SizedBox(height: 16),
            _ModeTabs(state: state),
            const SizedBox(height: 12),
            _Filters(
              state: state,
              batches: batches,
              onSearch: ref.read(lessonPlannerProvider.notifier).setSearch,
              onBatch: ref.read(lessonPlannerProvider.notifier).setBatch,
              onStatus: ref.read(lessonPlannerProvider.notifier).setStatus,
            ),
            const SizedBox(height: 20),
            if (state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.errorMessage != null)
              EmptyState(
                icon: Icons.error_outline,
                title: l10n.t('errorMessage'),
                body: state.errorMessage!,
                cta: l10n.t('retry'),
                onPressed: () =>
                    ref.read(lessonPlannerProvider.notifier).load(),
              )
            else if (state.lessons.isEmpty)
              EmptyState(
                icon: Icons.event_note_outlined,
                title: l10n.t('noLessonsOnThisDate'),
                body: l10n.t('createFirstLesson'),
                cta: l10n.t('addLesson'),
                onPressed: () => context.push('/lessons/new'),
              )
            else
              ...state.lessons.map(
                (item) => LessonCard(
                  item: item,
                  onTap: () => context.push('/lessons/${item.lesson.id}'),
                  onMarkComplete: () async {
                    await ref
                        .read(lessonRepositoryProvider)
                        .updateLessonStatus(
                          item.lesson.id,
                          LessonStatus.completed,
                        );
                    invalidateAllLessonProviders(
                      ref,
                      batchId: item.lesson.batchId,
                      lessonId: item.lesson.id,
                    );
                    ref.read(lessonPlannerProvider.notifier).load();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlannerHeader extends ConsumerWidget {
  const _PlannerHeader({required this.state});

  final LessonPlannerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final label = switch (state.viewMode) {
      LessonViewMode.daily => DateFormat(
        'EEE, d MMM yyyy',
      ).format(state.selectedDate),
      LessonViewMode.weekly =>
        '${l10n.t('weekOf')} ${DateFormat('d MMM').format(startOfWeek(state.selectedDate))}',
      LessonViewMode.monthly => DateFormat(
        'MMMM yyyy',
      ).format(state.selectedDate),
    };
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l10n.t('previousDay'),
                onPressed: () =>
                    ref.read(lessonPlannerProvider.notifier).shiftDate(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${state.lessons.length} ${l10n.t('lessons')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.t('nextDay'),
                onPressed: () =>
                    ref.read(lessonPlannerProvider.notifier).shiftDate(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDate: state.selectedDate,
              );
              if (picked != null && context.mounted) {
                await ref
                    .read(lessonPlannerProvider.notifier)
                    .setSelectedDate(picked);
              }
            },
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(l10n.t('selectDate')),
          ),
        ],
      ),
    );
  }
}

class _ModeTabs extends ConsumerWidget {
  const _ModeTabs({required this.state});

  final LessonPlannerState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<LessonViewMode>(
      segments: [
        ButtonSegment(
          value: LessonViewMode.daily,
          label: Text(context.l10n.t('daily')),
          icon: const Icon(Icons.today_outlined),
        ),
        ButtonSegment(
          value: LessonViewMode.weekly,
          label: Text(context.l10n.t('weekly')),
          icon: const Icon(Icons.view_week_outlined),
        ),
        ButtonSegment(
          value: LessonViewMode.monthly,
          label: Text(context.l10n.t('monthly')),
          icon: const Icon(Icons.calendar_view_month_outlined),
        ),
      ],
      selected: {state.viewMode},
      onSelectionChanged: (value) =>
          ref.read(lessonPlannerProvider.notifier).setViewMode(value.first),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.state,
    required this.batches,
    required this.onSearch,
    required this.onBatch,
    required this.onStatus,
  });

  final LessonPlannerState state;
  final List<dynamic> batches;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onBatch;
  final ValueChanged<LessonStatus?> onStatus;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: context.l10n.t('searchLessons'),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: state.searchQuery.isEmpty
              ? null
              : const Icon(Icons.clear),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String?>(
              initialValue: state.selectedBatchId,
              decoration: InputDecoration(
                labelText: context.l10n.t('selectBatch'),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(context.l10n.t('allBatches')),
                ),
                ...batches.map(
                  (batch) => DropdownMenuItem<String?>(
                    value: batch.id,
                    child: Text(batch.name),
                  ),
                ),
              ],
              onChanged: onBatch,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<LessonStatus?>(
              initialValue: state.statusFilter,
              decoration: InputDecoration(
                labelText: context.l10n.t('lessonStatus'),
              ),
              items: [
                DropdownMenuItem<LessonStatus?>(
                  value: null,
                  child: Text(context.l10n.t('allStatuses')),
                ),
                ...LessonStatus.values.map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.localizedLabel(context)),
                  ),
                ),
              ],
              onChanged: onStatus,
            ),
          ),
        ],
      ),
    ],
  );
}
