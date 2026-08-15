import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../students/data/models/student_model.dart';
import '../../domain/entities/message_entities.dart';
import '../../domain/entities/message_enums.dart';
import '../../providers/message_provider.dart';
import '../../services/message_variable_resolver.dart';
import '../../services/messaging_service.dart';

class ComposeMessageScreen extends ConsumerStatefulWidget {
  const ComposeMessageScreen({super.key, this.studentId, this.batchId});
  final String? studentId;
  final String? batchId;

  @override
  ConsumerState<ComposeMessageScreen> createState() =>
      _ComposeMessageScreenState();
}

class _ComposeMessageScreenState extends ConsumerState<ComposeMessageScreen> {
  final _bodyController = TextEditingController();
  final _noteController = TextEditingController();
  final _resolver = const MessageVariableResolver();
  final _messaging = const MessagingService();
  String? _studentId;
  MessageTemplateEntity? _template;
  MessageChannel _channel = MessageChannel.whatsapp;
  ResolvedMessage? _preview;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _studentId = widget.studentId;
    _bodyController.addListener(_onBodyChanged);
  }

  @override
  void dispose() {
    _bodyController
      ..removeListener(_onBodyChanged)
      ..dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onBodyChanged() => _resolvePreview();

  Future<void> _resolvePreview() async {
    final studentId = _studentId;
    if (studentId == null || _bodyController.text.isEmpty) {
      if (mounted) setState(() => _preview = null);
      return;
    }
    final value = await _resolver.resolve(
      body: _bodyController.text,
      studentId: studentId,
      batchId: widget.batchId,
      teacherNote: _noteController.text,
    );
    if (mounted) setState(() => _preview = value);
  }

  Future<void> _send() async {
    final studentId = _studentId;
    final preview = _preview;
    if (studentId == null || preview == null || preview.text.trim().isEmpty) {
      setState(() => _error = context.l10n.t('completeMessageFields'));
      return;
    }
    final students = Hive.box<StudentModel>('studentsBox');
    final student = students.get(studentId);
    if (student == null) return;
    final phone = student.parentPhone.isNotEmpty
        ? student.parentPhone
        : student.phone;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = _channel == MessageChannel.whatsapp
        ? await _messaging.launchWhatsApp(phone: phone, message: preview.text)
        : await _messaging.launchSMS(phone: phone, message: preview.text);
    if (!mounted) return;
    if (result == MessagingResult.success) {
      final log = MessageLogEntity(
        id: const Uuid().v4(),
        studentId: studentId,
        batchId: widget.batchId ?? '',
        channel: _channel,
        recipientPhone: phone,
        messageBody: preview.text,
        templateId: _template?.id ?? '',
        category: _template?.category ?? MessageCategory.custom,
        teacherNote: _noteController.text.trim(),
        sentAt: DateTime.now(),
      );
      await ref.read(messageLogRepositoryProvider).addLog(log);
      if (_template != null) {
        await ref
            .read(messageTemplateRepositoryProvider)
            .incrementUsageCount(_template!.id);
      }
      invalidateMessageProviders(ref, studentId: studentId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('messageOpened'))),
        );
        context.pop();
      }
    } else {
      setState(() {
        _loading = false;
        _error = switch (result) {
          MessagingResult.invalidPhone => context.l10n.t('invalidPhone'),
          MessagingResult.appNotFound => context.l10n.t(
            'messagingAppUnavailable',
          ),
          _ => context.l10n.t('couldNotOpenMessaging'),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final templates = ref.watch(messageTemplatesProvider);
    final students = Hive.box<StudentModel>('studentsBox').values.toList();
    final selectedStudent = students
        .where((item) => item.id == _studentId)
        .firstOrNull;
    return AppPage(
      title: l10n.t('composeMessage'),
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            l10n.t('recipient'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _studentId,
            decoration: InputDecoration(labelText: l10n.t('selectStudent')),
            items: students
                .map(
                  (item) => DropdownMenuItem(
                    value: item.id,
                    child: Text(item.fullName),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() => _studentId = value);
              _resolvePreview();
            },
          ),
          if (selectedStudent != null) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.t('parent')}: ${selectedStudent.parentName.isEmpty ? l10n.t('parent') : selectedStudent.parentName} • ${selectedStudent.parentPhone.isEmpty ? selectedStudent.phone : selectedStudent.parentPhone}',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            l10n.t('chooseTemplate'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          templates.when(
            data: (items) => DropdownButtonFormField<String>(
              initialValue: _template?.id,
              decoration: InputDecoration(labelText: l10n.t('messageTemplate')),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.title),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                final item = items.firstWhere(
                  (candidate) => candidate.id == id,
                );
                setState(() {
                  _template = item;
                  _bodyController.text = item.bodyFor(
                    LocalStorageService.instance.defaultMessageLanguage,
                  );
                });
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => Text(l10n.t('couldNotLoad')),
          ),
          const SizedBox(height: 16),
          SegmentedButton<MessageChannel>(
            segments: [
              ButtonSegment(
                value: MessageChannel.whatsapp,
                icon: const Icon(Icons.chat_rounded),
                label: Text(l10n.t('whatsapp')),
              ),
              ButtonSegment(
                value: MessageChannel.sms,
                icon: const Icon(Icons.sms_rounded),
                label: Text(l10n.t('sms')),
              ),
            ],
            selected: {_channel},
            onSelectionChanged: (values) =>
                setState(() => _channel = values.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bodyController,
            minLines: 6,
            maxLines: 10,
            decoration: InputDecoration(
              labelText: l10n.t('messageBody'),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            onChanged: (_) => _resolvePreview(),
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: l10n.t('teacherNote'),
              alignLabelWithHint: true,
            ),
          ),
          if (_preview != null) ...[
            const SizedBox(height: 20),
            AppCard(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('preview'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(_preview!.text),
                  if (_preview!.hasUnresolved) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.t('missingInformation')}: ${_preview!.unresolved.join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.orange),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loading ? null : _send,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_channel.icon),
            label: Text(l10n.t('openAndSend')),
          ),
        ],
      ),
    );
  }
}
