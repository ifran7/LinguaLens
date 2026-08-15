import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/lesson_status.dart';
import '../../domain/entities/lesson_type.dart';
import '../../providers/lesson_provider.dart';
import '../widgets/lesson_status_badge.dart';

class LessonDetailScreen extends ConsumerWidget {
  const LessonDetailScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(lessonDetailProvider(lessonId));
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => AppPage(
        title: context.l10n.t('lessonDetail'),
        showBack: true,
        child: Center(child: Text(error.toString())),
      ),
      data: (item) {
        if (item == null) {
          return AppPage(
            title: context.l10n.t('lessonDetail'),
            showBack: true,
            child: Center(child: Text(context.l10n.t('noLessonsPlanned'))),
          );
        }
        final lesson = item.lesson;
        return AppPage(
          title: context.l10n.t('lessonDetail'),
          showBack: true,
          action: PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                await context.push('/lessons/edit/${lesson.id}');
              } else if (value == 'delete') {
                final ok = await _confirmDelete(context);
                if (ok == true) {
                  await ref
                      .read(lessonRepositoryProvider)
                      .deleteLesson(lesson.id);
                  invalidateAllLessonProviders(
                    ref,
                    batchId: lesson.batchId,
                    lessonId: lesson.id,
                  );
                  if (context.mounted) context.pop();
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(context.l10n.t('editLesson')),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(context.l10n.t('deleteLesson')),
              ),
            ],
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        LessonStatusBadge(status: lesson.lessonStatus),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.batch.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      children: [
                        _Meta(
                          icon: Icons.calendar_today_outlined,
                          text: DateFormat('EEEE, d MMMM yyyy')
                              .format(lesson.lessonDate),
                        ),
                        _Meta(
                          icon: Icons.schedule_outlined,
                          text:
                              '${lesson.durationMinutes} ${context.l10n.t('minutes')}',
                        ),
                        _Meta(
                          icon: lesson.type.icon,
                          text: lesson.type.localizedLabel(context),
                        ),
                      ],
                    ),
                    if (lesson.description.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(lesson.description),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (lesson.lessonStatus == LessonStatus.planned) ...[
                FilledButton.icon(
                  onPressed: () async {
                    await ref
                        .read(lessonRepositoryProvider)
                        .updateLessonStatus(lesson.id, LessonStatus.completed);
                    invalidateAllLessonProviders(
                      ref,
                      batchId: lesson.batchId,
                      lessonId: lesson.id,
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(context.l10n.t('markComplete')),
                ),
                const SizedBox(height: 10),
              ],
              OutlinedButton.icon(
                onPressed: () => context.push(
                  '/attendance/batch/${lesson.batchId}',
                  extra: lesson.lessonDate,
                ),
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(
                  item.hasAttendance
                      ? context.l10n.t('viewEditAttendance')
                      : context.l10n.t('markAttendanceNow'),
                ),
              ),
              if (item.coveredTopics.isNotEmpty) ...[
                const SizedBox(height: 18),
                SectionHeader(title: context.l10n.t('topicsCovered')),
                AppCard(
                  child: Column(
                    children: item.coveredTopics
                        .map(
                          (topic) => ListTile(
                            leading: Icon(
                              topic.isCompleted
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: topic.isCompleted ? Colors.green : null,
                            ),
                            title: Text(topic.title),
                            subtitle: topic.chapterName.isEmpty
                                ? null
                                : Text(topic.chapterName),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              if (lesson.homework.isNotEmpty) ...[
                const SizedBox(height: 18),
                SectionHeader(title: context.l10n.t('homework')),
                AppCard(child: SelectableText(lesson.homework)),
              ],
              if (lesson.resourceLinks.isNotEmpty) ...[
                const SizedBox(height: 18),
                SectionHeader(title: context.l10n.t('resources')),
                AppCard(child: SelectableText(lesson.resourceLinks)),
              ],
              if (lesson.teacherNote.isNotEmpty) ...[
                const SizedBox(height: 18),
                SectionHeader(title: context.l10n.t('teacherNote')),
                AppCard(child: Text(lesson.teacherNote)),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.t('deleteLesson')),
      content: Text(context.l10n.t('deleteLessonConfirm')),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(context.l10n.t('cancel')),
        ),
        FilledButton(
          onPressed: () => context.pop(true),
          child: Text(context.l10n.t('deleteLesson')),
        ),
      ],
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [Icon(icon, size: 16), const SizedBox(width: 5), Text(text)],
  );
}
