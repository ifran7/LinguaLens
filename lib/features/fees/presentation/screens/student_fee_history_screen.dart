import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../students/providers/student_provider.dart';
import '../../../students/presentation/widgets/student_ui_utils.dart';
import '../../domain/entities/fee_status.dart';
import '../../domain/entities/payment_entity.dart';
import '../../providers/fee_provider.dart';
import '../widgets/fee_status_badge.dart';
import '../widgets/payment_entry_tile.dart';

class StudentFeeHistoryScreen extends ConsumerWidget {
  const StudentFeeHistoryScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(studentFeeHistoryProvider(studentId));
    final summary = ref.watch(studentFeeSummaryProvider(studentId));
    final student = ref.watch(studentDetailProvider(studentId));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('paymentHistory'))),
      body: student.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: context.l10n.t('studentNotFound'),
          body: error.toString(),
          cta: context.l10n.t('retry'),
          onPressed: () => ref.invalidate(studentDetailProvider(studentId)),
        ),
        data: (studentEntity) {
          if (studentEntity == null) {
            return EmptyState(
              icon: Icons.person_off_outlined,
              title: context.l10n.t('studentNotFound'),
              body: context.l10n.t('errorMessage'),
              cta: context.l10n.t('retry'),
            );
          }
          return history.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => EmptyState(
              icon: Icons.error_outline_rounded,
              title: context.l10n.t('errorMessage'),
              body: error.toString(),
              cta: context.l10n.t('retry'),
              onPressed: () =>
                  ref.invalidate(studentFeeHistoryProvider(studentId)),
            ),
            data: (views) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context).colorScheme.primary
                              .withValues(alpha: 0.12),
                          child: Text(studentInitials(studentEntity.fullName)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentEntity.fullName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                studentEntity.studentCode,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  summary.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => const SizedBox.shrink(),
                    data: (aggregate) => Row(
                      children: [
                        Expanded(
                          child: _HistoryMetric(
                            label: context.l10n.t('totalCollected'),
                            value: formatFee(aggregate.totalCollected),
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HistoryMetric(
                            label: context.l10n.t('totalDue'),
                            value: formatFee(aggregate.totalDue),
                            color: aggregate.totalDue > 0
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (views.isEmpty)
                    EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: context.l10n.t('noFeeHistory'),
                      body: context.l10n.t('generateFeesToCreate'),
                      cta: context.l10n.t('generateFees'),
                      onPressed: () => context.push('/fees/generate'),
                    )
                  else
                    for (final view in views)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HistoryRecord(
                          view: view,
                          onCollect: view.feeRecord.status == FeeStatus.paid
                              ? null
                              : () => context.push(
                                  '/fees/collect?studentId=$studentId&batchId=${view.batch.id}&monthKey=${view.feeRecord.monthKey}&feeRecordId=${view.feeRecord.id}',
                                ),
                          onDeletePayment: (payment) =>
                              _deletePayment(context, ref, payment),
                        ),
                      ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deletePayment(
    BuildContext context,
    WidgetRef ref,
    PaymentEntity payment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.t('deletePayment')),
        content: Text(context.l10n.t('deletePaymentConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.t('deletePayment')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(paymentRepositoryProvider).deletePayment(payment.id);
    ref.invalidate(paymentsForFeeRecordProvider(payment.feeRecordId));
    ref.invalidate(studentFeeHistoryProvider(payment.studentId));
    ref.invalidate(studentFeeSummaryProvider(payment.studentId));
    ref.invalidate(batchFeeSummaryProvider(payment.batchId));
    ref.invalidate(feeOverviewProvider(payment.monthKey));
    ref.invalidate(feeDashboardProvider);
    ref.invalidate(totalDueProvider);
    ref.invalidate(collectedThisMonthProvider);
    ref.invalidate(recentPaymentsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.t('paymentDeleted'))));
    }
  }
}

class _HistoryMetric extends StatelessWidget {
  const _HistoryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _HistoryRecord extends StatelessWidget {
  const _HistoryRecord({
    required this.view,
    required this.onCollect,
    required this.onDeletePayment,
  });

  final dynamic view;
  final VoidCallback? onCollect;
  final ValueChanged<PaymentEntity> onDeletePayment;

  @override
  Widget build(BuildContext context) {
    final record = view.feeRecord;
    return Card(
      child: ExpansionTile(
        initiallyExpanded: false,
        title: Row(
          children: [
            Expanded(
              child: Text(
                formatMonthKeyDisplay(record.monthKey),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            FeeStatusBadge(status: record.status),
          ],
        ),
        subtitle: Text(
          '${view.batch.name} • ${formatFee(record.dueAmount)} ${context.l10n.t('dueAmount').toLowerCase()}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _Line(
                label: context.l10n.t('assigned'),
                value: formatFee(record.assignedFee),
              ),
              _Line(
                label: context.l10n.t('discount'),
                value: formatFee(record.discountAmount),
              ),
              _Line(
                label: context.l10n.t('finalFee'),
                value: formatFee(record.finalFee),
              ),
              _Line(
                label: context.l10n.t('totalPaid'),
                value: formatFee(record.totalPaid),
              ),
              _Line(
                label: context.l10n.t('dueAmount'),
                value: formatFee(record.dueAmount),
              ),
            ],
          ),
          if (onCollect != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onCollect,
                icon: const Icon(Icons.add_card_rounded),
                label: Text(context.l10n.t('collectPayment')),
              ),
            ),
          ],
          if (view.payments.isNotEmpty) ...[
            const Divider(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.t('paymentHistory'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (final payment in view.payments)
              PaymentEntryTile(
                payment: payment,
                onDelete: () => onDeletePayment(payment),
              ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppColors.muted),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
