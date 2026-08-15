import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';

import '../../features/attendance/data/models/attendance_model.dart';
import '../../features/batches/data/models/batch_enrollment_model.dart';
import '../../features/batches/data/models/batch_model.dart';
import '../../features/fees/data/models/fee_record_model.dart';
import '../../features/fees/data/models/payment_model.dart';
import '../../features/lessons/data/models/lesson_plan_model.dart';
import '../../features/lessons/data/models/syllabus_topic_model.dart';
import '../../features/messages/data/models/message_log_model.dart';
import '../../features/messages/data/models/message_template_model.dart';
import '../../features/students/data/models/student_model.dart';
import '../constants/hive_boxes.dart';
import '../models/app_metadata_models.dart';
import 'local_storage_service.dart';

class BackupSummary {
  const BackupSummary({required this.createdAt, required this.counts});

  final DateTime createdAt;
  final Map<String, int> counts;

  int get total => counts.values.fold(0, (sum, item) => sum + item);
}

class BackupService {
  BackupService._();

  static final instance = BackupService._();
  static const schemaVersion = 2;

  Map<String, dynamic> buildPayload() {
    final storage = LocalStorageService.instance;
    final metadataBox = Hive.box<dynamic>(HiveBoxes.meta);
    return {
      'schemaVersion': schemaVersion,
      'appVersion': '1.0.0+1',
      'backupCreatedAt': DateTime.now().toIso8601String(),
      'students': Hive.box<StudentModel>(HiveBoxes.students).values
          .map((e) => e.toJson())
          .toList(),
      'batches': Hive.box<BatchModel>(HiveBoxes.batches).values
          .map((e) => e.toJson())
          .toList(),
      'enrollments': Hive.box<BatchEnrollmentModel>(HiveBoxes.batchEnrollments)
          .values
          .map((e) => e.toJson())
          .toList(),
      'attendance': Hive.box<AttendanceModel>(HiveBoxes.attendance).values
          .map((e) => e.toJson())
          .toList(),
      'feeRecords': Hive.box<FeeRecordModel>(HiveBoxes.fees).values
          .map((e) => e.toJson())
          .toList(),
      'payments': Hive.box<PaymentModel>(HiveBoxes.payments).values
          .map((e) => e.toJson())
          .toList(),
      'lessons': Hive.box<LessonPlanModel>(HiveBoxes.lessons).values
          .map((e) => e.toJson())
          .toList(),
      'syllabusTopics': Hive.box<SyllabusTopicModel>(HiveBoxes.syllabusTopics)
          .values
          .map((e) => e.toJson())
          .toList(),
      'messageTemplates': Hive.box<MessageTemplateModel>(
        HiveBoxes.messageTemplates,
      ).values.map((e) => e.toJson()).toList(),
      'messageLogs': Hive.box<MessageLogModel>(HiveBoxes.messageLogs).values
          .map((e) => e.toJson())
          .toList(),
      'backupMeta': Hive.box<BackupMetaModel>(HiveBoxes.backupMeta).values
          .map((e) => e.toJson())
          .toList(),
      'appSettings': Hive.box<AppSettingsModel>(HiveBoxes.settings).values
          .map((e) => e.toJson())
          .toList(),
      'meta': {
        for (final entry in metadataBox.toMap().entries)
          entry.key.toString(): entry.value,
      },
      'settings': {
        'languageCode': storage.languageCode,
        'themeMode': storage.themeMode,
        'isOnboardingCompleted': storage.onboardingCompleted,
        'lastBackupTime': storage.lastBackupTime?.toIso8601String(),
        'remindToBackup': storage.remindToBackup,
        'teacherName': storage.teacherName,
        'teacherPhone': storage.teacherPhone,
        'teacherPhotoPath': storage.teacherPhotoPath,
        'autoBackupEnabled': storage.autoBackupEnabled,
        'backupIntervalDays': storage.backupIntervalDays,
        'showFeesOnDashboard': storage.showFeesOnDashboard,
        'showAttendanceOnDashboard': storage.showAttendanceOnDashboard,
        'showLessonsOnDashboard': storage.showLessonsOnDashboard,
        'showUpcomingLessons': storage.showUpcomingLessons,
        'defaultMessageLanguage': storage.defaultMessageLanguage,
      },
    };
  }

