import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/batch_entity.dart';
import '../../providers/batch_provider.dart';
import '../widgets/batch_card.dart';

class BatchesListScreen extends ConsumerStatefulWidget {
  const BatchesListScreen({super.key});

  @override
  ConsumerState<BatchesListScreen> createState() => _BatchesListScreenState();
}

class _BatchesListScreenState extends ConsumerState<BatchesListScreen> {
  final _search = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(batchesListProvider.notifier).loadBatches(),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    if (!_showSearch) {
      _search.clear();
      ref.read(batchesListProvider.notifier).searchBatches('');
    }
  }

  Future<void> _showActions(BuildContext context, BatchEntity batch) async {
    final l = context.l10n;
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l.t('editBatch')),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
            ListTile(
              leading: Icon(
                batch.isActive
                    ? Icons.archive_outlined
                    : Icons.unarchive_outlined,
              ),
              title: Text(
                batch.isActive ? l.t('batchArchived') : l.t('batchRestored'),
              ),
              onTap: () => Navigator.pop(context, 'toggle'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                l.t('deleteStudent'),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    if (action == 'edit') {
      context.push('/batches/edit/${batch.id}', extra: batch);
      return;
    }
    if (action == 'toggle') {
      final notifier = ref.read(batchesListProvider.notifier);
      if (batch.isActive) {
        await notifier.archiveBatch(batch.id);
      } else {
        await notifier.restoreBatch(batch.id);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l.t(batch.isActive ? 'batchArchived' : 'batchRestored'),
            ),
          ),
        );
      }
      return;
    }
    if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.t('deleteStudent')),
          content: Text(l.t('confirmDeleteBatch')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l.t('deleteStudent')),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await ref.read(batchesListProvider.notifier).deleteBatch(batch.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l.t('batchDeleted'))));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchesListProvider);
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('batches')),
        leading: const BackButton(),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/batches/add'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.t('addBatch')),
      ),
      body: Column(
        children: [
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _showSearch
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TextField(
                controller: _search,
                autofocus: true,
                onChanged: ref.read(batchesListProvider.notifier).searchBatches,
                decoration: InputDecoration(
                  hintText: l.t('searchBatches'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: _toggleSearch,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
            ),
            secondChild: const SizedBox(height: 8),
          ),
          _FilterRow(state: state),
          Expanded(
            child: _Body(
              state: state,
              onRetry: () =>
                  ref.read(batchesListProvider.notifier).loadBatches(),
              onAdd: () => context.push('/batches/add'),
              onActions: _showActions,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends ConsumerWidget {
  const _FilterRow({required this.state});
  final BatchesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final notifier = ref.read(batchesListProvider.notifier);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _FilterChip(
            label: l.t('allStudents'),
            count: state.allBatches.length,
            selected: state.filterType == BatchFilterType.all,
            onTap: () => notifier.setFilter(BatchFilterType.all),
          ),
          _FilterChip(
            label: l.t('active'),
            count: state.activeCount,
            selected: state.filterType == BatchFilterType.active,
            onTap: () => notifier.setFilter(BatchFilterType.active),
          ),
          _FilterChip(
            label: l.t('archived'),
            count: state.archivedCount,
            selected: state.filterType == BatchFilterType.archived,
            onTap: () => notifier.setFilter(BatchFilterType.archived),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Text('$label  $count'),
      showCheckmark: true,
    ),
  );
}

class _Body extends StatelessWidget {
  const _Body({
    required this.state,
    required this.onRetry,
    required this.onAdd,
    required this.onActions,
  });
  final BatchesState state;
  final VoidCallback onRetry;
  final VoidCallback onAdd;
  final Future<void> Function(BuildContext context, BatchEntity batch)
  onActions;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.allBatches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.allBatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage!),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.t('retry')),
            ),
          ],
        ),
      );
    }
    if (state.filteredBatches.isEmpty) {
      final searching = state.searchQuery.trim().isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                searching ? Icons.search_off_rounded : Icons.groups_rounded,
                size: 56,
                color: Theme.of(context).colorScheme.primary
                    .withValues(alpha: 0.55),
              ),
              const SizedBox(height: 16),
              Text(
                searching
                    ? context.l10n.t('noBatchesFound')
                    : context.l10n.t('noBatchesYet'),
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                searching
                    ? context.l10n.t('tryDifferentSearch')
                    : context.l10n.t('createFirstBatch'),
                textAlign: TextAlign.center,
              ),
              if (!searching) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.l10n.t('createBatch')),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRetry(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        itemCount: state.filteredBatches.length,
        itemBuilder: (context, index) {
          final batch = state.filteredBatches[index];
          return BatchCard(
            batch: batch,
            onTap: () => context.push('/batches/${batch.id}'),
            onLongPress: () => onActions(context, batch),
          );
        },
      ),
    );
  }
}
