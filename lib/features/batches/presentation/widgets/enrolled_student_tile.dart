import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/presentation/widgets/student_ui_utils.dart';

class EnrolledStudentTile extends StatelessWidget {
  const EnrolledStudentTile({
    super.key,
    required this.student,
    required this.joiningDate,
    required this.effectiveFee,
    required this.isCustomFee,
    required this.onRemove,
  });

  final StudentEntity student;
  final DateTime joiningDate;
  final double effectiveFee;
  final bool isCustomFee;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: generateAvatarColor(student.fullName)
            .withValues(alpha: 0.14),
        backgroundImage: hasLocalPhoto(student.photoPath)
            ? FileImage(File(student.photoPath))
            : null,
        child: hasLocalPhoto(student.photoPath)
            ? null
            : Text(
                studentInitials(student.fullName),
                style: TextStyle(
                  color: generateAvatarColor(student.fullName),
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
      title: Text(
        student.fullName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${student.studentCode}  •  ${DateFormat('dd MMM yyyy').format(joiningDate)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: SizedBox(
        width: 132,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatFee(effectiveFee),
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (isCustomFee)
                  Text(
                    '(${context.l10n.t('customFee').toLowerCase()})',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
              ],
            ),
            IconButton(
              tooltip: context.l10n.t('removeFromBatch'),
              onPressed: onRemove,
              icon: const Icon(Icons.person_remove_outlined, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