  Future<bool> exportBackup() async {
    final payload = buildPayload();
    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(payload)),
    );
    final path = await FilePicker.saveFile(
      fileName:
          'lingualens-backup-${DateTime.now().millisecondsSinceEpoch}.json',
      bytes: bytes,
    );
    if (path == null) return false;
    await LocalStorageService.instance.markBackupCreated();
    await Hive.box<BackupMetaModel>(HiveBoxes.backupMeta).put(
      'latest',
      BackupMetaModel(
        id: 'latest',
        createdAt: DateTime.now(),
        fileName: path.pathSegments.isEmpty
            ? path.toString()
            : path.pathSegments.last,
        recordCount: _recordCount(payload),
        schemaVersion: schemaVersion,
      ),
    );
    return true;
  }

  Future<BackupSummary?> restoreFromPicker() async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null) return null;
    final content = utf8.decode(await result.readAsBytes());
    return restoreFromContent(content);
  }

  Future<BackupSummary> restoreFromContent(String content) async {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup file');
    }
    final schema = (decoded['schemaVersion'] as num?)?.toInt();
    if (schema == null || schema < 1 || schema > schemaVersion) {
      throw const FormatException('Unsupported backup schema');
    }
    for (final key in const [
      'students',
      'batches',
      'enrollments',
      'attendance',
      'feeRecords',
      'payments',
      'lessons',
      'syllabusTopics',
      'messageTemplates',
      'messageLogs',
      'backupMeta',
      'appSettings',
    ]) {
      if (decoded[key] != null && decoded[key] is! List) {
        throw FormatException('Invalid $key data');
      }
    }

    final students = _maps(decoded['students']);
    final batches = _maps(decoded['batches']);
    final enrollments = _maps(decoded['enrollments']);
    final attendance = _maps(decoded['attendance']);
    final fees = _maps(decoded['feeRecords'] ?? decoded['fees']);
    final payments = _maps(decoded['payments']);
    final lessons = _maps(decoded['lessons']);
    final topics = _maps(decoded['syllabusTopics']);
    final templates = _maps(decoded['messageTemplates']);
    final logs = _maps(decoded['messageLogs']);
    final backupMeta = _maps(decoded['backupMeta']);
    final appSettings = _maps(decoded['appSettings']);

    await Hive.box<StudentModel>(HiveBoxes.students).clear();
    await Hive.box<BatchModel>(HiveBoxes.batches).clear();
    await Hive.box<BatchEnrollmentModel>(HiveBoxes.batchEnrollments).clear();
    await Hive.box<AttendanceModel>(HiveBoxes.attendance).clear();
    await Hive.box<FeeRecordModel>(HiveBoxes.fees).clear();
    await Hive.box<PaymentModel>(HiveBoxes.payments).clear();
    await Hive.box<LessonPlanModel>(HiveBoxes.lessons).clear();
    await Hive.box<SyllabusTopicModel>(HiveBoxes.syllabusTopics).clear();
    await Hive.box<MessageTemplateModel>(HiveBoxes.messageTemplates).clear();
    await Hive.box<MessageLogModel>(HiveBoxes.messageLogs).clear();
    await Hive.box<BackupMetaModel>(HiveBoxes.backupMeta).clear();
    await Hive.box<AppSettingsModel>(HiveBoxes.settings).clear();
    await Hive.box<dynamic>(HiveBoxes.meta).clear();

    await Hive.box<StudentModel>(HiveBoxes.students).putAll({
      for (final item in students)
        item['id'] as String: StudentModel.fromJson(item),
    });
    await Hive.box<BatchModel>(HiveBoxes.batches).putAll({
      for (final item in batches)
        item['id'] as String: BatchModel.fromJson(item),
    });
    await Hive.box<BatchEnrollmentModel>(HiveBoxes.batchEnrollments).putAll({
      for (final item in enrollments)
        item['id'] as String: BatchEnrollmentModel.fromJson(item),
    });
    await Hive.box<AttendanceModel>(HiveBoxes.attendance).putAll({
      for (final item in attendance)
        item['id'] as String: AttendanceModel.fromJson(item),
    });
    await Hive.box<FeeRecordModel>(HiveBoxes.fees).putAll({
      for (final item in fees)
        item['id'] as String: FeeRecordModel.fromJson(item),
    });
    await Hive.box<PaymentModel>(HiveBoxes.payments).putAll({
      for (final item in payments)
        item['id'] as String: PaymentModel.fromJson(item),
    });
    await Hive.box<LessonPlanModel>(HiveBoxes.lessons).putAll({
      for (final item in lessons)
        item['id'] as String: LessonPlanModel.fromJson(item),
    });
    await Hive.box<SyllabusTopicModel>(HiveBoxes.syllabusTopics).putAll({
      for (final item in topics)
        item['id'] as String: SyllabusTopicModel.fromJson(item),
    });
    await Hive.box<MessageTemplateModel>(HiveBoxes.messageTemplates).putAll({
      for (final item in templates)
        item['id'] as String: MessageTemplateModel.fromJson(item),
    });
    await Hive.box<MessageLogModel>(HiveBoxes.messageLogs).putAll({
      for (final item in logs)
        item['id'] as String: MessageLogModel.fromJson(item),
    });
    await Hive.box<BackupMetaModel>(HiveBoxes.backupMeta).putAll({
      for (final item in backupMeta)
        item['id'] as String: BackupMetaModel.fromJson(item),
    });
    if (appSettings.isNotEmpty) {
      await Hive.box<AppSettingsModel>(HiveBoxes.settings).putAll({
        for (var index = 0; index < appSettings.length; index++)
          'settings-$index': AppSettingsModel.fromJson(appSettings[index]),
      });
    }
    final meta = decoded['meta'];
    if (meta is Map) {
      for (final entry in meta.entries) {
        await Hive.box<dynamic>(HiveBoxes.meta).put(entry.key, entry.value);
      }
    }

    final settings = decoded['settings'];
    if (settings is Map<String, dynamic>) {
      await LocalStorageService.instance.restoreSettings(settings);
    }
    await LocalStorageService.instance.markBackupCreated();
    final createdAt =
        DateTime.tryParse(decoded['backupCreatedAt'] as String? ?? '') ??
        DateTime.now();
    return BackupSummary(
      createdAt: createdAt,
      counts: {
        'students': students.length,
        'batches': batches.length,
        'enrollments': enrollments.length,
        'attendance': attendance.length,
        'feeRecords': fees.length,
        'payments': payments.length,
        'lessons': lessons.length,
        'syllabusTopics': topics.length,
        'messageTemplates': templates.length,
        'messageLogs': logs.length,
        'backupMeta': backupMeta.length,
        'appSettings': appSettings.length,
      },
    );
  }

  int _recordCount(Map<String, dynamic> payload) =>
      const [
        'students',
        'batches',
        'enrollments',
        'attendance',
        'feeRecords',
        'payments',
        'lessons',
        'syllabusTopics',
        'messageTemplates',
        'messageLogs',
      ].fold<int>(
        0,
        (total, key) =>
            total + (payload[key] is List ? (payload[key] as List).length : 0),
      );

  List<Map<String, dynamic>> _maps(Object? value) => value is List
      ? value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
      : <Map<String, dynamic>>[];
}
