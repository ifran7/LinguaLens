import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/batch_model.dart';

class BatchEntity {
  const BatchEntity({
    required this.id,
    required this.name,
    required this.subject,
    this.description = '',
    this.scheduleText = '',
    this.monthlyFeeDefault = 0,
    this.colorTagIndex = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String subject;
  final String description;
  final String scheduleText;
  final double monthlyFeeDefault;
  final int colorTagIndex;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Color get color =>
      AppConstants.batchColorTags[colorTagIndex.clamp(
        0,
        AppConstants.batchColorTags.length - 1,
      )];

  BatchEntity copyWith({
    String? id,
    String? name,
    String? subject,
    String? description,
    String? scheduleText,
    double? monthlyFeeDefault,
    int? colorTagIndex,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BatchEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    subject: subject ?? this.subject,
    description: description ?? this.description,
    scheduleText: scheduleText ?? this.scheduleText,
    monthlyFeeDefault: monthlyFeeDefault ?? this.monthlyFeeDefault,
    colorTagIndex: colorTagIndex ?? this.colorTagIndex,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  BatchModel toModel() => BatchModel(
    id: id,
    name: name,
    subject: subject,
    description: description,
    scheduleText: scheduleText,
    monthlyFeeDefault: monthlyFeeDefault,
    colorTagIndex: colorTagIndex,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static BatchEntity fromModel(BatchModel model) => BatchEntity(
    id: model.id,
    name: model.name,
    subject: model.subject,
    description: model.description,
    scheduleText: model.scheduleText,
    monthlyFeeDefault: model.monthlyFeeDefault,
    colorTagIndex: model.colorTagIndex,
    isActive: model.isActive,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is BatchEntity && other.id == id && other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, updatedAt);
}
