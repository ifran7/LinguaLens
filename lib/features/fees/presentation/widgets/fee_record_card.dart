import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../batches/domain/entities/batch_entity.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/presentation/widgets/student_ui_utils.dart';
import '../../domain/entities/fee_record_entity.dart';
import 'fee_status_badge.dart';

class FeeRecordCard extends StatelessWidget {
  const FeeRecordCard({
    super.key,
    required this.record,
    required this.student,
    required this.batch,
    this.onTap,
    this.onCollect,
  });

  final FeeRecordEntity record;
  final StudentEntity student;
  final BatchEntity batch;
  final VoidCallback? onTap;
  final VoidCallback? onCollect;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(context).colorScheme.primary
                        .withValues(alpha: 0.12),
                    child: Text(studentInitials(student.fullName)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          student.studentCode,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  FeeStatusBadge(status: record.status),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.groups_rounded, size: 16),
                    label: Text(batch.name),
                    visualDensity: VisualDensity.compact,
                  ),
                  Chip(
                    avatar: const Icon(Icons.calendar_month_rounded, size: 16),
                    label: Text(formatMonthKeyDisplay(record.monthKey)),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const Divider(height: 24),
              Wrap(
                spacing: 20,
                runSpacing: 12,
                children: [
                  _Amount(
                    label: context.l10n.t('assigned'),
                    value: record.assignedFee,
                  ),
                  if (record.discountAmount > 0)
                    _Amount(
                      label: context.l10n.t('discount'),
                      value: record.discountAmount,
                      muted: true,
                    ),
                  _Amount(
                    label: context.l10n.t('finalFee'),
                    value: record.finalFee,
                  ),
                  _Amount(
                    label: context.l10n.t('totalPaid'),
                    value: record.totalPaid,
                  ),
                  _Amount(
                    label: context.l10n.t('dueAmount'),
                    value: record.dueAmount,
                    color: record.dueAmount > 0
                        ? AppColors.danger
                        : AppColors.success,
                  ),
                ],
              ),
              if (onCollect != null && record.status.name != 'paid') ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: onCollect,
                    icon: const Icon(Icons.add_card_rounded),
                    label: Text(context.l10n.t('collectPayment')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({
    required this.label,
    required this.value,
    this.muted = false,
    this.color,
  });

  final String label;
  final double value;
  final bool muted;
  final Color? color;

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
          formatFee(value),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color ?? (muted ? AppColors.muted : null),
            fontWeight: FontWeight.w700,
            decoration: muted ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}
