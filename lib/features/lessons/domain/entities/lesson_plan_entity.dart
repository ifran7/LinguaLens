import '../../../../core/utils/date_utils.dart';
import '../../data/models/lesson_plan_model.dart';
import 'lesson_status.dart';
import 'lesson_type.dart';

class LessonPlanEntity {
  const LessonPlanEntity({
    required this.id,
    required this.batchId,
    this.title = '',
    this.description = '',
    required this.lessonDate,
    this.planType = 'daily',
    this.status = 'planned',
    this.coveredTopicIds = const [],
    this.homework = '',
    this.resourceLinks = '',
    this.durationMinutes = 0,
    this.teacherNote = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String batchId;
  final String title;
  final String description;
  final DateTime lessonDate;
  final String planType;
  final String status;
  final List<String> coveredTopicIds;
  final String homework;
  final String resourceLinks;
  final int durationMinutes;
  final String teacherNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  LessonType get type => LessonTypeX.fromValue(planType);
  LessonStatus get lessonStatus => LessonStatusX.fromValue(status);
  bool get isPast => lessonDate.isBefore(normalizeDate(DateTime.now()));
  bool get isToday => isSameNormalizedDate(lessonDate, DateTime.now());
  bool get isUpcoming => lessonDate.isAfter(normalizeDate(DateTime.now()));
  int get topicCount => coveredTopicIds.length;

  LessonPlanEntity copyWith({
    String? id,
    String? batchId,
    String? title,
    String? description,
    DateTime? lessonDate,
    String? planType,
    String? status,
    List<String>? coveredTopicIds,
    String? homework,
    String? resourceLinks,
    int? durationMinutes,
    String? teacherNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LessonPlanEntity(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    title: title ?? this.title,
    description: description ?? this.description,
    lessonDate: lessonDate ?? this.lessonDate,
    planType: planType ?? this.planType,
    status: status ?? this.status,
    coveredTopicIds: coveredTopicIds ?? this.coveredTopicIds,
    homework: homework ?? this.homework,
    resourceLinks: resourceLinks ?? this.resourceLinks,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    teacherNote: teacherNote ?? this.teacherNote,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  LessonPlanModel toModel() => LessonPlanModel(
    id: id,
    batchId: batchId,
    title: title,
    description: description,
    lessonDate: normalizeDate(lessonDate),
    planType: planType,
    status: status,
    coveredTopicIds: coveredTopicIds,
    homework: homework,
    resourceLinks: resourceLinks,
    durationMinutes: durationMinutes,
    teacherNote: teacherNote,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static LessonPlanEntity fromModel(LessonPlanModel model) => LessonPlanEntity(
    id: model.id,
    batchId: model.batchId,
    title: model.title,
    description: model.description,
    lessonDate: normalizeDate(model.lessonDate),
    planType: model.planType,
    status: model.status,
    coveredTopicIds: List.unmodifiable(model.coveredTopicIds),
    homework: model.homework,
    resourceLinks: model.resourceLinks,
    durationMinutes: model.durationMinutes,
    teacherNote: model.teacherNote,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is LessonPlanEntity &&
      other.id == id &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, updatedAt);
}
