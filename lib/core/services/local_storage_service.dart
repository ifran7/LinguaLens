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
