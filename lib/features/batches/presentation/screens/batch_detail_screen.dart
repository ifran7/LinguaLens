import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../domain/entities/batch_entity.dart';
import '../../providers/batch_provider.dart';
import '../widgets/batch_student_list.dart';

class BatchDetailScreen extends ConsumerStatefulWidget {
  const BatchDetailScreen({super.key, required this.batchId, this.batch});

  final String batchId;
  final BatchEntity? batch;

  @override
  ConsumerState<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends ConsumerState<BatchDetailScreen> {
  BatchEntity? _batch;

  @override
  void initState() {
    super.initState();
    _batch = widget.batch;
  }

  Future<void> _deleteBatch(BatchEntity batch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.t('deleteStudent')),
        content: Text(context.l10n.t('confirmDeleteBatch')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.t('deleteStudent')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(batchesListProvider.notifier).deleteBatch(batch.id);
      if (mounted) context.go('/batches');
    }
  }

  Future<void> _toggleArchive(BatchEntity batch) async {
    final notifier = ref.read(batchesListProvider.notifier);
    if (batch.isActive) {
      await notifier.archiveBatch(batch.id);
    } else {
      await notifier.restoreBatch(batch.id);
    }
    if (mounted) {
      setState(() => _batch = batch.copyWith(isActive: !batch.isActive));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final resolved = ref.watch(batchDetailProvider(widget.batchId));
    return resolved.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l.t('batchDetails'))),
        body: Center(child: Text(error.toString())),
      ),
      data: (loaded) {
        final batch = _batch ?? loaded;
        if (batch == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l.t('batchDetails'))),
            body: Center(child: Text(l.t('batchNotFound'))),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(l.t('batchDetails')),
            leading: const BackButton(),
            actions: [
              IconButton(
                onPressed: () =>
                    context.push('/batches/edit/${batch.id}', extra: batch),
                icon: const Icon(Icons.edit_outlined),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'archive') _toggleArchive(batch);
                  if (value == 'delete') _deleteBatch(batch);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'archive',
                    child: Text(
                      batch.isActive
                          ? l.t('batchArchived')
                          : l.t('batchRestored'),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l.t('deleteStudent')),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(batchDetailProvider(widget.batchId));
              ref.invalidate(batchStudentCountProvider(widget.batchId));
              ref.invalidate(batchEnrollmentsProvider(widget.batchId));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _Header(batch: batch),
                const SizedBox(height: 18),
                _OverviewCard(batch: batch),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.t('enrolledStudents'),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push(
                        '/batches/${batch.id}/enroll',
                        extra: batch,
                      ),
                      icon: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 18,
                      ),
                      label: Text(l.t('enrollStudent')),
                    ),
                  ],
                ),
                BatchStudentList(
                  batch: batch,
                  onEnroll: () =>
                      context.push('/batches/${batch.id}/enroll', extra: batch),
                ),
                const SizedBox(height: 18),
                _PlaceholderCard(
                  icon: Icons.payments_outlined,
                  title: l.t('feeOverview'),
                  body: l.t('noFeeOverview'),
                  action: l.t('viewFees'),
                ),
                const SizedBox(height: 12),
                _PlaceholderCard(
                  icon: Icons.menu_book_outlined,
                  title: l.t('lessonPlans'),
                  body: l.t('noLessonPlans'),
                  action: l.t('addLesson'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.batch});
  final BatchEntity batch;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [batch.color, batch.color.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batch.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    batch.subject,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      batch.isActive
                          ? context.l10n.t('batchActive')
                          : context.l10n.t('batchArchivedStatus'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends ConsumerWidget {
  const _OverviewCard({required this.batch});
  final BatchEntity batch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(batchStudentCountProvider(batch.id));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.t('batchDetails'),
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.schedule_outlined,
              label: context.l10n.t('schedule'),
              value: batch.scheduleText.isEmpty ? '—' : batch.scheduleText,
            ),
            _InfoRow(
              icon: Icons.payments_outlined,
              label: context.l10n.t('defaultMonthlyFee'),
              value:
                  '${formatFee(batch.monthlyFeeDefault)}${context.l10n.t('perMonth')}',
            ),
            _InfoRow(
              icon: Icons.people_alt_outlined,
              label: context.l10n.t('enrolledStudents'),
              value: count.when(
                data: (value) => '$value',
                loading: () => '…',
                error: (_, _) => '—',
              ),
            ),
            _InfoRow(
              icon: Icons.event_outlined,
              label: context.l10n.t('created'),
              value: DateFormat('dd MMM yyyy').format(batch.createdAt),
            ),
            if (batch.description.isNotEmpty)
              _InfoRow(
                icon: Icons.notes_outlined,
                label: context.l10n.t('description'),
                value: batch.description,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 118,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
  });
  final IconData icon;
  final String title;
  final String body;
  final String action;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          TextButton(onPressed: null, child: Text(action)),
        ],
      ),
    ),
  );
}
