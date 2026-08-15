import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/localization/app_localizations.dart';

class StudentAvatarPicker extends StatefulWidget {
  const StudentAvatarPicker({
    super.key,
    required this.studentId,
    required this.currentPath,
    required this.onChanged,
  });

  final String studentId;
  final String currentPath;
  final ValueChanged<String?> onChanged;

  @override
  State<StudentAvatarPicker> createState() => _StudentAvatarPickerState();
}

class _StudentAvatarPickerState extends State<StudentAvatarPicker> {
  final _picker = ImagePicker();
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => _busy = true);
    try {
      final image = await _picker.pickImage(
        source: source,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 82,
      );
      if (image == null) return;
      final directory = await getApplicationDocumentsDirectory();
      final photos = Directory('${directory.path}/students/photos');
      await photos.create(recursive: true);
      final destination = File('${photos.path}/${widget.studentId}.jpg');
      await File(image.path).copy(destination.path);
      if (mounted) {
        widget.onChanged(destination.path);
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('photoPermission'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.t('studentDetails'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(context.l10n.t('takePhoto')),
                onTap: () => _pick(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(context.l10n.t('chooseFromGallery')),
                onTap: () => _pick(ImageSource.gallery),
              ),
              if (widget.currentPath.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  title: Text(context.l10n.t('removePhoto')),
                  onTap: () {
                    widget.onChanged(null);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<String?> showStudentAvatarPicker(
  BuildContext context, {
  required String studentId,
  required String currentPath,
}) async {
  String? result;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: false,
    builder: (context) => StudentAvatarPicker(
      studentId: studentId,
      currentPath: currentPath,
      onChanged: (path) => result = path,
    ),
  );
  return result;
}
