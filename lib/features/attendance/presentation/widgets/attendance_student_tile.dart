import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../students/presentation/widgets/student_ui_utils.dart';
import '../../domain/entities/attendance_session_student.dart';
import '../../domain/entities/attendance_status.dart';
import 'attendance_note_sheet.dart';
import 'attendance_status_selector.dart';

class AttendanceStudentTile extends StatelessWidget {
  const AttendanceStudentTile({
    super.key,
    required this.item,
    required this.onStatusChanged,
    required this.onClearStatus,
    required this.onNoteChanged,
    this.enabled = true,
  });

  final AttendanceSessionStudent item;
  final ValueChanged<AttendanceStatus> onStatusChanged;
  final VoidCallback onClearStatus;
  final ValueChanged<String> onNoteChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final status = item.effectiveStatus;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
        child: Column(
          children: [
            Row(
              children: [
                _Avatar(
                  studentName: item.student.fullName,
                  photoPath: item.student.photoPath,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.student.fullName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.student.studentCode,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (item.note.trim().isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.notes_rounded,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.note,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.t('attendanceNote'),
                  onPressed: enabled
                      ? () async {
                          final note = await showAttendanceNoteSheet(
                            context,
                            initialNote: item.note,
                          );
                          if (note != null) onNoteChanged(note);
                        }
                      : null,
                  icon: Icon(
                    item.note.trim().isEmpty
                        ? Icons.note_add_outlined
                        : Icons.sticky_note_2_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AttendanceStatusSelector(
              selected: status,
              enabled: enabled,
              onStatusSelected: onStatusChanged,
              onClear: onClearStatus,
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.studentName, required this.photoPath});

  final String studentName;
  final String photoPath;

  @override
  Widget build(BuildContext context) {
    final photoExists = hasLocalPhoto(photoPath);
    return CircleAvatar(
      radius: 24,
      backgroundColor: generateAvatarColor(studentName),
      backgroundImage: photoExists ? FileImage(File(photoPath)) : null,
      child: photoExists
          ? null
          : Text(
              studentInitials(studentName),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
