import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppSnackbar {
  const AppSnackbar._();

  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message,
      Icons.check_circle_outline_rounded,
      AppColors.success,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      message,
      Icons.error_outline_rounded,
      AppColors.danger,
      duration: const Duration(seconds: 5),
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, Icons.info_outline_rounded, AppColors.primary);
  }

  static void showWarning(BuildContext context, String message) {
    _show(
      context,
      message,
      Icons.warning_amber_rounded,
      AppColors.warning,
      foregroundColor: Colors.black87,
      duration: const Duration(seconds: 5),
    );
  }

  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color background, {
    Color foregroundColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: foregroundColor),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: background,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: foregroundColor,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }
}

class AppDatePicker {
  const AppDatePicker._();

  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
  }) async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate ?? today,
      firstDate: firstDate ?? DateTime(today.year - 5),
      lastDate: lastDate ?? DateTime(today.year + 5),
      helpText: helpText,
    );
    if (selected == null) return null;
    return DateTime(selected.year, selected.month, selected.day);
  }

  static Future<DateTimeRange?> pickDateRange(
    BuildContext context, {
    DateTimeRange? initialRange,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final today = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: firstDate ?? DateTime(today.year - 5),
      lastDate: lastDate ?? DateTime(today.year + 5),
      initialDateRange: initialRange,
    );
    if (range == null) return null;
    return DateTimeRange(
      start: DateTime(range.start.year, range.start.month, range.start.day),
      end: DateTime(range.end.year, range.end.month, range.end.day),
    );
  }
}
