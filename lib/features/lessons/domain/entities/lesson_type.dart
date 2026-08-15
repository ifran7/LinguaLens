import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

enum LessonType { daily, weekly, monthly }

extension LessonTypeX on LessonType {
  String get value => name;

  static LessonType fromValue(String value) => LessonType.values.firstWhere(
    (item) => item.value == value,
    orElse: () => LessonType.daily,
  );

  IconData get icon => switch (this) {
    LessonType.daily => Icons.today_rounded,
    LessonType.weekly => Icons.date_range_rounded,
    LessonType.monthly => Icons.calendar_month_rounded,
  };

  String localizedLabel(BuildContext context) => context.l10n.t(value);
}
