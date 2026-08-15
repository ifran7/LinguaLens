import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lesson_status.dart';
import '../../domain/entities/lesson_with_batch.dart';
import 'lesson_status_badge.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.item,
    this.onTap,
    this.onMarkComplete,
  });

  final LessonWithBatch item;
  final VoidCallback? onTap;
  final VoidCallback? onMarkComplete;

  @override
  Widget build(BuildContext context) {
    final lesson = item.lesson;
    final statusColor = lesson.lessonStatus.color;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 7,
                height: 82,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 8),
                        LessonStatusBadge(
                          status: lesson.lessonStatus,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.batch.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 5,
                      children: [
                        _Meta(
                          icon: Icons.calendar_today_outlined,
                          label: DateFormat('EEE, d MMM')
                              .format(lesson.lessonDate),
                        ),
                        if (lesson.durationMinutes > 0)
                          _Meta(
                            icon: Icons.schedule_outlined,
                            label: '${lesson.durationMinutes} min',
                          ),
                        if (item.coveredTopics.isNotEmpty)
                          _Meta(
                            icon: Icons.menu_book_outlined,
                            label:
                                '${item.coveredTopics.length} topic${item.coveredTopics.length == 1 ? '' : 's'}',
                          ),
                        if (item.hasAttendance)
                          _Meta(
                            icon: Icons.fact_check_outlined,
                            label: '${item.attendanceMarkedCount} marked',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onMarkComplete != null &&
                  lesson.lessonStatus == LessonStatus.planned)
                IconButton(
                  tooltip: 'Mark complete',
                  onPressed: onMarkComplete,
                  icon: const Icon(Icons.check_circle_outline),
                  color: AppColors.success,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 14,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
