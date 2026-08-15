import 'package:hive/hive.dart';

@HiveType(typeId: 11)
class BackupMetaModel extends HiveObject {
  BackupMetaModel({
    required this.id,
    required this.createdAt,
    required this.fileName,
    required this.recordCount,
    this.schemaVersion = 2,
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  DateTime createdAt;
  @HiveField(2)
  String fileName;
  @HiveField(3)
  int recordCount;
  @HiveField(4)
  int schemaVersion;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'fileName': fileName,
    'recordCount': recordCount,
    'schemaVersion': schemaVersion,
  };

  factory BackupMetaModel.fromJson(Map<String, dynamic> json) =>
      BackupMetaModel(
        id: json['id'] as String? ?? 'latest',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        fileName: json['fileName'] as String? ?? '',
        recordCount: (json['recordCount'] as num?)?.toInt() ?? 0,
        schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 2,
      );
}

class BackupMetaModelAdapter extends TypeAdapter<BackupMetaModel> {
  @override
  final int typeId = 11;

  @override
  BackupMetaModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    final id = fields[0] is String ? fields[0] as String : 'latest';
    final createdAt = fields[1] is DateTime
        ? fields[1] as DateTime
        : DateTime.now();
    final fileName = fields[2] is String ? fields[2] as String : '';
    final recordCount = fields[3] is num ? (fields[3] as num).toInt() : 0;
    final schemaVersion = fields[4] is num ? (fields[4] as num).toInt() : 2;
    return BackupMetaModel(
      id: id,
      createdAt: createdAt,
      fileName: fileName,
      recordCount: recordCount,
      schemaVersion: schemaVersion,
    );
  }

  @override
  void write(BinaryWriter writer, BackupMetaModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.recordCount)
      ..writeByte(4)
      ..write(obj.schemaVersion);
  }
}

@HiveType(typeId: 12)
class AppSettingsModel extends HiveObject {
  AppSettingsModel({
    this.languageCode = 'en',
    this.themeMode = 'light',
    this.isOnboardingCompleted = false,
    this.isPremium = false,
    this.lastBackupTime,
    this.remindToBackup = true,
    this.teacherName = '',
    this.teacherPhotoPath = '',
    this.teacherPhone = '',
    this.firstDayOfWeek = 6,
    this.showAttendanceOnDashboard = true,
    this.showFeesOnDashboard = true,
    this.showLessonsOnDashboard = true,
    this.currencySymbol = '৳',
    this.appVersion = '',
    DateTime? firstLaunchDate,
  }) : firstLaunchDate = firstLaunchDate ?? DateTime.now();

  @HiveField(0)
  String languageCode;
  @HiveField(1)
  String themeMode;
  @HiveField(2)
  bool isOnboardingCompleted;
  @HiveField(3)
  bool isPremium;
  @HiveField(4)
  DateTime? lastBackupTime;
  @HiveField(5)
  bool remindToBackup;
  @HiveField(6)
  String teacherName;
  @HiveField(7)
  String teacherPhotoPath;
  @HiveField(8)
  String teacherPhone;
  @HiveField(9)
  int firstDayOfWeek;
  @HiveField(10)
  bool showAttendanceOnDashboard;
  @HiveField(11)
  bool showFeesOnDashboard;
  @HiveField(12)
  bool showLessonsOnDashboard;
  @HiveField(13)
  String currencySymbol;
  @HiveField(14)
  String appVersion;
  @HiveField(15)
  DateTime firstLaunchDate;

