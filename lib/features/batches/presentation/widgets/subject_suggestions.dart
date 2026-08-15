import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';

class SubjectSuggestions extends StatelessWidget {
  const SubjectSuggestions({
    super.key,
    required this.query,
    required this.onSelected,
  });

  final String query;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return const SizedBox.shrink();
    final suggestions = AppConstants.subjects
        .where((subject) => subject.toLowerCase().contains(needle))
        .take(5)
        .toList();
    if (suggestions.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(top: -6, bottom: 12),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: suggestions
            .map(
              (subject) => ListTile(
                dense: true,
                leading: const Icon(Icons.menu_book_outlined, size: 18),
                title: Text(subject),
                onTap: () => onSelected(subject),
              ),
            )
            .toList(),
      ),
    );
  }
}

String subjectHint(BuildContext context) => context.l10n.t('subjectHint');
