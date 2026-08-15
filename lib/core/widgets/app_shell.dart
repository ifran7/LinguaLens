import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/widgets/nav_badge.dart';
import '../../features/attendance/providers/attendance_provider.dart';
import '../../features/batches/providers/batch_provider.dart';
import '../../features/fees/providers/fee_provider.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fees = ref.watch(feeDashboardProvider);
    final attendance = ref.watch(todayAttendanceCountProvider);
    final activeBatchCount = ref.watch(batchesListProvider).activeCount;
    final todayMarkedCount = attendance.whenOrNull(data: (value) => value) ?? 0;
    final overdueCount = fees.overdueRecords.length;
    final unmarkedAttendanceCount = todayMarkedCount == 0
        ? activeBatchCount
        : 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l.t('dashboard'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline_rounded),
            selectedIcon: const Icon(Icons.people_rounded),
            label: l.t('students'),
          ),
          NavigationDestination(
            icon: NavBadgeIcon(
              icon: Icons.fact_check_outlined,
              count: unmarkedAttendanceCount,
            ),
            selectedIcon: NavBadgeIcon(
              icon: Icons.fact_check_rounded,
              count: unmarkedAttendanceCount,
            ),
            label: l.t('attendance'),
          ),
          NavigationDestination(
            icon: NavBadgeIcon(
              icon: Icons.account_balance_wallet_outlined,
              count: overdueCount,
            ),
            selectedIcon: NavBadgeIcon(
              icon: Icons.account_balance_wallet_rounded,
              count: overdueCount,
            ),
            label: l.t('fees'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l.t('more'),
          ),
        ],
      ),
    );
  }
}
