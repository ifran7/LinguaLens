import 'package:flutter/material.dart';

import '../../domain/entities/lesson_status.dart';

class LessonStatusBadge extends StatelessWidget {
  const LessonStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final LessonStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: compact ? 13 : 15, color: color),
          const SizedBox(width: 5),
          Text(
            status.localizedLabel(context),
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
