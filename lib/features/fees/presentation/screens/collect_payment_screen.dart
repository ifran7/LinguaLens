import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../batches/domain/entities/batch_enrollment_entity.dart';
import '../../../batches/domain/entities/batch_entity.dart';
import '../../../batches/providers/batch_provider.dart';
import '../../../students/domain/entities/student_entity.dart';
import '../../../students/providers/student_provider.dart';
import '../../../students/presentation/widgets/student_ui_utils.dart';
import '../../domain/entities/fee_record_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_method.dart';
import '../../providers/fee_provider.dart';

class CollectPaymentScreen extends ConsumerStatefulWidget {
  const CollectPaymentScreen({
    super.key,
    required this.studentId,
    required this.batchId,
    required this.monthKey,
    this.feeRecordId,
  });

  final String studentId;
  final String batchId;
  final String monthKey;
  final String? feeRecordId;

  @override
  ConsumerState<CollectPaymentScreen> createState() =>
      _CollectPaymentScreenState();
}

class _CollectPaymentScreenState extends ConsumerState<CollectPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _uuid = const Uuid();
  late Future<_PaymentContextData> _future;
  PaymentMethod _method = PaymentMethod.cash;
  DateTime _paymentDate = normalizeDate(DateTime.now());
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_PaymentContextData> _load() async {
    final errorMessage = context.l10n.t('errorMessage');
    final student = await ref
        .read(studentRepositoryProvider)
        .getStudentById(widget.studentId);
    final batch = await ref
        .read(batchRepositoryProvider)
        .getBatchById(widget.batchId);
    if (student == null || batch == null) {
      throw StateError(errorMessage);
    }
    final existing = await ref
        .read(feeRepositoryProvider)
        .getFeeRecord(widget.studentId, widget.batchId, widget.monthKey);
    final enrollment = await ref
        .read(enrollmentRepositoryProvider)
        .getActiveEnrollment(widget.studentId, widget.batchId);
    final record = existing ?? _draftRecord(batch, enrollment);
    return _PaymentContextData(
      student: student,
      batch: batch,
      enrollment: enrollment,
      record: record,
      isDraft: existing == null,
    );
  }

  FeeRecordEntity _draftRecord(
    BatchEntity batch,
    BatchEnrollmentEntity? enrollment,
  ) {
    final assigned =
        enrollment?.effectiveFee(batch.monthlyFeeDefault) ??
        batch.monthlyFeeDefault;
    final now = DateTime.now();
    return FeeRecordEntity(
      id: '',
      studentId: widget.studentId,
      batchId: widget.batchId,
      monthKey: widget.monthKey,
      assignedFee: assigned,
      finalFee: assigned < 0 ? 0 : assigned,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: normalizeDate(DateTime.now()),
      initialDate: _paymentDate,
    );
    if (selected != null) {
      setState(() => _paymentDate = normalizeDate(selected));
    }
  }

  Future<void> _save(_PaymentContextData data) async {
    if (!_formKey.currentState!.validate() || _saving) return;
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (_paymentDate.isAfter(normalizeDate(DateTime.now()))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('futurePaymentDate'))),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final feeRepo = ref.read(feeRepositoryProvider);
      var record = data.record;
      if (data.isDraft) {
        final now = DateTime.now();
        record = record.copyWith(
          id: _uuid.v4(),
          createdAt: now,
          updatedAt: now,
        );
        try {
          await feeRepo.addFeeRecord(record);
        } catch (_) {
          final existing = await feeRepo.getFeeRecord(
            widget.studentId,
            widget.batchId,
            widget.monthKey,
          );
          if (existing == null) rethrow;
          record = existing;
        }
      }
      await ref
          .read(paymentRepositoryProvider)
          .addPayment(
            PaymentEntity(
              id: _uuid.v4(),
              feeRecordId: record.id,
              studentId: widget.studentId,
              batchId: widget.batchId,
              monthKey: widget.monthKey,
              amount: amount,
              paymentDate: _paymentDate,
              paymentMethod: _method.value,
              note: _noteController.text.trim(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
      _invalidate(record.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.l10n.t('paymentSaved')}: ${formatFee(amount)}',
          ),
        ),
      );
      context.pop();
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  void _invalidate(String feeRecordId) {
    ref.invalidate(paymentsForFeeRecordProvider(feeRecordId));
    ref.invalidate(studentFeeHistoryProvider(widget.studentId));
    ref.invalidate(studentFeeSummaryProvider(widget.studentId));
    ref.invalidate(batchFeeSummaryProvider(widget.batchId));
    ref.invalidate(feeOverviewProvider(widget.monthKey));
    ref.invalidate(feeDashboardProvider);
    ref.invalidate(totalDueProvider);
    ref.invalidate(collectedThisMonthProvider);
    ref.invalidate(recentPaymentsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('collectPayment'))),
      body: FutureBuilder<_PaymentContextData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return EmptyState(
              icon: Icons.error_outline_rounded,
              title: context.l10n.t('errorMessage'),
              body:
                  snapshot.error?.toString() ?? context.l10n.t('errorMessage'),
              cta: context.l10n.t('retry'),
              onPressed: () => setState(() => _future = _load()),
            );
          }
          final data = snapshot.data!;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary
                            .withValues(alpha: 0.12),
                        child: Text(studentInitials(data.student.fullName)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.student.fullName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${data.student.studentCode} • ${data.batch.name}',
                            ),
                            Text(
                              formatMonthKeyDisplay(widget.monthKey),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.t('feeSummary'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 14),
                      _SummaryLine(
                        label: context.l10n.t('assigned'),
                        value: formatFee(data.record.assignedFee),
                      ),
                      _SummaryLine(
                        label: context.l10n.t('discount'),
                        value: formatFee(data.record.discountAmount),
                      ),
                      _SummaryLine(
                        label: context.l10n.t('finalFee'),
                        value: formatFee(data.record.finalFee),
                      ),
                      _SummaryLine(
                        label: context.l10n.t('totalPaid'),
                        value: formatFee(data.record.totalPaid),
                      ),
                      _SummaryLine(
                        label: context.l10n.t('remainingDue'),
                        value: formatFee(data.record.dueAmount),
                        color: data.record.dueAmount > 0
                            ? AppColors.danger
                            : AppColors.success,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: context.l10n.t('amount'),
                    prefixText: '৳ ',
                    hintText: formatFee(data.record.dueAmount),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    if (amount == null || amount <= 0) {
                      return context.l10n.t('amountRequired');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.t('paymentMethod'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final method in PaymentMethod.values)
                      ChoiceChip(
                        avatar: Icon(method.icon, size: 18),
                        label: Text(method.localizedLabel(context)),
                        selected: _method == method,
                        onSelected: (_) => setState(() => _method = method),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_rounded),
                  title: Text(context.l10n.t('paymentDate')),
                  subtitle: Text(formatDayMonthYear(_paymentDate)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: context.l10n.t('paymentNote'),
                    hintText: context.l10n.t('paymentNoteHint'),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : () => _save(data),
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    _saving
                        ? context.l10n.t('savingPayment')
                        : context.l10n.t('savePayment'),
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

class _PaymentContextData {
  const _PaymentContextData({
    required this.student,
    required this.batch,
    required this.enrollment,
    required this.record,
    required this.isDraft,
  });

  final StudentEntity student;
  final BatchEntity batch;
  final BatchEnrollmentEntity? enrollment;
  final FeeRecordEntity record;
  final bool isDraft;
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
