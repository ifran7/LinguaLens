import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/batch_entity.dart';
import '../../providers/batch_provider.dart';
import '../widgets/color_tag_picker.dart';
import '../widgets/subject_suggestions.dart';

class BatchFormScreen extends ConsumerStatefulWidget {
  const BatchFormScreen({super.key, this.batch});

  final BatchEntity? batch;

  @override
  ConsumerState<BatchFormScreen> createState() => _BatchFormScreenState();
}

class _BatchFormScreenState extends ConsumerState<BatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  final _schedule = TextEditingController();
  final _fee = TextEditingController();
  int _colorIndex = 0;
  bool _saving = false;

  bool get _editing => widget.batch != null;

  @override
  void initState() {
    super.initState();
    final batch = widget.batch;
    if (batch != null) {
      _name.text = batch.name;
      _subject.text = batch.subject;
      _description.text = batch.description;
      _schedule.text = batch.scheduleText;
      _fee.text =
          batch.monthlyFeeDefault == batch.monthlyFeeDefault.truncateToDouble()
          ? batch.monthlyFeeDefault.toInt().toString()
          : batch.monthlyFeeDefault.toStringAsFixed(2);
      _colorIndex = batch.colorTagIndex;
    }
  }

  @override
  void dispose() {
    for (final controller in [_name, _subject, _description, _schedule, _fee]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_fee.text.trim()) ?? 0;
    setState(() => _saving = true);
    final now = DateTime.now();
    final existing = widget.batch;
    final batch = BatchEntity(
      id: existing?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      subject: _subject.text.trim(),
      description: _description.text.trim(),
      scheduleText: _schedule.text.trim(),
      monthlyFeeDefault: amount,
      colorTagIndex: _colorIndex,
      isActive: existing?.isActive ?? true,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      if (existing == null) {
        await ref.read(batchesListProvider.notifier).addBatch(batch);
      } else {
        await ref.read(batchesListProvider.notifier).updateBatch(batch);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.t('batchSaved'))));
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.t('errorMessage'))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? context.l10n.t('required') : null;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t(_editing ? 'editBatch' : 'createBatch')),
        leading: const BackButton(),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l.t('save')),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          children: [
            _SectionTitle(title: l.t('batchName')),
            _Field(
              controller: _name,
              label: l.t('batchName'),
              maxLength: 80,
              validator: (value) {
                final required = _required(value);
                if (required != null) return required;
                return value!.trim().length < 2 ? l.t('required') : null;
              },
            ),
            _Field(
              controller: _subject,
              label: l.t('subject'),
              hint: l.t('subjectHint'),
              validator: _required,
              onChanged: (_) => setState(() {}),
            ),
            SubjectSuggestions(
              query: _subject.text,
              onSelected: (value) {
                _subject.text = value;
                setState(() {});
              },
            ),
            _Field(
              controller: _description,
              label: l.t('description'),
              maxLines: 3,
              maxLength: 300,
            ),
            const SizedBox(height: 14),
            _SectionTitle(title: l.t('schedule')),
            _Field(
              controller: _schedule,
              label: l.t('schedule'),
              hint: l.t('scheduleHint'),
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            _SectionTitle(title: l.t('defaultMonthlyFee')),
            _Field(
              controller: _fee,
              label: l.t('defaultMonthlyFee'),
              prefix: const Text('৳ '),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final required = _required(value);
                if (required != null) return required;
                final amount = double.tryParse(value!.trim());
                if (amount == null || amount < 0) return l.t('required');
                return null;
              },
            ),
            const SizedBox(height: 14),
            _SectionTitle(title: l.t('batchColor')),
            ColorTagPicker(
              selectedIndex: _colorIndex,
              onSelected: (value) => setState(() => _colorIndex = value),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(l.t('saveBatch')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.prefix,
    this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 14, right: 4),
                child: prefix,
              ),
      ),
    ),
  );
}

class BatchEditLoader extends ConsumerWidget {
  const BatchEditLoader({super.key, required this.batchId, this.batch});

  final String batchId;
  final BatchEntity? batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (batch != null) return BatchFormScreen(batch: batch);
    return ref
        .watch(batchDetailProvider(batchId))
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, _) =>
              Scaffold(body: Center(child: Text(error.toString()))),
          data: (value) => value == null
              ? Scaffold(
                  body: Center(child: Text(context.l10n.t('batchNotFound'))),
                )
              : BatchFormScreen(batch: value),
        );
  }
}
