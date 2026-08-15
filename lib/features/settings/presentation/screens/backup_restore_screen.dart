import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../attendance/providers/attendance_provider.dart';
import '../../../batches/providers/batch_provider.dart';
import '../../../fees/providers/fee_provider.dart';
import '../../../lessons/providers/lesson_provider.dart';
import '../../../messages/providers/message_provider.dart';
import '../../../students/providers/student_provider.dart';
import '../../providers/settings_provider.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _busy = false;

  Map<String, int> _counts() {
    final payload = BackupService.instance.buildPayload();
    int count(String key) =>
        payload[key] is List ? (payload[key] as List).length : 0;
    return {
      'students': count('students'),
      'batches': count('batches'),
      'enrollments': count('enrollments'),
      'attendance': count('attendance'),
      'fees': count('feeRecords'),
      'payments': count('payments'),
      'lessons': count('lessons'),
      'syllabusTopics': count('syllabusTopics'),
      'messageTemplates': count('messageTemplates'),
      'messageLogs': count('messageLogs'),
    };
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    final success = await BackupService.instance.exportBackup();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.l10n.t('backupExported')
              : context.l10n.t('backupCancelled'),
        ),
      ),
    );
  }

  Future<void> _restore() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.t('restoreBackup')),
        content: Text(context.l10n.t('restoreWarning')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.t('restore')),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _busy = true);
    try {
      final summary = await BackupService.instance.restoreFromPicker();
      if (!mounted) return;
      setState(() => _busy = false);
      if (summary != null) {
        ref.invalidate(settingsProvider);
        ref.invalidate(studentsListProvider);
        ref.invalidate(batchesListProvider);
        ref.invalidate(attendanceHomeProvider);
        ref.invalidate(feeDashboardProvider);
        ref.invalidate(lessonPlannerProvider);
        ref.invalidate(messageTemplatesProvider);
        ref.invalidate(messageLogsProvider);
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.t('restoreComplete')),
            content: Text(
              '${context.l10n.t('recordsRestored')}: ${summary.total}',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.t('done')),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.l10n.t('restoreFailed')}: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final counts = _counts();
    final storage = LocalStorageService.instance;
    return AppPage(
      title: l10n.t('backupRestore'),
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          AppCard(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('localFirstData'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.t('backupDescription'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: l10n.t('dataSummary')),
          AppCard(
            child: Wrap(
              spacing: 24,
              runSpacing: 18,
              children: [
                for (final entry in counts.entries)
                  SizedBox(
                    width: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.value}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          l10n.t(entry.key),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.file_upload_outlined,
                  title: l10n.t('exportBackup'),
                  subtitle: l10n.t('exportBackupSubtitle'),
                  onTap: _busy ? null : _export,
                ),
                const Divider(height: 8),
                SettingsTile(
                  icon: Icons.file_download_outlined,
                  title: l10n.t('restoreBackup'),
                  subtitle: l10n.t('restoreBackupSubtitle'),
                  onTap: _busy ? null : _restore,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('automaticBackup'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.t('enableAutomaticBackup')),
                  value: ref.watch(settingsProvider).autoBackupEnabled,
                  onChanged: _busy
                      ? null
                      : (value) => ref
                            .read(settingsProvider.notifier)
                            .setAutoBackup(value),
                ),
                if (ref.watch(settingsProvider).autoBackupEnabled)
                  DropdownButtonFormField<int>(
                    initialValue: ref
                        .watch(settingsProvider)
                        .backupIntervalDays,
                    decoration: InputDecoration(
                      labelText: l10n.t('backupFrequency'),
                    ),
                    items: [1, 3, 7, 14, 30]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text('$value ${l10n.t('days')}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .setBackupInterval(value);
                      }
                    },
                  ),
                const SizedBox(height: 12),
                Text(
                  storage.lastBackupTime == null
                      ? l10n.t('noBackupYet')
                      : '${l10n.t('lastBackup')}: ${storage.lastBackupTime!.day}/${storage.lastBackupTime!.month}/${storage.lastBackupTime!.year}',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (_busy) ...[
            const SizedBox(height: 20),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}
