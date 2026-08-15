import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/spacing_tokens.dart';
import '../theme/text_tokens.dart';
import '../utils/currency_utils.dart';

enum CurrencyAmountSize { sm, md, lg, xl }

enum CurrencyAmountTone { normal, success, danger, muted }

class CurrencyAmountText extends StatelessWidget {
  const CurrencyAmountText({
    super.key,
    required this.amount,
    this.size = CurrencyAmountSize.md,
    this.tone = CurrencyAmountTone.normal,
    this.showPlusSign = false,
    this.compact = false,
    this.textAlign = TextAlign.start,
    this.color,
  });

  final double amount;
  final CurrencyAmountSize size;
  final CurrencyAmountTone tone;
  final bool showPlusSign;
  final bool compact;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueColor =
        color ??
        switch (tone) {
          CurrencyAmountTone.normal => theme.colorScheme.onSurface,
          CurrencyAmountTone.success => AppColors.success,
          CurrencyAmountTone.danger => AppColors.danger,
          CurrencyAmountTone.muted => theme.colorScheme.onSurfaceVariant,
        };
    final valueStyle = switch (size) {
      CurrencyAmountSize.sm => AppTextTokens.metadata.copyWith(
        color: valueColor,
        fontWeight: FontWeight.w600,
      ),
      CurrencyAmountSize.md => AppTextTokens.bodyMedium.copyWith(
        color: valueColor,
        fontWeight: FontWeight.w700,
      ),
      CurrencyAmountSize.lg => AppTextTokens.stat.copyWith(color: valueColor),
      CurrencyAmountSize.xl => AppTextTokens.screenTitle.copyWith(
        color: valueColor,
        fontSize: 28,
      ),
    };
    final symbolStyle = valueStyle.copyWith(
      fontSize: (valueStyle.fontSize ?? 14) * 0.72,
      fontWeight: FontWeight.w500,
      color: valueColor.withValues(alpha: 0.72),
    );
    final prefix = showPlusSign && amount > 0 ? '+' : '';

    return Semantics(
      label: '$prefix${formatFee(amount)}',
      child: RichText(
        textAlign: textAlign,
        text: TextSpan(
          children: [
            TextSpan(text: '$prefix৳', style: symbolStyle),
            TextSpan(
              text: compact
                  ? formatFeeNumber(amount).replaceAll(',', '')
                  : ' ${formatFeeNumber(amount)}',
              style: valueStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class MoneyPill extends StatelessWidget {
  const MoneyPill({
    super.key,
    required this.amount,
    required this.label,
    this.tone = CurrencyAmountTone.normal,
  });

  final double amount;
  final String label;
  final CurrencyAmountTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (tone) {
      CurrencyAmountTone.success => AppColors.success,
      CurrencyAmountTone.danger => AppColors.danger,
      CurrencyAmountTone.muted => theme.colorScheme.onSurfaceVariant,
      CurrencyAmountTone.normal => theme.colorScheme.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurrencyAmountText(
            amount: amount,
            size: CurrencyAmountSize.sm,
            tone: tone,
            compact: true,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextTokens.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}
