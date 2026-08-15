import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/modules/module_screens.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_state.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final completed = ref.read(storageProvider).onboardingCompleted;
  return GoRouter(
    initialLocation: completed ? '/dashboard' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (ctx, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (ctx, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/students',
        builder: (ctx, state) => ModuleScreen(
          title: 'Students',
          icon: Icons.people_alt_rounded,
          cta: 'Add student',
          onPressed: () => ctx.push('/students/add'),
        ),
      ),
      GoRoute(
        path: '/students/add',
        builder: (ctx, state) => const AddFormScreen(
          title: 'Add student',
          label: 'Student name',
          icon: Icons.person_add_alt_1_rounded,
        ),
      ),
      GoRoute(
        path: '/students/:id',
        builder: (ctx, state) => ModuleScreen(
          title: 'Student details',
          icon: Icons.person_rounded,
          cta: 'Add student',
        ),
      ),
      GoRoute(
        path: '/batches',
        builder: (ctx, state) => ModuleScreen(
          title: 'Batches',
          icon: Icons.groups_rounded,
          cta: 'Add batch',
          onPressed: () => ctx.push('/batches/add'),
        ),
      ),
      GoRoute(
        path: '/batches/add',
        builder: (ctx, state) => const AddFormScreen(
          title: 'Add batch',
          label: 'Batch name',
          icon: Icons.group_add_rounded,
        ),
      ),
      GoRoute(
        path: '/batches/:id',
        builder: (ctx, state) => ModuleScreen(
          title: 'Batch details',
          icon: Icons.groups_rounded,
          cta: 'Add batch',
        ),
      ),
      GoRoute(
        path: '/attendance',
        builder: (ctx, state) => ModuleScreen(
          title: 'Attendance',
          icon: Icons.fact_check_rounded,
          cta: 'Start marking',
        ),
      ),
      GoRoute(
        path: '/attendance/student/:id/calendar',
        builder: (ctx, state) => ModuleScreen(
          title: 'Attendance calendar',
          icon: Icons.calendar_month_rounded,
          cta: 'Start marking',
        ),
      ),
      GoRoute(
        path: '/fees',
        builder: (ctx, state) => ModuleScreen(
          title: 'Fees',
          icon: Icons.account_balance_wallet_rounded,
          cta: 'Record payment',
        ),
      ),
      GoRoute(
        path: '/lessons',
        builder: (ctx, state) => ModuleScreen(
          title: 'Lessons',
          icon: Icons.menu_book_rounded,
          cta: 'Plan a lesson',
        ),
      ),
      GoRoute(
        path: '/messages',
        builder: (ctx, state) => ModuleScreen(
          title: 'Messages',
          icon: Icons.chat_bubble_outline_rounded,
          cta: 'Message a parent',
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (ctx, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/settings/language',
        builder: (ctx, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/settings/theme',
        builder: (ctx, state) => const ThemeScreen(),
      ),
      GoRoute(
        path: '/settings/backup',
        builder: (ctx, state) => const BackupRestoreScreen(),
      ),
      GoRoute(
        path: '/settings/subscription',
        builder: (ctx, state) => const SubscriptionScreen(),
      ),
    ],
  );
});

class LinguaLensApp extends ConsumerWidget {
  const LinguaLensApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp.router(
      title: 'LinguaLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}
