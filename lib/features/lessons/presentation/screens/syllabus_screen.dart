import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/syllabus_topic_entity.dart';
import '../../providers/lesson_provider.dart';

class SyllabusScreen extends ConsumerStatefulWidget {
  const SyllabusScreen({super.key, required this.batchId, this.batchName});
  final String batchId;
  final String? batchName;
  @override
  ConsumerState<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends ConsumerState<SyllabusScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(syllabusEditProvider(widget.batchId).notifier).load(),
    );
  }

  Future<void> _addTopic() async {
    final title = TextEditingController();
    final chapter = TextEditingController();
    final description = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.t('addTopic')),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: title,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: context.l10n.t('topicTitle'),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: chapter,
                decoration: InputDecoration(
                  labelText: context.l10n.t('chapterName'),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: description,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: context.l10n.t('topicDescription'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(context.l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: Text(context.l10n.t('save')),
          ),
        ],
      ),
    );
    if (result != true || title.text.trim().isEmpty || !mounted) return;
    final now = DateTime.now();
    await ref
        .read(syllabusEditProvider(widget.batchId).notifier)
        .saveTopic(
          SyllabusTopicEntity(
            id: const Uuid().v4(),
            batchId: widget.batchId,
            title: title.text.trim(),
            chapterName: chapter.text.trim(),
            description: description.text.trim(),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> _bulkAdd() async {
    final controller = TextEditingController();
    final chapter = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.t('bulkAdd')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: chapter,
              decoration: InputDecoration(
                labelText: context.l10n.t('chapterName'),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: context.l10n.t('bulkAddHint'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(context.l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: Text(context.l10n.t('bulkAdd')),
          ),
        ],
      ),
    );
    if (result == true && controller.text.trim().isNotEmpty && mounted) {
      await ref
          .read(syllabusEditProvider(widget.batchId).notifier)
          .addBulkFromText(controller.text, chapterName: chapter.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(syllabusEditProvider(widget.batchId));
    final notifier = ref.read(syllabusEditProvider(widget.batchId).notifier);
    return AppPage(
      title: widget.batchName == null
          ? context.l10n.t('syllabus')
          : '${context.l10n.t('syllabus')} · ${widget.batchName}',
      showBack: true,
      action: PopupMenuButton<String>(
        onSelected: (value) =>
            value == 'bulk' ? _bulkAdd() : notifier.toggleReorderMode(),
        itemBuilder: (_) => [
          PopupMenuItem(value: 'bulk', child: Text(context.l10n.t('bulkAdd'))),
          PopupMenuItem(
            value: 'reorder',
            child: Text(
              state.reorderMode
                  ? context.l10n.t('exitReorder')
                  : context.l10n.t('reorderMode'),
            ),
          ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: notifier.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            ref
                .watch(batchSyllabusProgressProvider(widget.batchId))
                .when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (progress) => AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.t('syllabusProgress'),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '${progress.progressPercentage.round()}%',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progress.progressPercentage / 100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${progress.completedTopics} ${context.l10n.t('topicsCompleted')} · ${progress.remainingTopics} ${context.l10n.t('topicsRemaining')}',
                        ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 14),
            if (state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.topics.isEmpty)
              EmptyState(
                icon: Icons.menu_book_outlined,
                title: context.l10n.t('noSyllabusTopics'),
                body: context.l10n.t('addTopicsToTrack'),
                cta: context.l10n.t('addTopic'),
                onPressed: _addTopic,
              )
            else
              ...state.groups.map(
                (group) => AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.chapterName.isEmpty
                            ? context.l10n.t('ungrouped')
                            : group.chapterName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      ...group.topics.map(
                        (topic) => _TopicTile(
                          topic: topic,
                          reorderMode: state.reorderMode,
                          onToggle: () => notifier.toggleCompletion(topic.id),
                          onDelete: () => notifier.deleteTopic(topic.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _addTopic,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.t('addTopic')),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.topic,
    required this.reorderMode,
    required this.onToggle,
    required this.onDelete,
  });
  final SyllabusTopicEntity topic;
  final bool reorderMode;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: IconButton(
      onPressed: onToggle,
      icon: Icon(
        topic.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: topic.isCompleted ? Colors.green : null,
      ),
    ),
    title: Text(
      topic.title,
      style: TextStyle(
        decoration: topic.isCompleted ? TextDecoration.lineThrough : null,
      ),
    ),
    subtitle: topic.description.isEmpty ? null : Text(topic.description),
    trailing: reorderMode
        ? const Icon(Icons.drag_handle)
        : IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
  );
}
