import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/spacing_tokens.dart';
import '../../../../core/theme/text_tokens.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/id_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/premium_widgets.dart';
import '../../../batches/domain/entities/batch_enrollment_entity.dart';
import '../../../batches/providers/batch_provider.dart';
import '../../domain/entities/student_entity.dart';
import '../../providers/student_provider.dart';
import '../widgets/student_avatar_picker.dart';
import '../widgets/student_ui_utils.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  const StudentFormScreen({super.key, this.student});

  final StudentEntity? student;

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _parentName = TextEditingController();
  final _parentPhone = TextEditingController();
  final _className = TextEditingController();
  final _schoolName = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();
  final _scheduleNote = TextEditingController();

  String _photoPath = '';
  String _preferredStartTime = '';
  Set<int> _preferredWeekdays = <int>{};
  Set<String> _selectedBatchIds = <String>{};
  List<BatchEnrollmentEntity> _existingEnrollments = const [];
  bool _saving = false;
  bool _loadingAssignments = true;

  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    if (student != null) {
      _name.text = student.fullName;
      _phone.text = student.phone;
      _parentName.text = student.parentName;
      _parentPhone.text = student.parentPhone;
      _className.text = student.className;
      _schoolName.text = student.schoolName;
      _address.text = student.address;
      _notes.text = student.notes;
      _photoPath = student.photoPath;
      _preferredStartTime = student.preferredStartTime;
      _preferredWeekdays = student.preferredWeekdays.toSet();
      _scheduleNote.text = student.preferredScheduleNote;
    }
    Future.microtask(_loadBatchAssignments);
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _phone,
      _parentName,
      _parentPhone,
      _className,
      _schoolName,
      _address,
      _notes,
      _scheduleNote,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadBatchAssignments() async {
    try {
      final batchesNotifier = ref.read(batchesListProvider.notifier);
      if (ref.read(batchesListProvider).allBatches.isEmpty) {
        await batchesNotifier.loadBatches();
      }
      if (widget.student != null) {
        final all = await ref
            .read(enrollmentRepositoryProvider)
            .getAllEnrollments();
        final mine = all
            .where((enrollment) => enrollment.studentId == widget.student!.id)
            .toList();
        if (!mounted) return;
        setState(() {
          _existingEnrollments = mine;
          _selectedBatchIds = mine
              .where((enrollment) => enrollment.isActive)
              .map((enrollment) => enrollment.batchId)
              .toSet();
          _loadingAssignments = false;
        });
      } else if (mounted) {
        setState(() => _loadingAssignments = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAssignments = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final existing = widget.student;
      final student = StudentEntity(
        id: existing?.id ?? const Uuid().v4(),
        fullName: _name.text.trim(),
        studentCode: existing?.studentCode ?? await generateStudentCode(),
        phone: _phone.text.trim(),
        parentName: _parentName.text.trim(),
        parentPhone: _parentPhone.text.trim(),
        className: _className.text.trim(),
        schoolName: _schoolName.text.trim(),
        address: _address.text.trim(),
        notes: _notes.text.trim(),
        photoPath: _photoPath,
        isActive: existing?.isActive ?? true,
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        preferredStartTime: _preferredStartTime,
        preferredWeekdays: _preferredWeekdays.toList()..sort(),
        preferredScheduleNote: _scheduleNote.text.trim(),
      );
      if (_isEditing) {
        await ref.read(studentsListProvider.notifier).updateStudent(student);
      } else {
        await ref.read(studentsListProvider.notifier).addStudent(student);
      }
      await _syncEnrollments(student);
      ref.invalidate(studentDetailProvider(student.id));
      ref.invalidate(studentBatchOverviewsProvider(student.id));
      for (final batchId in _affectedBatchIds) {
        ref.invalidate(batchStudentCountProvider(batchId));
        ref.invalidate(batchEnrollmentsProvider(batchId));
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.t('studentSaved'))));
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('couldNotSaveStudent'))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Set<String> get _affectedBatchIds => {
    ..._selectedBatchIds,
    ..._existingEnrollments.map((enrollment) => enrollment.batchId),
  };

  Future<void> _syncEnrollments(StudentEntity student) async {
    final repository = ref.read(enrollmentRepositoryProvider);
    final all = await repository.getAllEnrollments();
    final existing = all
        .where((enrollment) => enrollment.studentId == student.id)
        .toList();
    final now = DateTime.now();
    final batches = ref.read(batchesListProvider).allBatches;

    for (final batchId in _selectedBatchIds) {
      final matching = existing
          .where((item) => item.batchId == batchId)
          .toList();
      final historical = matching.isEmpty ? null : matching.first;
      if (historical == null) {
        await repository.enrollStudent(
          BatchEnrollmentEntity(
            id: const Uuid().v4(),
            studentId: student.id,
            batchId: batchId,
            joiningDate: now,
            customFee: 0,
            isActive: true,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else if (!historical.isActive) {
        await repository.updateEnrollment(
          historical.copyWith(isActive: true, updatedAt: now),
        );
      }
    }

    for (final enrollment in existing.where((item) => item.isActive)) {
      if (!_selectedBatchIds.contains(enrollment.batchId)) {
        await repository.removeStudentFromBatch(enrollment.id);
      }
    }

    // Keep the batch list dependency explicit so a newly selected batch with a
    // stale local list cannot silently bypass the UI's available options.
    if (batches.isEmpty && _selectedBatchIds.isNotEmpty) {
      throw StateError('No batch data available for enrollment sync');
    }
  }

  Future<void> _choosePhoto() async {
    final path = await showStudentAvatarPicker(
      context,
      studentId: widget.student?.id ?? const Uuid().v4(),
      currentPath: _photoPath,
    );
    if (!mounted || path == null) return;
    setState(() => _photoPath = path);
  }

  Future<void> _choosePreferredTime() async {
    final initial =
        _parseTime(_preferredStartTime) ?? const TimeOfDay(hour: 16, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (!mounted || picked == null) return;
    setState(() {
      _preferredStartTime = MaterialLocalizations.of(context)
          .formatTimeOfDay(picked, alwaysUse24HourFormat: false);
    });
  }

  TimeOfDay? _parseTime(String value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null || hour > 23 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? context.l10n.t('required') : null;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final batchesState = ref.watch(batchesListProvider);
    final availableBatches = batchesState.allBatches
        .where((batch) => batch.isActive)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.t('editStudent') : l.t('addStudent')),
        leading: const BackButton(),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l.t('save')),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.hero,
          ),
          children: [
            Center(
              child: Semantics(
                button: true,
                label: l.t('chooseFromGallery'),
                child: GestureDetector(
                  onTap: _choosePhoto,
                  child: _FormAvatar(name: _name.text, photoPath: _photoPath),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                l.t('chooseFromGallery'),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.muted),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionTitle(title: l.t('fullName')),
            _Field(
              controller: _name,
              label: l.t('fullName'),
              validator: (value) {
                final required = _required(value);
                if (required != null) return required;
                return value!.trim().length < 2 ? l.t('required') : null;
              },
            ),
            _Field(
              controller: _phone,
              label: l.t('phone'),
              keyboardType: TextInputType.phone,
            ),
            _Field(
              controller: _className,
              label: l.t('className'),
              validator: _required,
            ),
            _Field(controller: _schoolName, label: l.t('schoolName')),
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle(title: l.t('parentName')),
            _Field(
              controller: _parentName,
              label: l.t('parentName'),
              validator: _required,
            ),
            _Field(
              controller: _parentPhone,
              label: l.t('parentPhone'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                final required = _required(value);
                if (required != null) return required;
                final digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
                return digits.length < 10 ? l.t('phoneInvalid') : null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle(title: l.t('preferredSchedule')),
            _buildPreferredSchedule(l),
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle(title: l.t('studentBatches')),
            _buildBatchAssignments(l, availableBatches, batchesState.isLoading),
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle(title: l.t('address')),
            _Field(controller: _address, label: l.t('address'), maxLines: 2),
            _Field(
              controller: _notes,
              label: l.t('notes'),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 52,
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
                label: Text(l.t('saveStudent')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferredSchedule(AppLocalizations l) {
    final weekdays = <int, String>{
      DateTime.monday: l.t('mondayShort'),
      DateTime.tuesday: l.t('tuesdayShort'),
      DateTime.wednesday: l.t('wednesdayShort'),
      DateTime.thursday: l.t('thursdayShort'),
      DateTime.friday: l.t('fridayShort'),
      DateTime.saturday: l.t('saturdayShort'),
      DateTime.sunday: l.t('sundayShort'),
    };
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _choosePreferredTime,
            borderRadius: BorderRadius.circular(AppRadii.field),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.t('preferredStartTime'),
                          style: AppTextTokens.cardTitle,
                        ),
                        Text(
                          _preferredStartTime.isEmpty
                              ? l.t('notSet')
                              : _preferredStartTime,
                          style: AppTextTokens.metadata.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(l.t('preferredWeekdays'), style: AppTextTokens.metadata),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: weekdays.entries
                .map(
                  (entry) => FilterChip(
                    label: Text(entry.value),
                    selected: _preferredWeekdays.contains(entry.key),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _preferredWeekdays.add(entry.key);
                        } else {
                          _preferredWeekdays.remove(entry.key);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          _Field(
            controller: _scheduleNote,
            label: l.t('scheduleNote'),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBatchAssignments(
    AppLocalizations l,
    List<dynamic> availableBatches,
    bool loading,
  ) {
    if (_loadingAssignments || loading) {
      return const AppLoading();
    }
    if (availableBatches.isEmpty) {
      return PremiumCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.t('noBatchesYet'), style: AppTextTokens.cardTitle),
            const SizedBox(height: AppSpacing.xs),
            Text(l.t('createBatchToAssign'), style: AppTextTokens.metadata),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => context.push('/batches/add'),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.t('createBatch')),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final batch in availableBatches) ...[
          PremiumToggleTile(
            title: batch.name,
            subtitle:
                '${batch.subject} · ${batch.scheduleText} · ${formatFee(batch.monthlyFeeDefault)}',
            leading: IconBadge(icon: Icons.groups_rounded, color: batch.color),
            selected: _selectedBatchIds.contains(batch.id),
            semanticLabel: '${batch.name}, ${l.t('assignToBatch')}',
            onChanged: (selected) {
              setState(() {
                if (selected) {
                  _selectedBatchIds.add(batch.id);
                } else {
                  _selectedBatchIds.remove(batch.id);
                }
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(AppRadii.chip),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.7,
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
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

class _FormAvatar extends StatelessWidget {
  const _FormAvatar({required this.name, required this.photoPath});

  final String name;
  final String photoPath;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      CircleAvatar(
        radius: 52,
        backgroundColor: generateAvatarColor(name).withValues(alpha: 0.15),
        backgroundImage: hasLocalPhoto(photoPath)
            ? FileImage(File(photoPath))
            : null,
        child: hasLocalPhoto(photoPath)
            ? null
            : Text(
                studentInitials(name.isEmpty ? 'S' : name),
                style: TextStyle(
                  color: generateAvatarColor(name),
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
      ),
      Positioned(
        right: 0,
        bottom: 0,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    ],
  );
}

class StudentEditLoader extends ConsumerWidget {
  const StudentEditLoader({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStudent = ref.watch(studentDetailProvider(studentId));
    return asyncStudent.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (error, _) => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: AppErrorState(message: error.toString()),
      ),
      data: (student) => student == null
          ? Scaffold(
              appBar: AppBar(leading: const BackButton()),
              body: Center(child: Text(context.l10n.t('studentNotFound'))),
            )
          : StudentFormScreen(student: student),
    );
  }
}
