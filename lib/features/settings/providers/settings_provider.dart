import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/local_storage_service.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsState {
  const SettingsState({
    required this.teacherName,
    required this.teacherPhone,
    required this.teacherPhotoPath,
    required this.autoBackupEnabled,
    required this.backupIntervalDays,
    required this.showFeesOnDashboard,
    required this.showAttendanceOnDashboard,
    required this.showLessonsOnDashboard,
    required this.showUpcomingLessons,
    required this.defaultMessageLanguage,
  });

  final String teacherName;
  final String teacherPhone;
  final String teacherPhotoPath;
  final bool autoBackupEnabled;
  final int backupIntervalDays;
  final bool showFeesOnDashboard;
  final bool showAttendanceOnDashboard;
  final bool showLessonsOnDashboard;
  final bool showUpcomingLessons;
  final String defaultMessageLanguage;

  SettingsState copyWith({
    String? teacherName,
    String? teacherPhone,
    String? teacherPhotoPath,
    bool? autoBackupEnabled,
    int? backupIntervalDays,
    bool? showFeesOnDashboard,
    bool? showAttendanceOnDashboard,
    bool? showLessonsOnDashboard,
    bool? showUpcomingLessons,
    String? defaultMessageLanguage,
  }) => SettingsState(
    teacherName: teacherName ?? this.teacherName,
    teacherPhone: teacherPhone ?? this.teacherPhone,
    teacherPhotoPath: teacherPhotoPath ?? this.teacherPhotoPath,
    autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
    backupIntervalDays: backupIntervalDays ?? this.backupIntervalDays,
    showFeesOnDashboard: showFeesOnDashboard ?? this.showFeesOnDashboard,
    showAttendanceOnDashboard:
        showAttendanceOnDashboard ?? this.showAttendanceOnDashboard,
    showLessonsOnDashboard:
        showLessonsOnDashboard ?? this.showLessonsOnDashboard,
    showUpcomingLessons: showUpcomingLessons ?? this.showUpcomingLessons,
    defaultMessageLanguage:
        defaultMessageLanguage ?? this.defaultMessageLanguage,
  );
}

class SettingsNotifier extends Notifier<SettingsState> {
  LocalStorageService get _storage => ref.read(storageProviderForSettings);

  @override
  SettingsState build() => SettingsState(
    teacherName: _storage.teacherName,
    teacherPhone: _storage.teacherPhone,
    teacherPhotoPath: _storage.teacherPhotoPath,
    autoBackupEnabled: _storage.autoBackupEnabled,
    backupIntervalDays: _storage.backupIntervalDays,
    showFeesOnDashboard: _storage.showFeesOnDashboard,
    showAttendanceOnDashboard: _storage.showAttendanceOnDashboard,
    showLessonsOnDashboard: _storage.showLessonsOnDashboard,
    showUpcomingLessons: _storage.showUpcomingLessons,
    defaultMessageLanguage: _storage.defaultMessageLanguage,
  );

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoPath,
  }) async {
    await _storage.setTeacherProfile(
      name: name,
      phone: phone,
      photoPath: photoPath,
    );
    state = state.copyWith(
      teacherName: name,
      teacherPhone: phone,
      teacherPhotoPath: photoPath,
    );
  }

  Future<void> setAutoBackup(bool value) async {
    await _storage.setAutoBackup(value);
    state = state.copyWith(autoBackupEnabled: value);
  }

  Future<void> setBackupInterval(int value) async {
    await _storage.setBackupIntervalDays(value);
    state = state.copyWith(backupIntervalDays: value);
  }

  Future<void> setDashboardVisibility({
    bool? fees,
    bool? attendance,
    bool? lessons,
    bool? upcoming,
  }) async {
    await _storage.setDashboardVisibility(
      fees: fees,
      attendance: attendance,
      lessons: lessons,
      upcoming: upcoming,
    );
    state = state.copyWith(
      showFeesOnDashboard: fees,
      showAttendanceOnDashboard: attendance,
      showLessonsOnDashboard: lessons,
      showUpcomingLessons: upcoming,
    );
  }

  Future<void> setDefaultMessageLanguage(String value) async {
    await _storage.setDefaultMessageLanguage(value);
    state = state.copyWith(defaultMessageLanguage: value);
  }
}

final storageProviderForSettings = Provider<LocalStorageService>(
  (_) => LocalStorageService.instance,
);
