import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';

Future<String?> showMonthPickerDialog(
  BuildContext context, {
  required String initialMonthKey,
}) => showDialog<String>(
  context: context,
  builder: (_) => MonthPickerDialog(initialMonthKey: initialMonthKey),
);

class MonthPickerDialog extends StatefulWidget {
  const MonthPickerDialog({super.key, required this.initialMonthKey});

  final String initialMonthKey;

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final date = monthKeyToDate(widget.initialMonthKey);
    _year = date.year;
    _month = date.month;
  }

  @override
  Widget build(BuildContext context) {
    final names = <String>[
      context.l10n.t('january'),
      context.l10n.t('february'),
      context.l10n.t('march'),
      context.l10n.t('april'),
      context.l10n.t('may'),
      context.l10n.t('june'),
      context.l10n.t('july'),
      context.l10n.t('august'),
      context.l10n.t('september'),
      context.l10n.t('october'),
      context.l10n.t('november'),
      context.l10n.t('december'),
    ];
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(() => _year--),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text('$_year'),
          IconButton(
            onPressed: () => setState(() => _year++),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.7,
          ),
          itemBuilder: (context, index) {
            final selected = index + 1 == _month;
            return OutlinedButton(
              onPressed: () => setState(() => _month = index + 1),
              style: OutlinedButton.styleFrom(
                backgroundColor: selected
                    ? Theme.of(context).colorScheme.primary
                    : null,
                foregroundColor: selected ? Colors.white : null,
              ),
              child: Text(names[index]),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.t('cancel')),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(monthKey(DateTime(_year, _month))),
          child: Text(context.l10n.t('selectMonth')),
        ),
      ],
    );
  }
}
