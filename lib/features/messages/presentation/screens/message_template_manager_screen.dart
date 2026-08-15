import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/message_entities.dart';
import '../../domain/entities/message_enums.dart';
import '../../providers/message_provider.dart';

class MessageTemplateManagerScreen extends ConsumerWidget {
  const MessageTemplateManagerScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, {
    MessageTemplateEntity? template,
  }) async {
    final result = await showDialog<MessageTemplateEntity>(
      context: context,
      builder: (_) => _TemplateDialog(template: template),
    );
    if (result == null) return;
    final repository = ref.read(messageTemplateRepositoryProvider);
    if (template == null) {
      await repository.addTemplate(result);
    } else {
      await repository.updateTemplate(result);
    }
    ref.invalidate(messageTemplatesProvider);
    ref.invalidate(messageTemplatesByCategoryProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final templates = ref.watch(messageTemplatesProvider);
    return AppPage(
      title: l10n.t('messageTemplates'),
      showBack: true,
      action: IconButton(
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add_rounded),
        tooltip: l10n.t('addTemplate'),
      ),
      child: templates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.t('couldNotLoad'))),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.edit_note_rounded,
                title: l10n.t('noTemplates'),
                body: l10n.t('noTemplatesBody'),
                cta: l10n.t('addTemplate'),
                onPressed: () => _edit(context, ref),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: IconBadge(
                        icon: item.category.icon,
                        color: item.category.color,
                        size: 44,
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.category.label(l10n)} • ${item.usageCount} ${l10n.t('uses')}\n${item.bodyEn}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            await _edit(context, ref, template: item);
                          }
                          if (value == 'delete' && !item.isDefault) {
                            await ref
                                .read(messageTemplateRepositoryProvider)
                                .deleteTemplate(item.id);
                            ref.invalidate(messageTemplatesProvider);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text(l10n.t('edit')),
                          ),
                          if (!item.isDefault)
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(l10n.t('delete')),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _TemplateDialog extends StatefulWidget {
  const _TemplateDialog({this.template});
  final MessageTemplateEntity? template;

  @override
  State<_TemplateDialog> createState() => _TemplateDialogState();
}

class _TemplateDialogState extends State<_TemplateDialog> {
  late final TextEditingController _title;
  late final TextEditingController _en;
  late final TextEditingController _bn;
  late MessageCategory _category;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    _title = TextEditingController(text: template?.title ?? '');
    _en = TextEditingController(text: template?.bodyEn ?? '');
    _bn = TextEditingController(text: template?.bodyBn ?? '');
    _category = template?.category ?? MessageCategory.custom;
  }

  @override
  void dispose() {
    _title.dispose();
    _en.dispose();
    _bn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(
        widget.template == null
            ? l10n.t('addTemplate')
            : l10n.t('editTemplate'),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: l10n.t('templateTitle')),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MessageCategory>(
              initialValue: _category,
              decoration: InputDecoration(labelText: l10n.t('category')),
              items: MessageCategory.values
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item.label(l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _category = value ?? MessageCategory.custom),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _en,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: l10n.t('englishBody'),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bn,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: l10n.t('banglaBody'),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.t('messageVariablesHint'),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.t('cancel')),
        ),
        FilledButton(
          onPressed: () {
            if (_title.text.trim().isEmpty || _en.text.trim().isEmpty) return;
            final now = DateTime.now();
            Navigator.pop(
              context,
              MessageTemplateEntity(
                id: widget.template?.id ?? const Uuid().v4(),
                title: _title.text.trim(),
                bodyEn: _en.text.trim(),
                bodyBn: _bn.text.trim(),
                category: _category,
                isDefault: widget.template?.isDefault ?? false,
                usageCount: widget.template?.usageCount ?? 0,
                createdAt: widget.template?.createdAt ?? now,
                updatedAt: now,
              ),
            );
          },
          child: Text(l10n.t('save')),
        ),
      ],
    );
  }
}
