import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../theme/app_theme.dart';

class AppDialogs {
  const AppDialogs._();

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final l = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: icon == null
            ? null
            : Icon(
                icon,
                color: isDestructive
                    ? AppColors.danger
                    : Theme.of(dialogContext).colorScheme.primary,
              ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel ?? l.t('cancel')),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(backgroundColor: AppColors.danger)
                : null,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(confirmLabel ?? l.t('confirm')),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    required String hint,
    String? initialValue,
    String? confirmLabel,
    String? Function(String)? validator,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: hint),
            validator: (value) => validator?.call(value?.trim() ?? ''),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogContext).pop(controller.text.trim());
              }
            },
            child: Text(confirmLabel ?? context.l10n.t('confirm')),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionLabel,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.info_outline_rounded,
          color: Theme.of(dialogContext).colorScheme.primary,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(actionLabel ?? context.l10n.t('close')),
          ),
        ],
      ),
    );
  }
}
