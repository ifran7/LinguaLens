import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../students/providers/student_provider.dart';
import '../../domain/entities/batch_entity.dart';
import '../../domain/entities/batch_enrollment_entity.dart';
import '../../providers/batch_provider.dart';
import 'enrolled_student_tile.dart';

class BatchStudentList extends ConsumerStatefulWidget {
  const BatchStudentList({
    super.key,
    required this.batch,
    required this.onEnroll,
  });

  final BatchEntity batch;
  final VoidCallback onEnroll;

  @override
  ConsumerState<BatchStudentList> createState() => _BatchStudentListState();
}

class _BatchStudentListState extends ConsumerState<BatchStudentList> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(batchEnrollmentsProvider(widget.batch.id).notifier)
          .loadEnrollmentsForBatch(),
    );
  }

  Future<void> _remove(
    BatchEnrollmentEntity enrollment,
    String studentName,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.t('removeFromBatch')),
        content: Text(
          '${context.l10n.t('removeFromBatchConfirm')}\n\n$studentName',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.t('removeFromBatch')),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref
          .read(batchEnrollmentsProvider(widget.batch.id).notifier)
          .removeStudent(enrollment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('removedFromBatch'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchEnrollmentsProvider(widget.batch.id));
    if (state.isLoading && state.enrollments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (state.errorMessage != null && state.enrollments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(state.errorMessage!),
      );
    }
    if (state.enrollments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
        child: Column(
          children: [
            Icon(
              Icons.groups_2_outlined,
              size: 42,
              color: Theme.of(context).colorScheme.primary
                  .withValues(alpha: 0.55),
            ),
            const SizedBox(height: 8),
            Text(context.l10n.t('noStudentsEnrolled')),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: widget.onEnroll,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(context.l10n.t('enrollStudent')),
            ),
          ],
        ),
      );
    }
    final repo = ref.read(studentRepositoryProvider);
    return Column(
      children: state.enrollments.map((enrollment) {
        return FutureBuilder(
          future: repo.getStudentById(enrollment.studentId),
          builder: (context, snapshot) {
            final student = snapshot.data;
            if (student == null) return const SizedBox.shrink();
            return EnrolledStudentTile(
              student: student,
              joiningDate: enrollment.joiningDate,
              effectiveFee: enrollment.effectiveFee(
                widget.batch.monthlyFeeDefault,
              ),
              isCustomFee: enrollment.customFee > 0,
              onRemove: () => _remove(enrollment, student.fullName),
            );
          },
        );
      }).toList(),
    );
  }
}
