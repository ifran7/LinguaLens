# LinguaLens

LinguaLens is a local-first Flutter app foundation for tuition teachers. It is designed for Android first while keeping the project compatible with iOS. The current build focuses on a calm, professional dashboard experience and the extensible foundation requested for student, batch, attendance, fee, lesson, messaging, backup, settings, authentication, and subscription workflows.

## Product foundation

The first-run experience includes a three-page onboarding flow with localized English and Bangla copy. After onboarding, teachers land on a dashboard with a daily-focus banner, student/batch/fee/attendance metrics, quick actions, and an intentional empty state for recent activity. Settings includes immediate language and light/dark theme switching, local backup and restore, a premium feature placeholder, and an about section.

The application is local-first. Preferences are stored with `shared_preferences`, while backup export and schema-checked restore use JSON files selected through the native file picker. Supabase Google login, cloud sync, billing, and advanced business repositories are represented as future-ready service contracts and are intentionally disabled in this phase.

## Architecture

The code is organized by responsibility:

- `lib/app/` contains the app shell, Riverpod state controllers, and GoRouter route map.
- `lib/core/` contains theme tokens, bilingual localization, shared widgets, local storage, backup/restore, and future integration services.
- `lib/features/` contains onboarding, dashboard, settings, and route-safe placeholder modules.
- `lib/models/` contains null-safe foundational entities and enums for students, batches, attendance, fees, lessons, and settings.
- `test/` contains the localization smoke test.

The visual direction is bound in `.open-design.json` to the Open Design `clean` system with the `live-dashboard` dashboard composition reference. The implementation applies an 8-point spacing rhythm, soft rounded surfaces, a restrained blue accent, accessible touch targets, semantic light/dark colors, and concise action-oriented copy.

## Run locally

Install Flutter 3.47 or later, then run:

```bash
flutter pub get
flutter run
```

The default onboarding state is persisted locally. To test onboarding again, clear the application data or remove the `is_onboarding_completed` preference from the device.

## Validation

The project currently passes:

```bash
flutter analyze
flutter test
flutter build bundle --debug
```

An Android APK build was attempted in the sandbox, but the sandbox does not include an Android SDK. The Flutter source and platform-neutral bundle build pass successfully; run `flutter build apk --debug` on a machine with the Android SDK configured.
