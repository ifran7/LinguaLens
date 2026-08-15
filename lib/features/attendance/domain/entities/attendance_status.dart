import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';

enum AttendanceStatus { present, absent, late, leave }

extension AttendanceStatusX on AttendanceStatus {
  String get value => name;

  static AttendanceStatus fromValue(String value) => switch (value) {
    'present' => AttendanceStatus.present,
    'absent' => AttendanceStatus.absent,
    'late' => AttendanceStatus.late,
    'leave' => AttendanceStatus.leave,
    _ => AttendanceStatus.present,
  };

  Color get color => switch (this) {
    AttendanceStatus.present => AppColors.success,
    AttendanceStatus.absent => AppColors.danger,
    AttendanceStatus.late => Colors.orange,
    AttendanceStatus.leave => Colors.blueGrey,
  };

  IconData get icon => switch (this) {
    AttendanceStatus.present => Icons.check_circle_rounded,
    AttendanceStatus.absent => Icons.cancel_rounded,
    AttendanceStatus.late => Icons.schedule_rounded,
    AttendanceStatus.leave => Icons.event_busy_rounded,
  };

  String localizedLabel(BuildContext context) => switch (this) {
    AttendanceStatus.present => context.l10n.t('present'),
    AttendanceStatus.absent => context.l10n.t('absent'),
    AttendanceStatus.late => context.l10n.t('late'),
    AttendanceStatus.leave => context.l10n.t('leave'),
  };
}
