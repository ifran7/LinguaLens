import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../providers/settings_provider.dart';

class SettingsCenterScreen extends ConsumerWidget {
  const SettingsCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    return AppPage(
      title: l10n.t('settings'),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    settings.teacherName.isEmpty
                        ? 'T'
                        : settings.teacherName.substring(0, 1).toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.teacherName.isEmpty
                            ? l10n.t('teacherProfile')
                            : settings.teacherName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        settings.teacherPhone.isEmpty
                            ? l10n.t('addTeacherDetails')
                            : settings.teacherPhone,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editProfile(context, ref, settings),
                  icon: const Icon(Icons.edit_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: l10n.t('appearance')),
          AppCard(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.language_rounded,
                  title: l10n.t('language'),
                  subtitle: l10n.t('languageSubtitle'),
                  onTap: () => context.push('/settings/language'),
                ),
                const Divider(height: 8),
                SettingsTile(
                  icon: Icons.brightness_6_rounded,
                  title: l10n.t('theme'),
                  subtitle: l10n.t('themeSubtitle'),
                  onTap: () => context.push('/settings/theme'),
                ),
                const Divider(height: 8),
                SettingsTile(
                  icon: Icons.translate_rounded,
                  title: l10n.t('defaultMessageLanguage'),
                  subtitle: settings.defaultMessageLanguage == 'bn'
                      ? l10n.t('bangla')
                      : l10n.t('english'),
                  trailing: DropdownButton<String>(
                    value: settings.defaultMessageLanguage,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(l10n.t('english')),
                      ),
                      DropdownMenuItem(
                        value: 'bn',
                        child: Text(l10n.t('bangla')),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .setDefaultMessageLanguage(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: l10n.t('dashboardSections')),
          AppCard(
            child: Column(
              children: [
                _ToggleRow(
                  label: l10n.t('fees'),
                  value: settings.showFeesOnDashboard,
                  onChanged: (value) => ref
                      .read(settingsProvider.notifier)
                      .setDashboardVisibility(fees: value),
                ),
                _ToggleRow(
                  label: l10n.t('attendance'),
                  value: settings.showAttendanceOnDashboard,
                  onChanged: (value) => ref
                      .read(settingsProvider.notifier)
                      .setDashboardVisibility(attendance: value),
                ),
                _ToggleRow(
                  label: l10n.t('lessons'),
                  value: settings.showLessonsOnDashboard,
                  onChanged: (value) => ref
                      .read(settingsProvider.notifier)
                      .setDashboardVisibility(lessons: value),
                ),
                _ToggleRow(
                  label: l10n.t('upcomingLessons'),
                  value: settings.showUpcomingLessons,
                  onChanged: (value) => ref
                      .read(settingsProvider.notifier)
                      .setDashboardVisibility(upcoming: value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: l10n.t('dataAndPrivacy')),
          AppCard(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.backup_rounded,
                  title: l10n.t('backupRestore'),
                  subtitle: l10n.t('backupRestoreSubtitle'),
                  onTap: () => context.push('/settings/backup'),
                ),
                const Divider(height: 8),
                SettingsTile(
                  icon: Icons.auto_awesome_rounded,
                  title: l10n.t('subscription'),
                  subtitle: l10n.t('subscriptionSubtitle'),
                  onTap: () => context.push('/settings/subscription'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: l10n.t('about')),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LinguaLens',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.t('aboutLinguaLens'),
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                Text(
                  '${l10n.t('version')} 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
  ) async {
    final name = TextEditingController(text: settings.teacherName);
    final phone = TextEditingController(text: settings.teacherPhone);
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.t('teacherProfile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: context.l10n.t('teacherName'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: context.l10n.t('teacherPhone'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, [name.text.trim(), phone.text.trim()]),
            child: Text(context.l10n.t('save')),
          ),
        ],
      ),
    );
    name.dispose();
    phone.dispose();
    if (result != null) {
      await ref
          .read(settingsProvider.notifier)
          .updateProfile(name: result[0], phone: result[1]);
    }
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    value: value,
    onChanged: onChanged,
  );
}
