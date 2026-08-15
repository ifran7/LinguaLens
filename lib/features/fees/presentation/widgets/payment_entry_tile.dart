import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/currency_amount_text.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_method.dart';

class PaymentEntryTile extends StatelessWidget {
  const PaymentEntryTile({
    super.key,
    required this.payment,
    this.studentLabel,
    this.batchLabel,
    this.onDelete,
  });

  final PaymentEntity payment;
  final String? studentLabel;
  final String? batchLabel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final method = payment.method;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.success.withValues(alpha: 0.12),
        child: Icon(method.icon, color: AppColors.success, size: 20),
      ),
      title: Row(
        children: [
          Expanded(
            child: CurrencyAmountText(
              amount: payment.amount,
              size: CurrencyAmountSize.md,
              tone: CurrencyAmountTone.success,
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: context.l10n.t('deletePayment'),
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.muted,
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatDayMonthYear(payment.paymentDate)} • ${method.localizedLabel(context)}',
          ),
          if (studentLabel != null || batchLabel != null)
            Text(
              [studentLabel, batchLabel]
                  .whereType<String>()
                  .where((value) => value.isNotEmpty)
                  .join(' • '),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.muted),
            ),
          if (payment.note.trim().isNotEmpty)
            Text(
              payment.note,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.muted),
            ),
        ],
      ),
    );
  }
}
