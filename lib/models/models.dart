enum AttendanceStatus { present, absent, late, leave }

enum FeeStatus { unpaid, partial, paid }

enum LessonPlanType { daily, weekly, monthly }

class StudentModel {
  StudentModel({
    required this.id,
    required this.fullName,
    this.studentCode,
    this.phone,
    this.parentName,
    this.parentPhone,
    this.address,
    this.schoolName,
    this.className,
    this.notes,
    this.photoPath,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String fullName;
  final String? studentCode;
  final String? phone;
  final String? parentName;
  final String? parentPhone;
  final String? address;
  final String? schoolName;
  final String? className;
  final String? notes;
  final String? photoPath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class BatchModel {
  BatchModel({
    required this.id,
    required this.name,
    required this.subject,
    this.description,
    this.scheduleText,
    this.monthlyFeeDefault = 0,
    this.colorTag,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String name;
  final String subject;
  final String? description;
  final String? scheduleText;
  final double monthlyFeeDefault;
  final String? colorTag;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class AttendanceModel {
  AttendanceModel({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.date,
    required this.status,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String studentId;
  final String batchId;
  final DateTime date;
  final AttendanceStatus status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class FeeRecordModel {
  FeeRecordModel({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.monthKey,
    this.assignedFee = 0,
    this.discountAmount = 0,
    this.finalFee = 0,
    this.dueAmount = 0,
    this.status = FeeStatus.unpaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String studentId;
  final String batchId;
  final String monthKey;
  final double assignedFee;
  final double discountAmount;
  final double finalFee;
  final double dueAmount;
  final FeeStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class LessonPlanModel {
  LessonPlanModel({
    required this.id,
    required this.batchId,
    required this.title,
    required this.lessonDate,
    this.description,
    this.planType = LessonPlanType.daily,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String batchId;
  final String title;
  final String? description;
  final DateTime lessonDate;
  final LessonPlanType planType;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class AppSettingsModel {
  const AppSettingsModel({
    this.languageCode = 'en',
    this.themeMode = 'light',
    this.isOnboardingCompleted = false,
    this.isPremium = false,
    this.lastBackupTime,
  });

  final String languageCode;
  final String themeMode;
  final bool isOnboardingCompleted;
  final bool isPremium;
  final DateTime? lastBackupTime;
}
