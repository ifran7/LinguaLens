import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

enum PaymentMethod { cash, bankTransfer, mobileBanking, other }

extension PaymentMethodX on PaymentMethod {
  String get value => switch (this) {
    PaymentMethod.cash => 'cash',
    PaymentMethod.bankTransfer => 'bank_transfer',
    PaymentMethod.mobileBanking => 'mobile_banking',
    PaymentMethod.other => 'other',
  };

  static PaymentMethod fromValue(String value) => switch (value) {
    'bank_transfer' => PaymentMethod.bankTransfer,
    'mobile_banking' => PaymentMethod.mobileBanking,
    'other' => PaymentMethod.other,
    _ => PaymentMethod.cash,
  };

  IconData get icon => switch (this) {
    PaymentMethod.cash => Icons.payments_rounded,
    PaymentMethod.bankTransfer => Icons.account_balance_rounded,
    PaymentMethod.mobileBanking => Icons.phone_android_rounded,
    PaymentMethod.other => Icons.more_horiz_rounded,
  };

  String localizedLabel(BuildContext context) => switch (this) {
    PaymentMethod.cash => context.l10n.t('cash'),
    PaymentMethod.bankTransfer => context.l10n.t('bankTransfer'),
    PaymentMethod.mobileBanking => context.l10n.t('mobileBanking'),
    PaymentMethod.other => context.l10n.t('other'),
  };
}
