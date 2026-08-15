import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../batches/providers/batch_provider.dart';
import '../../domain/entities/lesson_plan_entity.dart';
import '../../domain/entities/lesson_type.dart';
import '../../providers/lesson_provider.dart';

class LessonFormScreen extends ConsumerStatefulWidget {
  const LessonFormScreen({
    super.key,
    this.lessonId,
    this.initialBatchId,
    this.initialDate,
  });

  final String? lessonId;
  final String? initialBatchId;
  final DateTime? initialDate;

  @override
  ConsumerState<LessonFormScreen> createState() => _LessonFormScreenState();
}

class _LessonFormScreenState extends ConsumerState<LessonFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _duration = TextEditingController(text: '60');
  final _homework = TextEditingController();
  final _resources = TextEditingController();
  final _note = TextEditingController();
  String? _batchId;
  DateTime _date = normalizeDate(DateTime.now());
  LessonType _type = LessonType.daily;
  String? _lessonStatus;
  Set<String> _topicIds = {};
  bool _loading = false;
  bool _editingLoaded = false;

  @override
  void initState() {
    super.initState();
    _batchId = widget.initialBatchId;
    _date = normalizeDate(widget.initialDate ?? DateTime.now());
    Future.microtask(_load);
  }

  Future<void> _load() async {
    ref.read(batchesListProvider.notifier).loadBatches();
    if (widget.lessonId == null) return;
    final lesson = await ref
        .read(lessonRepositoryProvider)
        .getLessonById(widget.lessonId!);
    if (!mounted || lesson == null) return;
    setState(() {
      _editingLoaded = true;
      _batchId = lesson.batchId;
      _date = lesson.lessonDate;
      _type = lesson.type;
      _lessonStatus = lesson.status;
      _topicIds = lesson.coveredTopicIds.toSet();
      _title.text = lesson.title;
      _description.text = lesson.description;
      _duration.text = lesson.durationMinutes.toString();
      _homework.text = lesson.homework;
      _resources.text = lesson.resourceLinks;
      _note.text = lesson.teacherNote;
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _duration.dispose();
    _homework.dispose();
    _resources.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _batchId == null) return;
    setState(() => _loading = true);
    final now = DateTime.now();
    final existing = widget.lessonId == null
        ? null
        : await ref
              .read(lessonRepositoryProvider)
              .getLessonById(widget.lessonId!);
    final lesson = LessonPlanEntity(
      id: existing?.id ?? const Uuid().v4(),
      batchId: _batchId!,
      title: _title.text.trim(),
      description: _description.text.trim(),
      lessonDate: _date,
      planType: _type.value,
      status: _lessonStatus ?? 'planned',
      coveredTopicIds: _topicIds.toList(),
      homework: _homework.text.trim(),
      resourceLinks: _resources.text.trim(),
      durationMinutes: int.tryParse(_duration.text.trim()) ?? 0,
      teacherNote: _note.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    final repo = ref.read(lessonRepositoryProvider);
    if (existing == null) {
      await repo.addLesson(lesson);
    } else {
      await repo.updateLesson(lesson);
    }
    invalidateAllLessonProviders(
      ref,
      batchId: lesson.batchId,
      lessonId: lesson.id,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.t('lessonSaved'))));
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final batches = ref
        .watch(batchesListProvider)
        .allBatches
        .where((batch) => batch.isActive)
        .toList();
    final topics = _batchId == null
        ? const []
        : ref
              .watch(batchSyllabusProvider(_batchId!))
              .maybeWhen(data: (value) => value, orElse: () => const []);
    final l10n = context.l10n;
    return AppPage(
      title: widget.lessonId == null
          ? l10n.t('newLesson')
          : l10n.t('editLesson'),
      showBack: true,
      action: FilledButton(
        onPressed: _loading ? null : _save,
        child: Text(l10n.t('save')),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            if (_loading || (widget.lessonId != null && !_editingLoaded))
              const LinearProgressIndicator(),
            TextFormField(
              controller: _title,
              decoration: InputDecoration(
                labelText: l10n.t('lessonTitle'),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.t('lessonTitleRequired')
                  : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _batchId,
              decoration: InputDecoration(
                labelText: l10n.t('batchName'),
                prefixIcon: const Icon(Icons.groups_outlined),
              ),
              items: batches
                  .map(
                    (batch) => DropdownMenuItem(
                      value: batch.id,
                      child: Text(batch.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                _batchId = value;
                _topicIds = {};
              }),
              validator: (value) =>
                  value == null ? l10n.t('batchRequired') : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: _date,
                      );
                      if (picked != null) {
                        setState(() => _date = normalizeDate(picked));
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.t('lessonDate'),
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(DateFormat('d MMM yyyy').format(_date)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.t('duration'),
                      suffixText: l10n.t('minutes'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<LessonType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.t('lessonType'),
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: LessonType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.localizedLabel(context)),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _type = value ?? LessonType.daily),
            ),
            if (widget.lessonId != null) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _lessonStatus ?? 'planned',
                decoration: InputDecoration(
                  labelText: l10n.t('lessonStatus'),
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                items: ['planned', 'completed', 'skipped', 'postponed']
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _lessonStatus = value),
              ),
            ],
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.t('lessonDescription'),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            _TopicSelector(
              topics: topics,
              selected: _topicIds,
              onChanged: (value) => setState(() => _topicIds = value),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _homework,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.t('homework'),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _resources,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.t('resources'),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _note,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.t('teacherNote'),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicSelector extends StatelessWidget {
  const _TopicSelector({
    required this.topics,
    required this.selected,
    required this.onChanged,
  });

  final List<dynamic> topics;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            const Icon(Icons.info_outline),
            const SizedBox(width: 10),
            Expanded(child: Text(context.l10n.t('noTopicsLinked'))),
          ],
        ),
      );
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.t('topicsCovered'),
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          ...topics.map(
            (topic) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: selected.contains(topic.id),
              title: Text(topic.title),
              subtitle: topic.chapterName.isEmpty
                  ? null
                  : Text(topic.chapterName),
              onChanged: (value) {
                final next = {...selected};
                if (value == true) {
                  next.add(topic.id);
                } else {
                  next.remove(topic.id);
                }
                onChanged(next);
              },
            ),
          ),
        ],
      ),
    );
  }
}
