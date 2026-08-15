import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';

class ColorTagPicker extends StatelessWidget {
  const ColorTagPicker({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(AppConstants.batchColorTags.length, (index) {
          final selected = selectedIndex == index;
          final color = AppConstants.batchColorTags[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Semantics(
              label: '${context.l10n.t('batchColor')} ${index + 1}',
              selected: selected,
              button: true,
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(28),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: selected ? 48 : 40,
                  height: selected ? 48 : 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, color: Colors.white)
                      : null,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
