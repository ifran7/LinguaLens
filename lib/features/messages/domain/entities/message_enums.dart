import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

enum MessageCategory {
  feeReminder,
  attendanceAlert,
  progressUpdate,
  paymentConfirmation,
  custom,
}

extension MessageCategoryX on MessageCategory {
  String get value => switch (this) {
    MessageCategory.feeReminder => 'fee_reminder',
    MessageCategory.attendanceAlert => 'attendance_alert',
    MessageCategory.progressUpdate => 'progress_update',
    MessageCategory.paymentConfirmation => 'payment_confirmation',
    MessageCategory.custom => 'custom',
  };

  static MessageCategory fromValue(String value) =>
      MessageCategory.values.firstWhere(
        (item) => item.value == value,
        orElse: () => MessageCategory.custom,
      );

  String label(AppLocalizations l10n) => switch (this) {
    MessageCategory.feeReminder => l10n.t('feeReminder'),
    MessageCategory.attendanceAlert => l10n.t('attendanceAlert'),
    MessageCategory.progressUpdate => l10n.t('progressUpdate'),
    MessageCategory.paymentConfirmation => l10n.t('paymentConfirmation'),
    MessageCategory.custom => l10n.t('custom'),
  };

  IconData get icon => switch (this) {
    MessageCategory.feeReminder => Icons.receipt_long_rounded,
    MessageCategory.attendanceAlert => Icons.fact_check_rounded,
    MessageCategory.progressUpdate => Icons.trending_up_rounded,
    MessageCategory.paymentConfirmation => Icons.payments_rounded,
    MessageCategory.custom => Icons.edit_note_rounded,
  };

  Color get color => switch (this) {
    MessageCategory.feeReminder => const Color(0xFFF59E0B),
    MessageCategory.attendanceAlert => const Color(0xFFEF4444),
    MessageCategory.progressUpdate => const Color(0xFF8B5CF6),
    MessageCategory.paymentConfirmation => const Color(0xFF10B981),
    MessageCategory.custom => const Color(0xFF3B82F6),
  };
}

enum MessageChannel { whatsapp, sms }

extension MessageChannelX on MessageChannel {
  String get value => this == MessageChannel.whatsapp ? 'whatsapp' : 'sms';

  static MessageChannel fromValue(String value) =>
      value == 'sms' ? MessageChannel.sms : MessageChannel.whatsapp;

  String label(AppLocalizations l10n) =>
      this == MessageChannel.whatsapp ? l10n.t('whatsapp') : l10n.t('sms');

  IconData get icon =>
      this == MessageChannel.whatsapp ? Icons.chat_rounded : Icons.sms_rounded;

  Color get color => this == MessageChannel.whatsapp
      ? const Color(0xFF25D366)
      : const Color(0xFF64748B);
}

enum MessagingResult { success, invalidPhone, appNotFound, error }
