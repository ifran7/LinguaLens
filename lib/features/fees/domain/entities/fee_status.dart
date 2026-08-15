import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

enum FeeStatus { unpaid, partial, paid }

extension FeeStatusX on FeeStatus {
  String get value => name;

  static FeeStatus fromValue(String value) => switch (value) {
    'partial' => FeeStatus.partial,
    'paid' => FeeStatus.paid,
    _ => FeeStatus.unpaid,
  };

  Color get color => switch (this) {
    FeeStatus.unpaid => AppColors.danger,
    FeeStatus.partial => Colors.orange,
    FeeStatus.paid => AppColors.success,
  };

  IconData get icon => switch (this) {
    FeeStatus.unpaid => Icons.error_outline_rounded,
    FeeStatus.partial => Icons.timelapse_rounded,
    FeeStatus.paid => Icons.check_circle_rounded,
  };

  String localizedLabel(BuildContext context) => switch (this) {
    FeeStatus.unpaid => context.l10n.t('unpaid'),
    FeeStatus.partial => context.l10n.t('partial'),
    FeeStatus.paid => context.l10n.t('paid'),
  };
}
