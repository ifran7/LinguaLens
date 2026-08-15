import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../attendance/providers/attendance_provider.dart';
import '../students/providers/student_provider.dart';
import '../batches/providers/batch_provider.dart';
import '../fees/providers/fee_provider.dart';
import '../lessons/providers/lesson_provider.dart';
import '../lessons/presentation/widgets/lesson_card.dart';
import '../settings/providers/settings_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _backupReminderDismissed = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(studentsListProvider.notifier).loadStudents();
      await ref.read(batchesListProvider.notifier).loadBatches();
      await ref.read(feeDashboardProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final feeDashboard = ref.watch(feeDashboardProvider);
    final settings = ref.watch(settingsProvider);
    final storage = ref.read(storageProvider);
    final lastBackup = storage.lastBackupTime;
    final backupDue =
        storage.remindToBackup &&
        !_backupReminderDismissed &&
        (lastBackup == null ||
            DateTime.now().difference(lastBackup).inDays >= 30);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.t('appName'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  l.t('appTagline'),
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.t('search'),
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: backupDue
                ? l.t('backupReminderMessage')
                : l.t('backupRestore'),
            onPressed: () => context.push('/settings/backup'),
            icon: Badge(
              isLabelVisible: backupDue,
              backgroundColor: AppColors.warning,
              child: const Icon(Icons.backup_outlined),
            ),
          ),
          IconButton(
            tooltip: l.t('settings'),
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreetingCard(
                teacherName: settings.teacherName,
                activeStudents: ref.watch(studentsListProvider).activeCount,
              ),
              if (backupDue) ...[
                const SizedBox(height: 16),
                _BackupReminderBanner(
                  onBackup: () => context.push('/settings/backup'),
                  onDismiss: () =>
                      setState(() => _backupReminderDismissed = true),
                ),
              ],
              const SizedBox(height: 20),
              _FocusBanner(onTap: () => context.push('/attendance')),
              const SizedBox(height: 28),
              SizedBox(
                height: 132,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    SizedBox(
                      width: 148,
                      child: MetricCard(
                        label: l.t('totalStudents'),
                        value: ref
                            .watch(studentsListProvider)
                            .activeCount
                            .toString(),
                        icon: Icons.people_alt_rounded,
                        color: AppColors.primary,
                        onTap: () => context.push('/students'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 148,
                      child: MetricCard(
                        label: l.t('activeBatches'),
                        value: ref
                            .watch(batchesListProvider)
                            .activeCount
                            .toString(),
                        icon: Icons.groups_rounded,
                        color: AppColors.secondary,
                        onTap: () => context.push('/batches'),
                      ),
                    ),
                    if (settings.showFeesOnDashboard) ...[
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 148,
                        child: MetricCard(
                          label: l.t('pendingFees'),
                          value:
                              feeDashboard.isLoading &&
                                  feeDashboard.aggregate == null
                              ? '…'
                              : formatFee(
                                  feeDashboard.aggregate?.totalDue ?? 0,
                                ),
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppColors.warning,
                          onTap: () => context.push('/fees'),
                        ),
                      ),
                    ],
                    if (settings.showAttendanceOnDashboard) ...[
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 148,
                        child: MetricCard(
                          label: l.t('attendanceToday'),
                          value: ref
                              .watch(
                                attendanceDailySummaryProvider(
                                  normalizeDate(DateTime.now()),
                                ),
                              )
                              .when(
                                data: (summary) =>
                                    '${summary.presentCount}/${summary.expectedStudentCount}',
                                loading: () => '…',
                                error: (_, _) => '—',
                              ),
                          icon: Icons.fact_check_rounded,
                          color: AppColors.success,
                          onTap: () => context.push('/attendance'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SectionHeader(title: l.t('quickActions')),
              const SizedBox(height: 14),
              _QuickActions(),
              const SizedBox(height: 30),
              if (settings.showLessonsOnDashboard) ...[
                SectionHeader(
                  title: l.t('todaysSchedule'),
                  actionLabel: l.t('viewAll'),
                  onAction: () => context.push('/lessons'),
                ),
                const SizedBox(height: 12),
                ref
                    .watch(todayLessonsProvider)
                    .when(
                      loading: () => const AppLoading(),
                      error: (_, _) =>
                          AppCard(child: Text(l.t('noLessonsToday'))),
                      data: (items) => items.isEmpty
                          ? AppEmptyState(
                              compact: true,
                              icon: Icons.menu_book_outlined,
                              title: l.t('noLessonsToday'),
                              actionLabel: l.t('addLesson'),
                              onAction: () => context.push('/lessons/add'),
                            )
                          : Column(
                              children: items
                                  .take(3)
                                  .map(
                                    (item) => LessonCard(
                                      item: item,
                                      onTap: () => context.push(
                                        '/lessons/${item.lesson.id}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                const SizedBox(height: 30),
              ],
              if (settings.showUpcomingLessons) ...[
                SectionHeader(
                  title: l.t('upcomingLessons'),
                  actionLabel: l.t('viewAll'),
                  onAction: () => context.push('/lessons'),
                ),
                const SizedBox(height: 12),
                ref
                    .watch(upcomingLessonsProvider)
                    .when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) =>
                          AppCard(child: Text(l.t('noUpcomingLessons'))),
                      data: (items) => items.isEmpty
                          ? AppCard(child: Text(l.t('noUpcomingLessons')))
                          : Column(
                              children: items
                                  .take(3)
                                  .map(
                                    (item) => LessonCard(
                                      item: item,
                                      onTap: () => context.push(
                                        '/lessons/${item.lesson.id}',
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                const SizedBox(height: 30),
              ],
              SectionHeader(
                title: l.t('recentActivity'),
                actionLabel: l.t('viewAll'),
                onAction: () => context.push('/students'),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Row(
                  children: [
                    const IconBadge(
                      icon: Icons.auto_awesome_rounded,
                      color: AppColors.primary,
                      size: 48,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.t('noRecentActivity'),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.t('noRecentActivityBody'),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({
    required this.teacherName,
    required this.activeStudents,
  });

  final String teacherName;
  final int activeStudents;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? l.t('goodMorning')
        : hour < 17
        ? l.t('goodAfternoon')
        : l.t('goodEvening');
    final name = teacherName.trim().isEmpty
        ? l.t('teacher')
        : teacherName.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.78),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $name',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatShortWeekdayDate(DateTime.now())}  •  $activeStudents ${l.t('studentsActive')}',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.white.withValues(alpha: 0.84)),
          ),
        ],
      ),
    );
  }
}

class _BackupReminderBanner extends StatelessWidget {
  const _BackupReminderBanner({
    required this.onBackup,
    required this.onDismiss,
  });

  final VoidCallback onBackup;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppCard(
      color: AppColors.warning.withValues(alpha: 0.16),
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          const Icon(Icons.backup_outlined, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l.t('backupReminderMessage'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            tooltip: l.t('dismiss'),
            onPressed: onDismiss,
            icon: const Icon(Icons.close_rounded),
          ),
          TextButton(onPressed: onBackup, child: Text(l.t('createBackupNow'))),
        ],
      ),
    );
  }
}

class _FocusBanner extends StatelessWidget {
  const _FocusBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.t('todayFocus'),
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.82)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.t('startMarking'),
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.t('keepDailyRhythm'),
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: Colors.white.withValues(alpha: 0.82)),
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        'addStudent',
        Icons.person_add_alt_1_rounded,
        AppColors.primary,
        '/students/add',
      ),
      (
        'addBatch',
        Icons.group_add_rounded,
        AppColors.secondary,
        '/batches/add',
      ),
      ('recordPayment', Icons.payments_rounded, AppColors.warning, '/fees'),
      ('planLesson', Icons.menu_book_rounded, AppColors.success, '/lessons'),
      (
        'messageParent',
        Icons.chat_bubble_outline_rounded,
        const Color(0xFF0EA5A4),
        '/messages',
      ),
      (
        'openBackup',
        Icons.cloud_upload_outlined,
        const Color(0xFF7C3AED),
        '/settings/backup',
      ),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions
          .map(
            (action) => SizedBox(
              width: (MediaQuery.sizeOf(context).width - 60) / 3,
              child: InkWell(
                onTap: () => context.push(action.$4),
                borderRadius: BorderRadius.circular(18),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  child: Column(
                    children: [
                      IconBadge(icon: action.$2, color: action.$3, size: 38),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.t(action.$1),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
