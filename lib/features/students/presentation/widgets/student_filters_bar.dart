import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../providers/student_provider.dart';

class StudentFiltersBar extends StatelessWidget {
  const StudentFiltersBar({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final StudentsState state;
  final ValueChanged<StudentFilterType> onChanged;

  @override
  Widget build(BuildContext context) {
    final filters = <(StudentFilterType, String, int)>[
      (
        StudentFilterType.all,
        context.l10n.t('allStudents'),
        state.allStudents.length,
      ),
      (
        StudentFilterType.active,
        context.l10n.t('activeStudents'),
        state.activeCount,
      ),
      (
        StudentFilterType.archived,
        context.l10n.t('archivedStudents'),
        state.archivedCount,
      ),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${filter.$2}  ${filter.$3}'),
                  selected: state.filterType == filter.$1,
                  onSelected: (_) => onChanged(filter.$1),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
