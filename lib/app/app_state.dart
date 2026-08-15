import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/local_storage_service.dart';

final storageProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService.instance,
);

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(
  ThemeController.new,
);

class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.read(storageProvider).themeMode;
    return saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await ref
        .read(storageProvider)
        .setThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => Locale(ref.read(storageProvider).languageCode);

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref.read(storageProvider).setLanguageCode(locale.languageCode);
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);

class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.read(storageProvider).onboardingCompleted;

  Future<void> complete() async {
    state = true;
    await ref.read(storageProvider).setOnboardingCompleted(true);
  }
}
