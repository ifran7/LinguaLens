import 'package:flutter/material.dart';

import '../../domain/entities/attendance_status.dart';

class AttendanceStatusSelector extends StatelessWidget {
  const AttendanceStatusSelector({
    super.key,
    required this.selected,
    required this.onStatusSelected,
    required this.onClear,
    this.enabled = true,
  });

  final AttendanceStatus? selected;
  final ValueChanged<AttendanceStatus> onStatusSelected;
  final VoidCallback onClear;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final status in AttendanceStatus.values)
          _StatusButton(
            status: status,
            selected: selected == status,
            enabled: enabled,
            onTap: () => onStatusSelected(status),
          ),
        if (selected != null)
          IconButton(
            tooltip: 'Clear',
            visualDensity: VisualDensity.compact,
            onPressed: enabled ? onClear : null,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.status,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final AttendanceStatus status;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Semantics(
      button: true,
      selected: selected,
      label: status.localizedLabel(context),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: color.withValues(alpha: enabled ? 0.55 : 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status.icon,
                size: 15,
                color: selected ? Colors.white : color,
              ),
              const SizedBox(width: 5),
              Text(
                status.localizedLabel(context),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? Colors.white : color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
