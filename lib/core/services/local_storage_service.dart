import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();

  static final LocalStorageService instance = LocalStorageService._();
  late SharedPreferences _preferences;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _preferences = await SharedPreferences.getInstance();
    _initialized = true;
  }

  bool get onboardingCompleted =>
      _preferences.getBool('is_onboarding_completed') ?? false;
  String get languageCode =>
      _preferences.getString('selected_language_code') ?? 'en';
  String get themeMode =>
      _preferences.getString('selected_theme_mode') ?? 'light';
  DateTime? get lastBackupTime {
    final value = _preferences.getString('last_backup_time');
    return value == null ? null : DateTime.tryParse(value);
  }

  String get teacherName => _preferences.getString('teacher_name') ?? '';
  String get teacherPhone => _preferences.getString('teacher_phone') ?? '';
  String get teacherPhotoPath =>
      _preferences.getString('teacher_photo_path') ?? '';
  bool get autoBackupEnabled =>
      _preferences.getBool('auto_backup_enabled') ?? false;
  int get backupIntervalDays =>
      _preferences.getInt('backup_interval_days') ?? 7;
  bool get showFeesOnDashboard =>
      _preferences.getBool('show_fees_dashboard') ?? true;
  bool get showAttendanceOnDashboard =>
      _preferences.getBool('show_attendance_dashboard') ?? true;
  bool get showLessonsOnDashboard =>
      _preferences.getBool('show_lessons_dashboard') ?? true;
  bool get showUpcomingLessons =>
      _preferences.getBool('show_upcoming_lessons') ?? true;
  String get defaultMessageLanguage =>
      _preferences.getString('default_message_language') ?? 'en';

  Future<void> setTeacherProfile({
    String? name,
    String? phone,
    String? photoPath,
  }) async {
    if (name != null) {
      await _preferences.setString('teacher_name', name);
    }
    if (phone != null) {
      await _preferences.setString('teacher_phone', phone);
    }
    if (photoPath != null) {
      await _preferences.setString('teacher_photo_path', photoPath);
    }
  }

  Future<void> setAutoBackup(bool value) =>
      _preferences.setBool('auto_backup_enabled', value);
  Future<void> setBackupIntervalDays(int value) =>
      _preferences.setInt('backup_interval_days', value);
  Future<void> setDashboardVisibility({
    bool? fees,
    bool? attendance,
    bool? lessons,
    bool? upcoming,
  }) async {
    if (fees != null) {
      await _preferences.setBool('show_fees_dashboard', fees);
    }
    if (attendance != null) {
      await _preferences.setBool('show_attendance_dashboard', attendance);
    }
    if (lessons != null) {
      await _preferences.setBool('show_lessons_dashboard', lessons);
    }
    if (upcoming != null) {
      await _preferences.setBool('show_upcoming_lessons', upcoming);
    }
  }

  Future<void> setDefaultMessageLanguage(String value) =>
      _preferences.setString('default_message_language', value);

  Future<void> markBackupCreated() => _preferences.setString(
    'last_backup_time',
    DateTime.now().toIso8601String(),
  );

  Future<void> restoreSettings(Map<String, dynamic> settings) async {
    final language = settings['languageCode'];
    final theme = settings['themeMode'];
    if (language is String) {
      await setLanguageCode(language);
    }
    if (theme is String) {
      await setThemeMode(theme);
    }
    if (settings['isOnboardingCompleted'] is bool) {
      await setOnboardingCompleted(settings['isOnboardingCompleted'] as bool);
    }
    if (settings['teacherName'] is String ||
        settings['teacherPhone'] is String ||
        settings['teacherPhotoPath'] is String) {
      await setTeacherProfile(
        name: settings['teacherName'] as String?,
        phone: settings['teacherPhone'] as String?,
        photoPath: settings['teacherPhotoPath'] as String?,
      );
    }
    if (settings['autoBackupEnabled'] is bool) {
      await setAutoBackup(settings['autoBackupEnabled'] as bool);
    }
    if (settings['backupIntervalDays'] is num) {
      await setBackupIntervalDays(
        (settings['backupIntervalDays'] as num).toInt(),
      );
    }
    await setDashboardVisibility(
      fees: settings['showFeesOnDashboard'] as bool?,
      attendance: settings['showAttendanceOnDashboard'] as bool?,
      lessons: settings['showLessonsOnDashboard'] as bool?,
      upcoming: settings['showUpcomingLessons'] as bool?,
    );
    if (settings['defaultMessageLanguage'] is String) {
      await setDefaultMessageLanguage(
        settings['defaultMessageLanguage'] as String,
      );
    }
  }

  Future<void> setOnboardingCompleted(bool value) =>
      _preferences.setBool('is_onboarding_completed', value);

  Future<void> setLanguageCode(String value) =>
      _preferences.setString('selected_language_code', value);

  Future<void> setThemeMode(String value) =>
      _preferences.setString('selected_theme_mode', value);

  Future<bool> exportBackup() async {
    final payload = {
      'schemaVersion': 1,
      'appVersion': '0.1.0',
      'backupCreatedAt': DateTime.now().toIso8601String(),
      'students': <Map<String, dynamic>>[],
      'batches': <Map<String, dynamic>>[],
      'attendance': <Map<String, dynamic>>[],
      'fees': <Map<String, dynamic>>[],
      'lessons': <Map<String, dynamic>>[],
      'settings': {
        'languageCode': languageCode,
        'themeMode': themeMode,
        'isOnboardingCompleted': onboardingCompleted,
      },
    };

    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(payload)),
    );
    final path = await FilePicker.saveFile(
      fileName:
          'lingualens-backup-${DateTime.now().millisecondsSinceEpoch}.json',
      bytes: bytes,
    );
    if (path == null) return false;
    await _preferences.setString(
      'last_backup_time',
      DateTime.now().toIso8601String(),
    );
    return true;
  }

  Future<bool> restoreBackup() async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null) return false;

    final content = utf8.decode(await result.readAsBytes());
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic> || decoded['schemaVersion'] != 1) {
      throw const FormatException('Unsupported backup schema');
    }

    final settings = decoded['settings'];
    if (settings is Map<String, dynamic>) {
      final restoredLanguage = settings['languageCode'];
      final restoredTheme = settings['themeMode'];
      if (restoredLanguage is String) await setLanguageCode(restoredLanguage);
      if (restoredTheme is String) await setThemeMode(restoredTheme);
    }
    return true;
  }
}
