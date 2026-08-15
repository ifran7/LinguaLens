import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/id_utils.dart';
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
  String _photoPath = '';
  bool _saving = false;

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
    }
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
    ]) {
      controller.dispose();
    }
    super.dispose();
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
      );
      if (_isEditing) {
        await ref.read(studentsListProvider.notifier).updateStudent(student);
      } else {
        await ref.read(studentsListProvider.notifier).addStudent(student);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.t('studentSaved'))));
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not save student')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? context.l10n.t('required') : null;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.t('editStudent') : l.t('addStudent')),
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Center(
              child: GestureDetector(
                onTap: _choosePhoto,
                child: _FormAvatar(name: _name.text, photoPath: _photoPath),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                l.t('chooseFromGallery'),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 28),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            _SectionTitle(title: l.t('address')),
            _Field(controller: _address, label: l.t('address'), maxLines: 2),
            _Field(
              controller: _notes,
              label: l.t('notes'),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 16),
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
                label: Text(l.t('saveStudent')),
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
    padding: const EdgeInsets.only(bottom: 12),
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
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(child: Text(error.toString())),
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
