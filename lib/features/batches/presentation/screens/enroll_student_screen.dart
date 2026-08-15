import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/exceptions.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/providers/student_provider.dart';
import '../../domain/entities/batch_entity.dart';
import '../../domain/entities/batch_enrollment_entity.dart';
import '../../providers/batch_provider.dart';

class EnrollStudentScreen extends ConsumerStatefulWidget {
  const EnrollStudentScreen({super.key, required this.batch});
  final BatchEntity batch;

  @override
  ConsumerState<EnrollStudentScreen> createState() =>
      _EnrollStudentScreenState();
}

class _EnrollStudentScreenState extends ConsumerState<EnrollStudentScreen> {
  final _search = TextEditingController();
  final _fee = TextEditingController();
  final _note = TextEditingController();
  List<StudentEntity> _students = [];
  List<StudentEntity> _filtered = [];
  Set<String> _enrolledIds = {};
  StudentEntity? _selected;
  DateTime _joiningDate = DateTime.now();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(_filterStudents);
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _search.dispose();
    _fee.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final studentRepo = ref.read(studentRepositoryProvider);
      final enrollmentRepo = ref.read(enrollmentRepositoryProvider);
      final students = await studentRepo.getActiveStudents();
      final enrollments = await enrollmentRepo.getEnrollmentsByBatch(
        widget.batch.id,
      );
      if (!mounted) return;
      setState(() {
        _students = students;
        _filtered = students;
        _enrolledIds = enrollments.map((item) => item.studentId).toSet();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filterStudents() {
    final needle = _search.text.trim().toLowerCase();
    setState(() {
      _filtered = _students.where((student) {
        return needle.isEmpty ||
            [
              student.fullName,
              student.studentCode,
              student.phone,
              student.className,
            ].any((value) => value.toLowerCase().contains(needle));
      }).toList();
    });
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: _joiningDate,
    );
    if (selected != null) setState(() => _joiningDate = selected);
  }

  Future<void> _enroll() async {
    final student = _selected;
    if (student == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('selectStudentToContinue'))),
      );
      return;
    }
    final double? fee = _fee.text.trim().isEmpty
        ? 0
        : double.tryParse(_fee.text.trim());
    if (fee == null || fee < 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.t('required'))));
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final enrollment = BatchEnrollmentEntity(
      id: const Uuid().v4(),
      studentId: student.id,
      batchId: widget.batch.id,
      joiningDate: _joiningDate,
      customFee: fee,
      note: _note.text.trim(),
      createdAt: now,
      updatedAt: now,
    );
    try {
      await ref
          .read(batchEnrollmentsProvider(widget.batch.id).notifier)
          .enrollStudent(enrollment);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('studentEnrolled'))),
      );
      Navigator.of(context).pop(true);
    } on StudentAlreadyEnrolledException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('studentAlreadyEnrolled'))),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('enrollStudent')),
        leading: const BackButton(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: l.t('searchStudents'),
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                Expanded(
                  child:
                      _filtered
                          .where(
                            (student) => !_enrolledIds.contains(student.id),
                          )
                          .isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              _students.isEmpty
                                  ? l.t('noStudentsToEnroll')
                                  : l.t('allBatchesEnrolled'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 250),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final student = _filtered[index];
                            final already = _enrolledIds.contains(student.id);
                            return Card(
                              color: already
                                  ? Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                  : null,
                              child: ListTile(
                                enabled: !already,
                                onTap: already
                                    ? null
                                    : () => setState(() => _selected = student),
                                leading: CircleAvatar(
                                  child: Text(
                                    student.fullName.isEmpty
                                        ? '?'
                                        : student.fullName
                                              .substring(0, 1)
                                              .toUpperCase(),
                                  ),
                                ),
                                title: Text(student.fullName),
                                subtitle: Text(
                                  '${student.studentCode}  •  ${student.className}',
                                ),
                                trailing: already
                                    ? Chip(label: Text(l.t('enrolled')))
                                    : (_selected?.id == student.id
                                          ? const Icon(
                                              Icons.check_circle_rounded,
                                            )
                                          : null),
                              ),
                            );
                          },
                        ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    _selected == null ? 0 : 14,
                    16,
                    20,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: _selected == null
                        ? null
                        : [
                            const BoxShadow(
                              blurRadius: 16,
                              color: Colors.black12,
                            ),
                          ],
                  ),
                  child: _selected == null
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${l.t('selectStudent')}: ${_selected!.fullName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today_outlined),
                              label: Text(
                                '${l.t('joiningDate')}: ${DateFormat('dd MMM yyyy').format(_joiningDate)}',
                              ),
                            ),
                            TextField(
                              controller: _fee,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: l.t('customFee'),
                                hintText:
                                    '${l.t('leaveEmptyForDefault')} (${widget.batch.monthlyFeeDefault})',
                                prefixText: '৳ ',
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _note,
                              decoration: InputDecoration(
                                labelText: l.t('enrollmentNote'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 50,
                              child: FilledButton.icon(
                                onPressed: _saving ? null : _enroll,
                                icon: const Icon(
                                  Icons.person_add_alt_1_rounded,
                                ),
                                label: Text(l.t('enrollStudent')),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}

class BatchEnrollLoader extends ConsumerWidget {
  const BatchEnrollLoader({super.key, required this.batchId, this.batch});

  final String batchId;
  final BatchEntity? batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (batch != null) return EnrollStudentScreen(batch: batch!);
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
              : EnrollStudentScreen(batch: value),
        );
  }
}
