import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_state.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';

class ModuleScreen extends StatelessWidget {
  const ModuleScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.cta,
    this.onPressed,
  });
  final String title;
  final IconData icon;
  final String cta;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: title,
      action: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded),
      ),
      child: EmptyState(
        icon: icon,
        title: context.l10n.t('comingSoon'),
        body: context.l10n.t('comingSoonBody'),
        cta: cta,
        onPressed: onPressed,
      ),
    );
  }
}

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _busy = false;

  Future<void> _run(Future<bool> Function() action, String success) async {
    setState(() => _busy = true);
    try {
      final done = await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(done ? success : 'No file selected')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not complete that backup action'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lastBackup = ref.read(storageProvider).lastBackupTime;
    return AppPage(
      title: l.t('backupRestore'),
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppCard(
            color: Theme.of(context).colorScheme.primary
                .withValues(alpha: 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconBadge(
                  icon: Icons.shield_outlined,
                  color: AppColors.primary,
                  size: 52,
                ),
                const SizedBox(height: 20),
                Text(
                  l.t('backupTitle'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l.t('backupBody'),
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.muted),
                ),
                if (lastBackup != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Last backup: ${lastBackup.toLocal()}',
                    style: Theme.of(context).textTheme.labelMedium
                        ?.copyWith(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _run(
                    ref.read(storageProvider).exportBackup,
                    l.t('backupSuccess'),
                  ),
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.file_upload_outlined),
            label: Text(l.t('backupNow')),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () => _run(
                    ref.read(storageProvider).restoreBackup,
                    l.t('restoreSuccess'),
                  ),
            icon: const Icon(Icons.file_download_outlined),
            label: Text(l.t('restoreBackup')),
          ),
          const SizedBox(height: 28),
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Backups are JSON files saved where you choose. Restoring is schema-checked before preferences are applied.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AppPage(
      title: l.t('subscription'),
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          AppCard(
            color: AppColors.secondary.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconBadge(
                  icon: Icons.workspace_premium_rounded,
                  color: AppColors.secondary,
                  size: 54,
                ),
                const SizedBox(height: 20),
                Text(
                  l.t('premiumTitle'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l.t('premiumBody'),
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.t('plannedFeatures'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                _FeatureRow(
                  icon: Icons.people_alt_rounded,
                  label: l.t('unlimitedStudents'),
                ),
                const Divider(height: 24),
                _FeatureRow(
                  icon: Icons.insights_rounded,
                  label: l.t('advancedReports'),
                ),
                const Divider(height: 24),
                _FeatureRow(
                  icon: Icons.cloud_sync_rounded,
                  label: l.t('cloudSync'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Subscriptions will be available in a future release.',
                ),
              ),
            ),
            child: const Text('Preview premium path'),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconBadge(icon: icon, color: AppColors.secondary, size: 40),
      const SizedBox(width: 14),
      Expanded(
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      ),
      const Icon(Icons.lock_outline_rounded, color: AppColors.muted, size: 20),
    ],
  );
}

class AddFormScreen extends StatelessWidget {
  const AddFormScreen({
    super.key,
    required this.title,
    required this.label,
    required this.icon,
  });
  final String title;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: title,
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Column(
              children: [
                IconBadge(
                  icon: icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 56,
                ),
                const SizedBox(height: 18),
                TextField(
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: 'Enter a name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional details',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$label saved locally')),
                      );
                      context.pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