  Map<String, dynamic> toJson() => {
    'languageCode': languageCode,
    'themeMode': themeMode,
    'isOnboardingCompleted': isOnboardingCompleted,
    'isPremium': isPremium,
    'lastBackupTime': lastBackupTime?.toIso8601String(),
    'remindToBackup': remindToBackup,
    'teacherName': teacherName,
    'teacherPhotoPath': teacherPhotoPath,
    'teacherPhone': teacherPhone,
    'firstDayOfWeek': firstDayOfWeek,
    'showAttendanceOnDashboard': showAttendanceOnDashboard,
    'showFeesOnDashboard': showFeesOnDashboard,
    'showLessonsOnDashboard': showLessonsOnDashboard,
    'currencySymbol': currencySymbol,
    'appVersion': appVersion,
    'firstLaunchDate': firstLaunchDate.toIso8601String(),
  };

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      AppSettingsModel(
        languageCode: json['languageCode'] as String? ?? 'en',
        themeMode: json['themeMode'] as String? ?? 'light',
        isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
        isPremium: json['isPremium'] as bool? ?? false,
        lastBackupTime: DateTime.tryParse(
          json['lastBackupTime'] as String? ?? '',
        ),
        remindToBackup: json['remindToBackup'] as bool? ?? true,
        teacherName: json['teacherName'] as String? ?? '',
        teacherPhotoPath: json['teacherPhotoPath'] as String? ?? '',
        teacherPhone: json['teacherPhone'] as String? ?? '',
        firstDayOfWeek: (json['firstDayOfWeek'] as num?)?.toInt() ?? 6,
        showAttendanceOnDashboard:
            json['showAttendanceOnDashboard'] as bool? ?? true,
        showFeesOnDashboard: json['showFeesOnDashboard'] as bool? ?? true,
        showLessonsOnDashboard: json['showLessonsOnDashboard'] as bool? ?? true,
        currencySymbol: json['currencySymbol'] as String? ?? '৳',
        appVersion: json['appVersion'] as String? ?? '',
        firstLaunchDate:
            DateTime.tryParse(json['firstLaunchDate'] as String? ?? '') ??
            DateTime.now(),
      );
}

class AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = 12;

  @override
  AppSettingsModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    String stringField(int index, String fallback) =>
        fields[index] is String ? fields[index] as String : fallback;
    bool boolField(int index, bool fallback) =>
        fields[index] is bool ? fields[index] as bool : fallback;
    int intField(int index, int fallback) =>
        fields[index] is int ? fields[index] as int : fallback;
    DateTime? dateField(int index) =>
        fields[index] is DateTime ? fields[index] as DateTime : null;

    return AppSettingsModel(
      languageCode: stringField(0, 'en'),
      themeMode: stringField(1, 'light'),
      isOnboardingCompleted: boolField(2, false),
      isPremium: boolField(3, false),
      lastBackupTime: dateField(4),
      remindToBackup: boolField(5, true),
      teacherName: stringField(6, ''),
      teacherPhotoPath: stringField(7, ''),
      teacherPhone: stringField(8, ''),
      firstDayOfWeek: intField(9, 6),
      showAttendanceOnDashboard: boolField(10, true),
      showFeesOnDashboard: boolField(11, true),
      showLessonsOnDashboard: boolField(12, true),
      currencySymbol: stringField(13, '৳'),
      appVersion: stringField(14, ''),
      firstLaunchDate: dateField(15) ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.languageCode)
      ..writeByte(1)
      ..write(obj.themeMode)
      ..writeByte(2)
      ..write(obj.isOnboardingCompleted)
      ..writeByte(3)
      ..write(obj.isPremium)
      ..writeByte(4)
      ..write(obj.lastBackupTime)
      ..writeByte(5)
      ..write(obj.remindToBackup)
      ..writeByte(6)
      ..write(obj.teacherName)
      ..writeByte(7)
      ..write(obj.teacherPhotoPath)
      ..writeByte(8)
      ..write(obj.teacherPhone)
      ..writeByte(9)
      ..write(obj.firstDayOfWeek)
      ..writeByte(10)
      ..write(obj.showAttendanceOnDashboard)
      ..writeByte(11)
      ..write(obj.showFeesOnDashboard)
      ..writeByte(12)
      ..write(obj.showLessonsOnDashboard)
      ..writeByte(13)
      ..write(obj.currencySymbol)
      ..writeByte(14)
      ..write(obj.appVersion)
      ..writeByte(15)
      ..write(obj.firstLaunchDate);
  }
}
