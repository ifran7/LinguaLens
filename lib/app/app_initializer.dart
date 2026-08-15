import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/hive_boxes.dart';
import '../core/models/app_metadata_models.dart';
import '../core/services/local_storage_service.dart';
import '../features/attendance/data/models/attendance_model.dart';
import '../features/batches/data/models/batch_enrollment_model.dart';
import '../features/batches/data/models/batch_model.dart';
import '../features/fees/data/models/fee_record_model.dart';
import '../features/fees/data/models/payment_model.dart';
import '../features/lessons/data/models/lesson_plan_model.dart';
import '../features/lessons/data/models/syllabus_topic_model.dart';
import '../features/messages/data/models/message_log_model.dart';
import '../features/messages/data/models/message_template_model.dart';
import '../features/messages/services/template_seeder.dart';
import '../features/students/data/models/student_model.dart';

class AppInitializer {
  AppInitializer._();

  static const appVersion = '1.0.0+1';

  static Future<void> initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _runStep('preferences', LocalStorageService.instance.init);
    await _runStep('hive initialization', Hive.initFlutter);
    _registerAdapters();
    await _runStep('box opening', _openBoxes);
    await _runStep('settings initialization', _initializeSettings);
    await _runStep('template seeding', TemplateSeeder.seedIfNeeded);
    await _runStep('first launch metadata', _recordFirstLaunch);
    await _runStep('app version metadata', _storeAppVersion);
  }

  static Future<void> _runStep(
    String name,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      throw StateError('$name failed: $error');
    }
  }

  static void _registerAdapters() {
    final adapters = <TypeAdapter<dynamic>>[
      StudentModelAdapter(),
      BatchModelAdapter(),
      BatchEnrollmentModelAdapter(),
      AttendanceModelAdapter(),
      FeeRecordModelAdapter(),
      PaymentModelAdapter(),
      LessonPlanModelAdapter(),
      SyllabusTopicModelAdapter(),
      MessageTemplateModelAdapter(),
      MessageLogModelAdapter(),
      BackupMetaModelAdapter(),
      AppSettingsModelAdapter(),
    ];
    for (final adapter in adapters) {
      if (!Hive.isAdapterRegistered(adapter.typeId)) {
        Hive.registerAdapter(adapter);
      }
    }
  }

  static Future<void> _openBoxes() async {
    await _runStep(
      'students box',
      () => _open<StudentModel>(HiveBoxes.students),
    );
    await _runStep('batches box', () => _open<BatchModel>(HiveBoxes.batches));
    await _runStep(
      'enrollments box',
      () => _open<BatchEnrollmentModel>(HiveBoxes.batchEnrollments),
    );
    await _runStep(
      'attendance box',
      () => _open<AttendanceModel>(HiveBoxes.attendance),
    );
    await _runStep('fees box', () => _open<FeeRecordModel>(HiveBoxes.fees));
    await _runStep(
      'payments box',
      () => _open<PaymentModel>(HiveBoxes.payments),
    );
    await _runStep(
      'lessons box',
      () => _open<LessonPlanModel>(HiveBoxes.lessons),
    );
    await _runStep(
      'syllabus topics box',
      () => _open<SyllabusTopicModel>(HiveBoxes.syllabusTopics),
    );
    await _runStep(
      'message templates box',
      () => _open<MessageTemplateModel>(
        HiveBoxes.messageTemplates,
        recover: true,
      ),
    );
    await _runStep(
      'message logs box',
      () => _open<MessageLogModel>(HiveBoxes.messageLogs, recover: true),
    );
    await _runStep(
      'backup metadata box',
      () => _open<BackupMetaModel>(HiveBoxes.backupMeta, recover: true),
    );
    await _runStep(
      'settings box',
      () => _open<AppSettingsModel>(HiveBoxes.settings, recover: true),
    );
    await _runStep('metadata box', () => _open<dynamic>(HiveBoxes.meta));
    await _runStep('metadata validation', _validateMetadataBoxes);
  }

  static Future<void> _open<T>(String name, {bool recover = false}) async {
    if (Hive.isBoxOpen(name)) return;
    try {
      await Hive.openBox<T>(name);
    } catch (_) {
      if (!recover) rethrow;
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).close();
      }
      await Hive.deleteBoxFromDisk(name);
      await Hive.openBox<T>(name);
    }
  }

  static Future<void> _validateMetadataBoxes() async {
    final settings = Hive.box<AppSettingsModel>(HiveBoxes.settings);
    final backupMeta = Hive.box<BackupMetaModel>(HiveBoxes.backupMeta);

    try {
      settings.values.toList(growable: false);
    } catch (_) {
      await _resetBox<AppSettingsModel>(HiveBoxes.settings);
    }

    try {
      backupMeta.values.toList(growable: false);
    } catch (_) {
      await _resetBox<BackupMetaModel>(HiveBoxes.backupMeta);
    }
  }

  static Future<void> _resetBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      await Hive.box<T>(name).close();
    }
    await Hive.deleteBoxFromDisk(name);
    await Hive.openBox<T>(name);
  }

  static Future<void> _initializeSettings() async {
    final box = Hive.box<AppSettingsModel>(HiveBoxes.settings);
    if (box.isNotEmpty) return;
    final storage = LocalStorageService.instance;
    await box.add(
      AppSettingsModel(
        languageCode: storage.languageCode,
        themeMode: storage.themeMode,
        isOnboardingCompleted: storage.onboardingCompleted,
        lastBackupTime: storage.lastBackupTime,
        remindToBackup: true,
        teacherName: storage.teacherName,
        teacherPhotoPath: storage.teacherPhotoPath,
        teacherPhone: storage.teacherPhone,
        showAttendanceOnDashboard: storage.showAttendanceOnDashboard,
        showFeesOnDashboard: storage.showFeesOnDashboard,
        showLessonsOnDashboard: storage.showLessonsOnDashboard,
        appVersion: appVersion,
      ),
    );
  }

  static Future<void> _recordFirstLaunch() async {
    final meta = Hive.box<dynamic>(HiveBoxes.meta);
    if (!meta.containsKey('firstLaunchDate')) {
      await meta.put('firstLaunchDate', DateTime.now().toIso8601String());
    }
  }

  static Future<void> _storeAppVersion() async {
    final meta = Hive.box<dynamic>(HiveBoxes.meta);
    await meta.put('appVersion', appVersion);
    final settings = Hive.box<AppSettingsModel>(HiveBoxes.settings);
    final current = settings.getAt(0);
    if (current != null && current.appVersion != appVersion) {
      current.appVersion = appVersion;
      await current.save();
    }
  }

  static bool get isFirstLaunch {
    final settings = Hive.box<AppSettingsModel>(HiveBoxes.settings);
    final value = settings.getAt(0);
    return value == null || !value.isOnboardingCompleted;
  }
}
