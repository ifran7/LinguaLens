import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 1:
        context.push('/students');
      case 2:
        context.push('/attendance');
      case 3:
        context.push('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
              Text(
                l.t('welcome'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                l.t('manageTeaching'),
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              _FocusBanner(onTap: () => context.push('/attendance')),
              const SizedBox(height: 28),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.12,
                children: [
                  MetricCard(
                    label: l.t('totalStudents'),
                    value: '0',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.primary,
                    onTap: () => context.push('/students'),
                  ),
                  MetricCard(
                    label: l.t('activeBatches'),
                    value: '0',
                    icon: Icons.groups_rounded,
                    color: AppColors.secondary,
                    onTap: () => context.push('/batches'),
                  ),
                  MetricCard(
                    label: l.t('pendingFees'),
                    value: '৳0',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.warning,
                    onTap: () => context.push('/fees'),
                  ),
                  MetricCard(
                    label: l.t('attendanceToday'),
                    value: '—',
                    icon: Icons.fact_check_rounded,
                    color: AppColors.success,
                    onTap: () => context.push('/attendance'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SectionHeader(title: l.t('quickActions')),
              const SizedBox(height: 14),
              _QuickActions(),
              const SizedBox(height: 30),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l.t('dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
            label: l.t('students'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.fact_check_outlined),
            selectedIcon: const Icon(Icons.fact_check_rounded),
            label: l.t('attendance'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_outlined),
            selectedIcon: const Icon(Icons.tune_rounded),
            label: l.t('settings'),
          ),
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
                    'Keep your daily rhythm moving.',
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
