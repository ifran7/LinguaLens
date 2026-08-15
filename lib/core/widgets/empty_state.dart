import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? Theme.of(context).colorScheme.primary;
    final iconSize = compact ? 48.0 : 64.0;
    final titleStyle = compact
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.titleMedium;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 32,
          vertical: compact ? 20 : 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: color),
            SizedBox(height: compact ? 12 : 20),
            Text(title, style: titleStyle, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: compact ? 12 : 20),
              compact
                  ? TextButton(onPressed: onAction, child: Text(actionLabel!))
                  : FilledButton.icon(
                      onPressed: onAction,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(actionLabel!),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
