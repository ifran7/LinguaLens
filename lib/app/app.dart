import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/modules/module_screens.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/batches/domain/entities/batch_entity.dart';
import '../features/batches/presentation/screens/batches_list_screen.dart';
import '../features/batches/presentation/screens/batch_form_screen.dart';
import '../features/batches/presentation/screens/batch_detail_screen.dart';
import '../features/batches/presentation/screens/enroll_student_screen.dart';
import '../features/students/presentation/screens/student_detail_screen.dart';
import '../features/students/presentation/screens/student_form_screen.dart';
import '../features/students/presentation/screens/students_list_screen.dart';
import '../features/attendance/presentation/screens/attendance_home_screen.dart';
import '../features/attendance/presentation/screens/attendance_session_screen.dart';
import '../features/attendance/presentation/screens/student_attendance_screen.dart';
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
        builder: (ctx, state) => const StudentsListScreen(),
      ),
      GoRoute(
        path: '/students/add',
        builder: (ctx, state) => const StudentFormScreen(),
      ),
      GoRoute(
        path: '/students/edit/:id',
        builder: (ctx, state) =>
            StudentEditLoader(studentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/students/:id',
        builder: (ctx, state) =>
            StudentDetailScreen(studentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/batches',
        builder: (ctx, state) => const BatchesListScreen(),
      ),
      GoRoute(
        path: '/batches/add',
        builder: (ctx, state) => const BatchFormScreen(),
      ),
      GoRoute(
        path: '/batches/edit/:id',
        builder: (ctx, state) => BatchEditLoader(
          batchId: state.pathParameters['id']!,
          batch: state.extra is BatchEntity ? state.extra as BatchEntity : null,
        ),
      ),
      GoRoute(
        path: '/batches/:id/enroll',
        builder: (ctx, state) => BatchEnrollLoader(
          batchId: state.pathParameters['id']!,
          batch: state.extra is BatchEntity ? state.extra as BatchEntity : null,
        ),
      ),
      GoRoute(
        path: '/batches/:id',
        builder: (ctx, state) => BatchDetailScreen(
          batchId: state.pathParameters['id']!,
          batch: state.extra is BatchEntity ? state.extra as BatchEntity : null,
        ),
      ),
      GoRoute(
        path: '/attendance',
        builder: (ctx, state) => const AttendanceHomeScreen(),
      ),
      GoRoute(
        path: '/attendance/batch/:batchId',
        builder: (ctx, state) => AttendanceSessionScreen(
          batchId: state.pathParameters['batchId']!,
          initialDate: state.extra is DateTime ? state.extra as DateTime : null,
        ),
      ),
      GoRoute(
        path: '/students/:id/attendance',
        builder: (ctx, state) => StudentAttendanceScreen(
          studentId: state.pathParameters['id']!,
          batchId: state.uri.queryParameters['batchId'],
        ),
      ),
      GoRoute(
        path: '/attendance/student/:id/calendar',
        builder: (ctx, state) => StudentAttendanceScreen(
          studentId: state.pathParameters['id']!,
          batchId: state.uri.queryParameters['batchId'],
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
