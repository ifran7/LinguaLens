import 'package:flutter/material.dart';

import '../../domain/entities/attendance_status.dart';

class AttendanceSummaryChips extends StatelessWidget {
  const AttendanceSummaryChips({
    super.key,
    required this.present,
    required this.absent,
    required this.late,
    required this.leave,
    required this.unmarked,
  });

  final int present;
  final int absent;
  final int late;
  final int leave;
  final int unmarked;

  @override
  Widget build(BuildContext context) {
    final items = [
      (AttendanceStatus.present, present),
      (AttendanceStatus.absent, absent),
      (AttendanceStatus.late, late),
      (AttendanceStatus.leave, leave),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items) _SummaryChip(status: item.$1, count: item.$2),
        _SummaryChip(
          label: 'Unmarked',
          icon: Icons.help_outline_rounded,
          color: Colors.deepOrange,
          count: unmarked,
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    this.status,
    this.label,
    this.icon,
    this.color,
    required this.count,
  });

  final AttendanceStatus? status;
  final String? label;
  final IconData? icon;
  final Color? color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? status!.color;
    final resolvedIcon = icon ?? status!.icon;
    final resolvedLabel = label ?? status!.localizedLabel(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(resolvedIcon, size: 15, color: resolvedColor),
          const SizedBox(width: 5),
          Text(
            '$resolvedLabel $count',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: resolvedColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
