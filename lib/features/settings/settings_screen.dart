import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final locale = ref.watch(localeControllerProvider);
    final theme = ref.watch(themeControllerProvider);
    return AppPage(
      title: l.t('settings'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppCard(
            color: Theme.of(context).colorScheme.primary
                .withValues(alpha: 0.08),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.t('appName'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.t('appTagline'),
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            l.t('appearance'),
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.language_rounded,
                  title: l.t('language'),
                  subtitle: locale.languageCode == 'bn'
                      ? l.t('bangla')
                      : l.t('english'),
                  onTap: () => context.push('/settings/language'),
                ),
                const Divider(height: 1),
                SettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: l.t('theme'),
                  subtitle: theme == ThemeMode.dark
                      ? l.t('dark')
                      : l.t('light'),
                  onTap: () => context.push('/settings/theme'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.t('backupRestore'),
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: SettingsTile(
              icon: Icons.shield_outlined,
              title: l.t('backupRestore'),
              subtitle: l.t('backupBody'),
              onTap: () => context.push('/settings/backup'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.t('subscription'),
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: SettingsTile(
              icon: Icons.workspace_premium_outlined,
              title: l.t('subscription'),
              subtitle: l.t('premiumBody'),
              onTap: () => context.push('/settings/subscription'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.t('about'),
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const IconBadge(
                icon: Icons.info_outline_rounded,
                color: AppColors.muted,
              ),
              title: Text(l.t('appName')),
              subtitle: Text('${l.t('version')}\n${l.t('aboutBody')}'),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeControllerProvider).languageCode;
    return AppPage(
      title: context.l10n.t('changeLanguage'),
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.l10n.t('changeLanguage'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the language that feels natural for your teaching day.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              children: [
                _ChoiceTile(
                  title: context.l10n.t('english'),
                  subtitle: 'English',
                  selected: current == 'en',
                  onTap: () async {
                    await ref
                        .read(localeControllerProvider.notifier)
                        .setLocale(const Locale('en'));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Language changed')),
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                _ChoiceTile(
                  title: context.l10n.t('bangla'),
                  subtitle: 'বাংলা',
                  selected: current == 'bn',
                  onTap: () async {
                    await ref
                        .read(localeControllerProvider.notifier)
                        .setLocale(const Locale('bn'));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ভাষা পরিবর্তন হয়েছে')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeControllerProvider);
    return AppPage(
      title: context.l10n.t('chooseTheme'),
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.l10n.t('chooseTheme'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'A quiet canvas helps you stay focused on people and progress.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              children: [
                _ChoiceTile(
                  title: context.l10n.t('light'),
                  subtitle: 'Bright and spacious',
                  icon: Icons.light_mode_rounded,
                  selected: current == ThemeMode.light,
                  onTap: () async {
                    await ref
                        .read(themeControllerProvider.notifier)
                        .setTheme(ThemeMode.light);
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Theme changed')));
                    }
                  },
                ),
                const Divider(height: 1),
                _ChoiceTile(
                  title: context.l10n.t('dark'),
                  subtitle: 'Soft on the eyes',
                  icon: Icons.dark_mode_rounded,
                  selected: current == ThemeMode.dark,
                  onTap: () async {
                    await ref
                        .read(themeControllerProvider.notifier)
                        .setTheme(ThemeMode.dark);
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Theme changed')));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.icon = Icons.check_circle_outline_rounded,
  });
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: IconBadge(
        icon: icon,
        color: selected
            ? Theme.of(context).colorScheme.primary
            : AppColors.muted,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: selected
            ? Icon(
                Icons.check_circle_rounded,
                key: const ValueKey('selected'),
                color: Theme.of(context).colorScheme.primary,
              )
            : const Icon(
                Icons.radio_button_unchecked_rounded,
                key: ValueKey('unselected'),
                color: AppColors.muted,
              ),
      ),
    );
  }
}
