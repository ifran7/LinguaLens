import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../batches/domain/entities/batch_entity.dart';
import '../../../batches/providers/batch_provider.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/providers/student_provider.dart';
import '../../domain/entities/fee_record_entity.dart';
import '../../domain/entities/fee_status.dart';
import '../../providers/fee_provider.dart';
import '../widgets/fee_record_card.dart';
import '../widgets/month_picker_dialog.dart';

class FeeOverviewScreen extends ConsumerStatefulWidget {
  const FeeOverviewScreen({
    super.key,
    this.initialMonthKey,
    this.showOverdue = false,
  });

  final String? initialMonthKey;
  final bool showOverdue;

  @override
  ConsumerState<FeeOverviewScreen> createState() => _FeeOverviewScreenState();
}

class _FeeOverviewScreenState extends ConsumerState<FeeOverviewScreen> {
  late String _monthKey;
  late Future<_FeeOverviewData> _future;
  FeeStatus? _status;
  String? _batchId;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _monthKey = widget.initialMonthKey ?? monthKey(DateTime.now());
    _future = _load(_monthKey);
  }

  Future<_FeeOverviewData> _load(String key) async {
    final records = await ref
        .read(feeRepositoryProvider)
        .getFeeRecordsByMonthKey(key);
    final students = await ref.read(studentRepositoryProvider).getAllStudents();
    final batches = await ref.read(batchRepositoryProvider).getAllBatches();
    return _FeeOverviewData(
      records: records,
      students: {for (final student in students) student.id: student},
      batches: {for (final batch in batches) batch.id: batch},
    );
  }

  void _changeMonth(String key) {
    setState(() {
      _monthKey = key;
      _future = _load(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.t('feeOverview')),
        actions: [
          IconButton(
            tooltip: context.l10n.t('selectMonth'),
            onPressed: () async {
              final selected = await showMonthPickerDialog(
                context,
                initialMonthKey: _monthKey,
              );
              if (selected != null) _changeMonth(selected);
            },
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/fees/generate?monthKey=$_monthKey'),
        icon: const Icon(Icons.auto_awesome_rounded),
        label: Text(context.l10n.t('generateFees')),
      ),
      body: FutureBuilder<_FeeOverviewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: context.l10n.t('errorMessage'),
              body: snapshot.error.toString(),
              cta: context.l10n.t('retry'),
              onPressed: () => setState(() => _future = _load(_monthKey)),
            );
          }
          final data = snapshot.data!;
          final filtered = data.records.where((record) {
            final student = data.students[record.studentId];
            final matchesSearch =
                _search.trim().isEmpty ||
                (student?.fullName.toLowerCase().contains(
                      _search.trim().toLowerCase(),
                    ) ??
                    false) ||
                (student?.studentCode.toLowerCase().contains(
                      _search.trim().toLowerCase(),
                    ) ??
                    false);
            final matchesStatus = _status == null || record.status == _status;
            final matchesBatch = _batchId == null || record.batchId == _batchId;
            final matchesOverdue =
                !widget.showOverdue || record.status != FeeStatus.paid;
            return matchesSearch &&
                matchesStatus &&
                matchesBatch &&
                matchesOverdue;
          }).toList();
          return RefreshIndicator(
            onRefresh: () async => setState(() => _future = _load(_monthKey)),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _changeMonth(
                          monthKey(
                            DateTime(
                              monthKeyToDate(_monthKey).year,
                              monthKeyToDate(_monthKey).month - 1,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Text(
                          formatMonthKeyDisplay(_monthKey),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _changeMonth(
                          monthKey(
                            DateTime(
                              monthKeyToDate(_monthKey).year,
                              monthKeyToDate(_monthKey).month + 1,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: InputDecoration(
                    labelText: context.l10n.t('searchStudents'),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () => setState(() => _search = ''),
                            icon: const Icon(Icons.clear_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text(context.l10n.t('all')),
                        selected: _status == null,
                        onSelected: (_) => setState(() => _status = null),
                      ),
                      const SizedBox(width: 8),
                      for (final status in FeeStatus.values) ...[
                        ChoiceChip(
                          label: Text(status.localizedLabel(context)),
                          selected: _status == status,
                          onSelected: (_) => setState(() => _status = status),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: _batchId,
                  decoration: InputDecoration(
                    labelText: context.l10n.t('selectBatch'),
                    prefixIcon: const Icon(Icons.groups_rounded),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(context.l10n.t('allBatches')),
                    ),
                    ...data.batches.values.map(
                      (batch) => DropdownMenuItem<String?>(
                        value: batch.id,
                        child: Text(batch.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _batchId = value),
                ),
                const SizedBox(height: 20),
                if (filtered.isEmpty)
                  EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: context.l10n.t('noFeeRecordsThisMonth'),
                    body: context.l10n.t('generateFeesToCreate'),
                    cta: context.l10n.t('generateFees'),
                    onPressed: () =>
                        context.push('/fees/generate?monthKey=$_monthKey'),
                  )
                else
                  for (final record in filtered)
                    if (data.students[record.studentId] != null &&
                        data.batches[record.batchId] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FeeRecordCard(
                          record: record,
                          student: data.students[record.studentId]!,
                          batch: data.batches[record.batchId]!,
                          onTap: () =>
                              context.push('/fees/student/${record.studentId}'),
                          onCollect: record.status == FeeStatus.paid
                              ? null
                              : () => context.push(
                                  '/fees/collect?studentId=${record.studentId}&batchId=${record.batchId}&monthKey=${record.monthKey}&feeRecordId=${record.id}',
                                ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FeeOverviewData {
  const _FeeOverviewData({
    required this.records,
    required this.students,
    required this.batches,
  });

  final List<FeeRecordEntity> records;
  final Map<String, StudentEntity> students;
  final Map<String, BatchEntity> batches;
}
