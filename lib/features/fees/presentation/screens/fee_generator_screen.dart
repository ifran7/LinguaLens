import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/fee_generation_preview_item.dart';
import '../../providers/fee_provider.dart';
import '../widgets/month_picker_dialog.dart';

class FeeGeneratorScreen extends ConsumerStatefulWidget {
  const FeeGeneratorScreen({super.key, this.initialMonthKey});

  final String? initialMonthKey;

  @override
  ConsumerState<FeeGeneratorScreen> createState() => _FeeGeneratorScreenState();
}

class _FeeGeneratorScreenState extends ConsumerState<FeeGeneratorScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(feeGenerationProvider.notifier)
          .loadPreview(widget.initialMonthKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feeGenerationProvider);
    final notifier = ref.read(feeGenerationProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('generateFees'))),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadPreview(),
        child: state.isLoading && state.previewItems.isEmpty
            ? ListView(
                children: [
                  SizedBox(height: 280),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : state.errorMessage != null && state.previewItems.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 160),
                  EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: context.l10n.t('errorMessage'),
                    body: state.errorMessage!,
                    cta: context.l10n.t('retry'),
                    onPressed: notifier.loadPreview,
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                children: [
                  _GeneratorFilters(state: state, notifier: notifier),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _CountCard(
                          label: context.l10n.t('newFees'),
                          value: state.newCount.toString(),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CountCard(
                          label: context.l10n.t('alreadyGenerated'),
                          value: state.existingCount.toString(),
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (state.previewItems.isEmpty)
                    EmptyState(
                      icon: Icons.groups_outlined,
                      title: context.l10n.t('noEligibleFeeStudents'),
                      body: context.l10n.t('addStudentsToBatchFirst'),
                      cta: context.l10n.t('viewBatches'),
                      onPressed: () => context.push('/batches'),
                    )
                  else
                    for (final item in state.previewItems)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PreviewTile(item: item),
                      ),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton.icon(
          onPressed: state.newCount == 0 || state.isGenerating
              ? null
              : () => _generate(notifier, state.newCount),
          icon: state.isGenerating
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome_rounded),
          label: Text(
            state.isGenerating
                ? context.l10n.t('generating')
                : '${context.l10n.t('generateFees')} (${state.newCount})',
          ),
        ),
      ),
    );
  }

  Future<void> _generate(FeeGenerationNotifier notifier, int count) async {
    final generated = await notifier.generateFees();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${context.l10n.t('feesGenerated')}: $generated')),
    );
  }
}

class _GeneratorFilters extends StatelessWidget {
  const _GeneratorFilters({required this.state, required this.notifier});

  final FeeGenerationState state;
  final FeeGenerationNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.t('generationSettings'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month_rounded),
            title: Text(context.l10n.t('feeMonth')),
            subtitle: Text(formatMonthKeyDisplay(state.selectedMonthKey)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () async {
              final selected = await showMonthPickerDialog(
                context,
                initialMonthKey: state.selectedMonthKey,
              );
              if (selected != null) notifier.changeMonth(selected);
            },
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String?>(
            initialValue: state.selectedBatchId,
            decoration: InputDecoration(
              labelText: context.l10n.t('selectBatch'),
              prefixIcon: const Icon(Icons.groups_rounded),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(context.l10n.t('allBatches')),
              ),
              ...state.activeBatches.map(
                (batch) => DropdownMenuItem<String?>(
                  value: batch.id,
                  child: Text(batch.name),
                ),
              ),
            ],
            onChanged: notifier.filterBatch,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.t('generationExplanation'),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.item});

  final FeeGenerationPreviewItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.alreadyExists
        ? AppColors.success
        : Theme.of(context).colorScheme.primary;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            item.alreadyExists ? Icons.check_rounded : Icons.add_rounded,
            color: color,
          ),
        ),
        title: Text(item.student.fullName),
        subtitle: Text('${item.batch.name} • ${formatFee(item.effectiveFee)}'),
        trailing: Text(
          item.alreadyExists
              ? context.l10n.t('exists')
              : context.l10n.t('newFee'),
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: color),
        ),
      ),
    );
  }
}
