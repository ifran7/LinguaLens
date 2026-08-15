import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingualens/core/localization/app_localizations.dart';

void main() {
  test('supported locales expose the primary app copy', () {
    final english = AppLocalizations(Locale('en'));
    final bangla = AppLocalizations(Locale('bn'));

    expect(english.t('appName'), 'LinguaLens');
    expect(bangla.t('appName'), isNotEmpty);
    expect(english.t('students'), isNotEmpty);
  });
}
