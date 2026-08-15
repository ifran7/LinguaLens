import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lingualens/core/localization/app_localizations.dart';

void main() {
  test('supports English and Bangla copy', () {
    expect(AppLocalizations(const Locale('en')).t('dashboard'), 'Dashboard');
    expect(AppLocalizations(const Locale('bn')).t('dashboard'), 'ড্যাশবোর্ড');
  });
}
