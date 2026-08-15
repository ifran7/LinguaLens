import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

Future<String?> showAttendanceNoteSheet(
  BuildContext context, {
  required String initialNote,
}) async {
  final controller = TextEditingController(text: initialNote);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.t('attendanceNote'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  maxLength: 200,
                  maxLines: 4,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: context.l10n.t('attendanceNote'),
                    alignLabelWithHint: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (controller.text.trim().isNotEmpty)
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(''),
                        child: Text(context.l10n.t('clearNote')),
                      ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(context.l10n.t('cancel')),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(controller.text.trim()),
                      child: Text(context.l10n.t('saveNote')),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
