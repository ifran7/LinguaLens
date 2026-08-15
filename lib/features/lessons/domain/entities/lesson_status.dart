import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

enum LessonStatus { planned, completed, skipped, postponed }

extension LessonStatusX on LessonStatus {
  String get value => name;

  static LessonStatus fromValue(String value) => LessonStatus.values.firstWhere(
    (item) => item.value == value,
    orElse: () => LessonStatus.planned,
  );

  Color get color => switch (this) {
    LessonStatus.planned => const Color(0xFF3B82F6),
    LessonStatus.completed => const Color(0xFF16A34A),
    LessonStatus.skipped => const Color(0xFFDC2626),
    LessonStatus.postponed => const Color(0xFFF59E0B),
  };

  IconData get icon => switch (this) {
    LessonStatus.planned => Icons.event_rounded,
    LessonStatus.completed => Icons.check_circle_rounded,
    LessonStatus.skipped => Icons.cancel_rounded,
    LessonStatus.postponed => Icons.update_rounded,
  };

  String localizedLabel(BuildContext context) => context.l10n.t(value);
}
