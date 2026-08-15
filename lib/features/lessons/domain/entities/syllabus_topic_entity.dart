import '../../data/models/syllabus_topic_model.dart';

class SyllabusTopicEntity {
  const SyllabusTopicEntity({
    required this.id,
    required this.batchId,
    this.title = '',
    this.description = '',
    this.orderIndex = 0,
    this.isCompleted = false,
    this.completedDate,
    this.chapterName = '',
    this.estimatedClasses = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String batchId;
  final String title;
  final String description;
  final int orderIndex;
  final bool isCompleted;
  final DateTime? completedDate;
  final String chapterName;
  final int estimatedClasses;
  final DateTime createdAt;
  final DateTime updatedAt;

  SyllabusTopicEntity copyWith({
    String? id,
    String? batchId,
    String? title,
    String? description,
    int? orderIndex,
    bool? isCompleted,
    DateTime? completedDate,
    bool clearCompletedDate = false,
    String? chapterName,
    int? estimatedClasses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SyllabusTopicEntity(
    id: id ?? this.id,
    batchId: batchId ?? this.batchId,
    title: title ?? this.title,
    description: description ?? this.description,
    orderIndex: orderIndex ?? this.orderIndex,
    isCompleted: isCompleted ?? this.isCompleted,
    completedDate: clearCompletedDate
        ? null
        : completedDate ?? this.completedDate,
    chapterName: chapterName ?? this.chapterName,
    estimatedClasses: (estimatedClasses ?? this.estimatedClasses).clamp(1, 999),
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  SyllabusTopicModel toModel() => SyllabusTopicModel(
    id: id,
    batchId: batchId,
    title: title,
    description: description,
    orderIndex: orderIndex,
    isCompleted: isCompleted,
    completedDate: completedDate,
    chapterName: chapterName,
    estimatedClasses: estimatedClasses,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static SyllabusTopicEntity fromModel(SyllabusTopicModel model) =>
      SyllabusTopicEntity(
        id: model.id,
        batchId: model.batchId,
        title: model.title,
        description: model.description,
        orderIndex: model.orderIndex,
        isCompleted: model.isCompleted,
        completedDate: model.completedDate,
        chapterName: model.chapterName,
        estimatedClasses: model.estimatedClasses < 1
            ? 1
            : model.estimatedClasses,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      other is SyllabusTopicEntity &&
      other.id == id &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, updatedAt);
}
