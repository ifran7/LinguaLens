import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final modules = [
      _MoreItem(
        'batches',
        Icons.groups_rounded,
        AppColors.secondary,
        '/batches',
      ),
      _MoreItem(
        'lessons',
        Icons.menu_book_rounded,
        AppColors.success,
        '/lessons',
      ),
      _MoreItem(
        'messages',
        Icons.chat_bubble_rounded,
        const Color(0xFF0EA5A4),
        '/messages',
      ),
      _MoreItem(
        'fees',
        Icons.account_balance_wallet_rounded,
        AppColors.warning,
        '/fees',
      ),
      _MoreItem('settings', Icons.tune_rounded, AppColors.primary, '/settings'),
      _MoreItem(
        'backupRestore',
        Icons.cloud_upload_rounded,
        const Color(0xFF7C3AED),
        '/settings/backup',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('more')),
        actions: [
          IconButton(
            tooltip: l.t('search'),
            onPressed: () => context.push('/search'),
            icon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text(
            l.t('moreTitle'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            l.t('moreSubtitle'),
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final item = modules[index];
              return Semantics(
                button: true,
                label: l.t(item.labelKey),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => context.push(item.route),
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconBadge(icon: item.icon, color: item.color, size: 46),
                        Text(
                          l.t(item.labelKey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem(this.labelKey, this.icon, this.color, this.route);

  final String labelKey;
  final IconData icon;
  final Color color;
  final String route;
}
