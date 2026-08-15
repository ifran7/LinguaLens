import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/future_services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/student_entity.dart';
import '../../providers/student_provider.dart';
import '../widgets/student_ui_utils.dart';

class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({super.key, required this.studentId});
  final String studentId;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    StudentEntity student,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.t('deleteStudent')),
        content: Text(context.l10n.t('deleteStudentConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.t('deleteStudent')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(studentsListProvider.notifier).deleteStudent(student.id);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.t('studentDeleted'))));
      context.pop();
    }
  }

  Future<void> _toggleArchive(
    BuildContext context,
    WidgetRef ref,
    StudentEntity student,
  ) async {
    if (student.isActive) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.t('archiveStudent')),
          content: Text(context.l10n.t('archiveStudentConfirm')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.t('archiveStudent')),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await ref.read(studentsListProvider.notifier).archiveStudent(student.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('studentArchived'))),
        );
      }
    } else {
      await ref.read(studentsListProvider.notifier).restoreStudent(student.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('studentRestored'))),
        );
      }
    }
    ref.invalidate(studentDetailProvider(student.id));
  }

  Future<void> _whatsapp(BuildContext context, StudentEntity student) async {
    final ok = await MessagingService().launchWhatsApp(
      formatPhoneForWhatsApp(student.parentPhone),
      'Hello ${student.parentName.isEmpty ? '' : student.parentName}, this is a message from your teacher.',
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  Future<void> _sms(BuildContext context, StudentEntity student) async {
    final ok = await MessagingService().launchSms(
      student.parentPhone,
      'Hello ${student.parentName.isEmpty ? '' : student.parentName}, this is a message from your teacher.',
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open SMS')));
    }
  }

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
      data: (student) {
        if (student == null) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: Center(child: Text(context.l10n.t('studentNotFound'))),
          );
        }
        final color = generateAvatarColor(student.fullName);
        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: Text(context.l10n.t('studentDetails')),
            actions: [
              IconButton(
                onPressed: () async {
                  await context.push('/students/edit/${student.id}');
                  ref.invalidate(studentDetailProvider(student.id));
                },
                icon: const Icon(Icons.edit_outlined),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              AppCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: color.withValues(alpha: 0.15),
                      backgroundImage: hasLocalPhoto(student.photoPath)
                          ? FileImage(File(student.photoPath))
                          : null,
                      child: hasLocalPhoto(student.photoPath)
                          ? null
                          : Text(
                              studentInitials(student.fullName),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontSize: 28,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      student.fullName,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          student.studentCode,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.muted),
                        ),
                        const SizedBox(width: 12),
                        _DetailStatus(isActive: student.isActive),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _InfoSection(
                title: context.l10n.t('fullName'),
                children: [
                  _InfoRow(
                    icon: Icons.school_outlined,
                    label: context.l10n.t('className'),
                    value: student.className,
                  ),
                  _InfoRow(
                    icon: Icons.apartment_outlined,
                    label: context.l10n.t('schoolName'),
                    value: student.schoolName,
                  ),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: context.l10n.t('phone'),
                    value: student.phone,
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: context.l10n.t('address'),
                    value: student.address,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoSection(
                title: context.l10n.t('parentName'),
                children: [
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: context.l10n.t('parentName'),
                    value: student.parentName,
                  ),
                  _InfoRow(
                    icon: Icons.phone_in_talk_outlined,
                    label: context.l10n.t('parentPhone'),
                    value: student.parentPhone,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: student.parentPhone.isEmpty
                          ? null
                          : () => _whatsapp(context, student),
                      icon: const Icon(Icons.chat_rounded),
                      label: Text(context.l10n.t('whatsappParent')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: student.parentPhone.isEmpty
                          ? null
                          : () => _sms(context, student),
                      icon: const Icon(Icons.sms_outlined),
                      label: Text(context.l10n.t('smsParent')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoSection(
                title: context.l10n.t('batchesEnrolled'),
                children: [
                  _PlaceholderRow(
                    icon: Icons.groups_outlined,
                    label: context.l10n.t('noBatchesYet'),
                  ),
                  _PlaceholderRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: context.l10n.t('noFeeRecords'),
                  ),
                  _PlaceholderRow(
                    icon: Icons.fact_check_outlined,
                    label: context.l10n.t('noAttendanceRecords'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _toggleArchive(context, ref, student),
                icon: Icon(
                  student.isActive
                      ? Icons.archive_outlined
                      : Icons.unarchive_outlined,
                ),
                label: Text(
                  student.isActive
                      ? context.l10n.t('archiveStudent')
                      : context.l10n.t('restoreStudent'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => _delete(context, ref, student),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                label: Text(
                  context.l10n.t('deleteStudent'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailStatus extends StatelessWidget {
  const _DetailStatus({required this.isActive});
  final bool isActive;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: (isActive ? AppColors.success : AppColors.muted).withValues(
        alpha: 0.12,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      isActive ? context.l10n.t('active') : context.l10n.t('archived'),
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: isActive ? AppColors.success : AppColors.muted),
    ),
  );
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: AppColors.muted),
        const SizedBox(width: 10),
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.muted),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}

class _PlaceholderRow extends StatelessWidget {
  const _PlaceholderRow({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 19, color: AppColors.muted),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.muted),
        ),
      ],
    ),
  );
}
