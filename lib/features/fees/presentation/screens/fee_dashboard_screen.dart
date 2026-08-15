import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../batches/domain/entities/batch_entity.dart';
import '../../../batches/providers/batch_provider.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/providers/student_provider.dart';
import '../../domain/entities/fee_record_entity.dart';
import '../../providers/fee_provider.dart';
import '../widgets/fee_record_card.dart';
import '../widgets/fee_summary_card.dart';
import '../widgets/month_picker_dialog.dart';
import '../widgets/payment_entry_tile.dart';

class FeeDashboardScreen extends ConsumerStatefulWidget {
  const FeeDashboardScreen({super.key});

  @override
  ConsumerState<FeeDashboardScreen> createState() => _FeeDashboardScreenState();
}

class _FeeDashboardScreenState extends ConsumerState<FeeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(feeDashboardProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feeDashboardProvider);
    final notifier = ref.read(feeDashboardProvider.notifier);
    final aggregate = state.aggregate;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.t('fees')),
        actions: [
          IconButton(
            tooltip: context.l10n.t('selectMonth'),
            onPressed: () async {
              final selected = await showMonthPickerDialog(
                context,
                initialMonthKey: state.selectedMonthKey,
              );
              if (selected != null) notifier.changeMonth(selected);
            },
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.load(),
        child: state.isLoading && aggregate == null
            ? ListView(
                children: [
                  SizedBox(height: 280),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : state.errorMessage != null && aggregate == null
            ? ListView(
                children: [
                  const SizedBox(height: 180),
                  EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: context.l10n.t('errorMessage'),
                    body: state.errorMessage!,
                    cta: context.l10n.t('retry'),
                    onPressed: notifier.load,
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  _MonthHeader(
                    monthKey: state.selectedMonthKey,
                    onPrevious: () => notifier.changeMonth(
                      monthKey(
                        DateTime(
                          monthKeyToDate(state.selectedMonthKey).year,
                          monthKeyToDate(state.selectedMonthKey).month - 1,
                        ),
                      ),
                    ),
                    onNext: () => notifier.changeMonth(
                      monthKey(
                        DateTime(
                          monthKeyToDate(state.selectedMonthKey).year,
                          monthKeyToDate(state.selectedMonthKey).month + 1,
                        ),
                      ),
                    ),
                    onSelect: () async {
                      final selected = await showMonthPickerDialog(
                        context,
                        initialMonthKey: state.selectedMonthKey,
                      );
                      if (selected != null) notifier.changeMonth(selected);
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 164,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FeeSummaryCard(
                          label: context.l10n.t('totalFee'),
                          value: formatFee(aggregate?.totalAssigned ?? 0),
                          color: Theme.of(context).colorScheme.primary,
                          icon: Icons.receipt_long_rounded,
                        ),
                        const SizedBox(width: 12),
                        FeeSummaryCard(
                          label: context.l10n.t('collected'),
                          value: formatFee(aggregate?.totalCollected ?? 0),
                          color: AppColors.success,
                          icon: Icons.check_circle_rounded,
                        ),
                        const SizedBox(width: 12),
                        FeeSummaryCard(
                          label: context.l10n.t('due'),
                          value: formatFee(aggregate?.totalDue ?? 0),
                          color: (aggregate?.totalDue ?? 0) > 0
                              ? AppColors.danger
                              : AppColors.success,
                          icon: Icons.pending_actions_rounded,
                        ),
                        const SizedBox(width: 12),
                        FeeSummaryCard(
                          label: context.l10n.t('today'),
                          value: formatFee(state.collectedToday),
                          color: Colors.teal,
                          icon: Icons.today_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(title: context.l10n.t('quickActions')),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.push(
                          '/fees/generate?monthKey=${state.selectedMonthKey}',
                        ),
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: Text(context.l10n.t('generateFees')),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push(
                          '/fees/overview?monthKey=${state.selectedMonthKey}',
                        ),
                        icon: const Icon(Icons.list_alt_rounded),
                        label: Text(context.l10n.t('viewAll')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SectionHeader(title: context.l10n.t('recentPayments')),
                  if (state.recentPayments.isEmpty)
                    AppCard(
                      child: Text(
                        context.l10n.t('noRecentPayments'),
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                    )
                  else
                    AppCard(
                      child: Column(
                        children: [
                          for (final payment in state.recentPayments)
                            PaymentEntryTile(payment: payment),
                        ],
                      ),
                    ),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: context.l10n.t('overdue'),
                    actionLabel: state.overdueRecords.length > 3
                        ? context.l10n.t('viewAll')
                        : null,
                    onAction: () => context.push(
                      '/fees/overview?overdue=true&monthKey=${state.selectedMonthKey}',
                    ),
                  ),
                  if (state.overdueRecords.isEmpty)
                    AppCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(context.l10n.t('noOverdue'))),
                        ],
                      ),
                    )
                  else
                    for (final record in state.overdueRecords.take(3))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ResolvedRecordCard(record: record),
                      ),
                ],
              ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.monthKey,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
  });

  final String monthKey;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: InkWell(
              onTap: onSelect,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Text(
                      context.l10n.t('monthlyFees'),
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatMonthKeyDisplay(monthKey),
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _ResolvedRecordCard extends ConsumerWidget {
  const _ResolvedRecordCard({required this.record});

  final FeeRecordEntity record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: Future.wait<Object?>([
        ref.read(studentRepositoryProvider).getStudentById(record.studentId),
        ref.read(batchRepositoryProvider).getBatchById(record.batchId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.data![0] == null ||
            snapshot.data![1] == null) {
          return const SizedBox.shrink();
        }
        final student = snapshot.data![0]! as StudentEntity;
        final batch = snapshot.data![1]! as BatchEntity;
        return FeeRecordCard(
          record: record,
          student: student,
          batch: batch,
          onTap: () => context.push('/fees/student/${student.id}'),
          onCollect: record.status.name == 'paid'
              ? null
              : () => context.push(
                  '/fees/collect?studentId=${student.id}&batchId=${batch.id}&monthKey=${record.monthKey}&feeRecordId=${record.id}',
                ),
        );
      },
    );
  }
}
