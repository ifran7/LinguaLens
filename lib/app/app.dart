import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/route_names.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/error_handler.dart';
import '../core/widgets/app_shell.dart';
import '../features/attendance/presentation/screens/attendance_home_screen.dart';
import '../features/attendance/presentation/screens/attendance_session_screen.dart';
import '../features/attendance/presentation/screens/student_attendance_screen.dart';
import '../features/batches/domain/entities/batch_entity.dart';
import '../features/batches/presentation/screens/batch_detail_screen.dart';
import '../features/batches/presentation/screens/batch_form_screen.dart';
import '../features/batches/presentation/screens/batches_list_screen.dart';
import '../features/batches/presentation/screens/enroll_student_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/fees/presentation/screens/collect_payment_screen.dart';
import '../features/fees/presentation/screens/fee_dashboard_screen.dart';
import '../features/fees/presentation/screens/fee_generator_screen.dart';
import '../features/fees/presentation/screens/fee_overview_screen.dart';
import '../features/fees/presentation/screens/student_fee_history_screen.dart';
import '../features/lessons/presentation/screens/lesson_detail_screen.dart';
import '../features/lessons/presentation/screens/lesson_form_screen.dart';
import '../features/lessons/presentation/screens/lesson_planner_screen.dart';
import '../features/lessons/presentation/screens/syllabus_screen.dart';
import '../features/messages/presentation/screens/compose_message_screen.dart';
import '../features/messages/presentation/screens/message_log_screen.dart';
import '../features/messages/presentation/screens/message_template_manager_screen.dart';
import '../features/messages/presentation/screens/messages_center_screen.dart';
import '../features/more/more_menu_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/search/global_search_screen.dart';
import '../features/settings/presentation/screens/backup_restore_screen.dart';
import '../features/settings/presentation/screens/settings_center_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/modules/module_screens.dart' show SubscriptionScreen;
import '../features/students/presentation/screens/student_detail_screen.dart';
import '../features/students/presentation/screens/student_form_screen.dart';
import '../features/students/presentation/screens/students_list_screen.dart';
import 'app_state.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final completed = ref.watch(onboardingControllerProvider);
  return GoRouter(
    initialLocation: completed ? RouteNames.dashboard : RouteNames.onboarding,
    redirect: (context, state) {
      final isOnboarding = state.matchedLocation == RouteNames.onboarding;
      if (!completed && !isOnboarding) return RouteNames.onboarding;
      if (completed && isOnboarding) return RouteNames.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.students,
                builder: (context, state) => const StudentsListScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const StudentFormScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) => StudentEditLoader(
                      studentId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => StudentDetailScreen(
                      studentId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.attendance,
                builder: (context, state) => const AttendanceHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'batch/:batchId',
                    builder: (context, state) => AttendanceSessionScreen(
                      batchId: state.pathParameters['batchId']!,
                      initialDate: state.extra is DateTime
                          ? state.extra as DateTime
                          : null,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: '/students/:id/attendance',
                builder: (context, state) => StudentAttendanceScreen(
                  studentId: state.pathParameters['id']!,
                  batchId: state.uri.queryParameters['batchId'],
                ),
              ),
              GoRoute(
                path: RouteNames.attendanceCalendar,
                builder: (context, state) => StudentAttendanceScreen(
                  studentId: state.pathParameters['id']!,
                  batchId: state.uri.queryParameters['batchId'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.fees,
                builder: (context, state) => const FeeDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'overview',
                    builder: (context, state) => FeeOverviewScreen(
                      initialMonthKey: state.uri.queryParameters['monthKey'],
                      showOverdue:
                          state.uri.queryParameters['overdue'] == 'true',
                    ),
                  ),
                  GoRoute(
                    path: 'generate',
                    builder: (context, state) => FeeGeneratorScreen(
                      initialMonthKey: state.uri.queryParameters['monthKey'],
                    ),
                  ),
                  GoRoute(
                    path: 'collect',
                    builder: (context, state) => CollectPaymentScreen(
                      studentId: state.uri.queryParameters['studentId'] ?? '',
                      batchId: state.uri.queryParameters['batchId'] ?? '',
                      monthKey: state.uri.queryParameters['monthKey'] ?? '',
                      feeRecordId: state.uri.queryParameters['feeRecordId'],
                    ),
                  ),
                  GoRoute(
                    path: 'student/:studentId',
                    builder: (context, state) => StudentFeeHistoryScreen(
                      studentId: state.pathParameters['studentId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreMenuScreen(),
              ),
              GoRoute(
                path: RouteNames.batches,
                builder: (context, state) => const BatchesListScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const BatchFormScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) => BatchEditLoader(
                      batchId: state.pathParameters['id']!,
                      batch: state.extra is BatchEntity
                          ? state.extra as BatchEntity
                          : null,
                    ),
                  ),
                  GoRoute(
                    path: ':id/enroll',
                    builder: (context, state) => BatchEnrollLoader(
                      batchId: state.pathParameters['id']!,
                      batch: state.extra is BatchEntity
                          ? state.extra as BatchEntity
                          : null,
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => BatchDetailScreen(
                      batchId: state.pathParameters['id']!,
                      batch: state.extra is BatchEntity
                          ? state.extra as BatchEntity
                          : null,
                    ),
                  ),
                  GoRoute(
                    path: ':id/syllabus',
                    builder: (context, state) =>
                        SyllabusScreen(batchId: state.pathParameters['id']!),
                  ),
                ],
              ),
              GoRoute(
                path: RouteNames.lessons,
                builder: (context, state) => const LessonPlannerScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => LessonFormScreen(
                      initialBatchId: state.uri.queryParameters['batchId'],
                      initialDate: state.uri.queryParameters['date'] == null
                          ? null
                          : DateTime.tryParse(
                              state.uri.queryParameters['date']!,
                            ),
                    ),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) =>
                        LessonFormScreen(lessonId: state.pathParameters['id']!),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => LessonDetailScreen(
                      lessonId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: RouteNames.messages,
                builder: (context, state) => const MessagesCenterScreen(),
                routes: [
                  GoRoute(
                    path: 'compose',
                    builder: (context, state) => ComposeMessageScreen(
                      studentId: state.uri.queryParameters['studentId'],
                      batchId: state.uri.queryParameters['batchId'],
                    ),
                  ),
                  GoRoute(
                    path: 'templates',
                    builder: (context, state) =>
                        const MessageTemplateManagerScreen(),
                  ),
                  GoRoute(
                    path: 'logs',
                    builder: (context, state) => MessageLogScreen(
                      studentId: state.uri.queryParameters['studentId'],
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: RouteNames.settings,
                builder: (context, state) => const SettingsCenterScreen(),
                routes: [
                  GoRoute(
                    path: 'language',
                    builder: (context, state) => const LanguageScreen(),
                  ),
                  GoRoute(
                    path: 'theme',
                    builder: (context, state) => const ThemeScreen(),
                  ),
                  GoRoute(
                    path: 'backup',
                    builder: (context, state) => const BackupRestoreScreen(),
                  ),
                  GoRoute(
                    path: 'subscription',
                    builder: (context, state) => const SubscriptionScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: RouteNames.search,
                builder: (context, state) => const GlobalSearchScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class LinguaLensApp extends ConsumerWidget {
  const LinguaLensApp({super.key, this.startupError});

  final Object? startupError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (startupError != null) {
      return MaterialApp(
        title: 'LinguaLens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(fontFamily: 'Poppins'),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 56),
                    const SizedBox(height: 20),
                    Text(
                      'LinguaLens could not start',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppErrorHandler.getReadableError(startupError!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Please restart LinguaLens and try again.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    final themeMode = ref.watch(themeControllerProvider);
    final locale = ref.watch(localeControllerProvider);
    final fontFamily = locale.languageCode == 'bn'
        ? 'NotoSansBengali'
        : 'Poppins';
    return MaterialApp.router(
      title: 'LinguaLens',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(fontFamily: fontFamily),
      darkTheme: AppTheme.dark(fontFamily: fontFamily),
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
