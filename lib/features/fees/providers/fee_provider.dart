import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/date_utils.dart';
import '../../batches/domain/entities/batch_entity.dart';
import '../../batches/providers/batch_provider.dart';
import '../../students/providers/student_provider.dart';
import '../data/repositories/fee_repository_impl.dart';
import '../data/repositories/payment_repository_impl.dart';
import '../domain/entities/fee_aggregate.dart';
import '../domain/entities/fee_generation_preview_item.dart';
import '../domain/entities/fee_record_entity.dart';
import '../domain/entities/payment_entity.dart';
import '../domain/entities/student_fee_month_view.dart';
import '../domain/repositories/fee_repository.dart';
import '../domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepositoryImpl(),
);

final feeRepositoryProvider = Provider<FeeRepository>(
  (ref) => FeeRepositoryImpl(ref.read(paymentRepositoryProvider)),
);

class FeeDashboardState {
  const FeeDashboardState({
    required this.selectedMonthKey,
    this.aggregate,
    this.overdueRecords = const [],
    this.recentUnpaid = const [],
    this.recentPayments = const [],
    this.collectedToday = 0,
    this.collectedThisMonth = 0,
    this.isLoading = false,
    this.errorMessage,
  });

  final FeeAggregate? aggregate;
  final List<FeeRecordEntity> overdueRecords;
  final List<FeeRecordEntity> recentUnpaid;
  final List<PaymentEntity> recentPayments;
  final double collectedToday;
  final double collectedThisMonth;
  final bool isLoading;
  final String? errorMessage;
  final String selectedMonthKey;

  FeeDashboardState copyWith({
    FeeAggregate? aggregate,
    List<FeeRecordEntity>? overdueRecords,
    List<FeeRecordEntity>? recentUnpaid,
    List<PaymentEntity>? recentPayments,
    double? collectedToday,
    double? collectedThisMonth,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? selectedMonthKey,
  }) => FeeDashboardState(
    aggregate: aggregate ?? this.aggregate,
    overdueRecords: overdueRecords ?? this.overdueRecords,
    recentUnpaid: recentUnpaid ?? this.recentUnpaid,
    recentPayments: recentPayments ?? this.recentPayments,
    collectedToday: collectedToday ?? this.collectedToday,
    collectedThisMonth: collectedThisMonth ?? this.collectedThisMonth,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    selectedMonthKey: selectedMonthKey ?? this.selectedMonthKey,
  );
}

final feeDashboardProvider =
    NotifierProvider<FeeDashboardNotifier, FeeDashboardState>(
      FeeDashboardNotifier.new,
    );

class FeeDashboardNotifier extends Notifier<FeeDashboardState> {
  @override
  FeeDashboardState build() =>
      FeeDashboardState(selectedMonthKey: monthKey(DateTime.now()));

  Future<void> load([String? selectedKey]) async {
    final key = selectedKey ?? state.selectedMonthKey;
    state = state.copyWith(
      selectedMonthKey: key,
      isLoading: true,
      clearError: true,
    );
    try {
      final feeRepo = ref.read(feeRepositoryProvider);
      final paymentRepo = ref.read(paymentRepositoryProvider);
      final results = await Future.wait([
        feeRepo.getFeeAggregateByMonthKey(key),
        feeRepo.getOverdueFeeRecords(),
        feeRepo.getUnpaidFeeRecords(),
        paymentRepo.getRecentPayments(8),
        paymentRepo.getTotalCollectedToday(),
        paymentRepo.getTotalCollectedThisMonth(),
      ]);
      state = state.copyWith(
        aggregate: results[0] as FeeAggregate,
        overdueRecords: results[1] as List<FeeRecordEntity>,
        recentUnpaid: results[2] as List<FeeRecordEntity>,
        recentPayments: results[3] as List<PaymentEntity>,
        collectedToday: results[4] as double,
        collectedThisMonth: results[5] as double,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<void> changeMonth(String key) => load(key);
}

final feeOverviewProvider =
    FutureProvider.family<List<FeeRecordEntity>, String>((ref, key) async {
      return ref.read(feeRepositoryProvider).getFeeRecordsByMonthKey(key);
    });

final studentFeeHistoryProvider =
    FutureProvider.family<List<StudentFeeMonthView>, String>((
      ref,
      studentId,
    ) async {
      final records = await ref
          .read(feeRepositoryProvider)
          .getFeeRecordsByStudent(studentId);
      final student = await ref
          .read(studentRepositoryProvider)
          .getStudentById(studentId);
      if (student == null) return const [];
      final views = <StudentFeeMonthView>[];
      for (final record in records) {
        final batch = await ref
            .read(batchRepositoryProvider)
            .getBatchById(record.batchId);
        if (batch == null) continue;
        views.add(
          StudentFeeMonthView(
            feeRecord: record,
            payments: await ref
                .read(paymentRepositoryProvider)
                .getPaymentsByFeeRecord(record.id),
            student: student,
            batch: batch,
          ),
        );
      }
      views.sort(
        (a, b) => b.feeRecord.monthKey.compareTo(a.feeRecord.monthKey),
      );
      return views;
    });

final studentFeeSummaryProvider = FutureProvider.family<FeeAggregate, String>(
  (ref, studentId) =>
      ref.read(feeRepositoryProvider).getFeeAggregateByStudent(studentId),
);

final batchFeeSummaryProvider = FutureProvider.family<FeeAggregate, String>(
  (ref, batchId) =>
      ref.read(feeRepositoryProvider).getFeeAggregateByBatch(batchId),
);

final paymentsForFeeRecordProvider =
    FutureProvider.family<List<PaymentEntity>, String>(
      (ref, feeRecordId) => ref
          .read(paymentRepositoryProvider)
          .getPaymentsByFeeRecord(feeRecordId),
    );

final totalDueProvider = FutureProvider<double>(
  (ref) => ref.read(feeRepositoryProvider).getTotalDueAmount(),
);

final collectedThisMonthProvider = FutureProvider<double>(
  (ref) => ref.read(paymentRepositoryProvider).getTotalCollectedThisMonth(),
);

final recentPaymentsProvider = FutureProvider<List<PaymentEntity>>(
  (ref) => ref.read(paymentRepositoryProvider).getRecentPayments(3),
);

class FeeGenerationState {
  const FeeGenerationState({
    required this.selectedMonthKey,
    this.selectedBatchId,
    this.activeBatches = const [],
    this.previewItems = const [],
    this.isLoading = false,
    this.isGenerating = false,
    this.errorMessage,
  });

  final List<BatchEntity> activeBatches;
  final String selectedMonthKey;
  final String? selectedBatchId;
  final List<FeeGenerationPreviewItem> previewItems;
  final bool isLoading;
  final bool isGenerating;
  final String? errorMessage;

  int get newCount => previewItems.where((item) => !item.alreadyExists).length;
  int get existingCount =>
      previewItems.where((item) => item.alreadyExists).length;

  FeeGenerationState copyWith({
    List<BatchEntity>? activeBatches,
    String? selectedMonthKey,
    String? selectedBatchId,
    bool clearBatch = false,
    List<FeeGenerationPreviewItem>? previewItems,
    bool? isLoading,
    bool? isGenerating,
    String? errorMessage,
    bool clearError = false,
  }) => FeeGenerationState(
    activeBatches: activeBatches ?? this.activeBatches,
    selectedMonthKey: selectedMonthKey ?? this.selectedMonthKey,
    selectedBatchId: clearBatch
        ? null
        : selectedBatchId ?? this.selectedBatchId,
    previewItems: previewItems ?? this.previewItems,
    isLoading: isLoading ?? this.isLoading,
    isGenerating: isGenerating ?? this.isGenerating,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

final feeGenerationProvider =
    NotifierProvider.autoDispose<FeeGenerationNotifier, FeeGenerationState>(
      FeeGenerationNotifier.new,
    );

class FeeGenerationNotifier extends Notifier<FeeGenerationState> {
  final Uuid _uuid = const Uuid();

  @override
  FeeGenerationState build() =>
      FeeGenerationState(selectedMonthKey: monthKey(DateTime.now()));

  Future<void> loadPreview([String? selectedKey, String? batchId]) async {
    final key = selectedKey ?? state.selectedMonthKey;
    state = state.copyWith(
      selectedMonthKey: key,
      selectedBatchId: batchId,
      clearBatch: batchId == null,
      isLoading: true,
      clearError: true,
    );
    try {
      final batches = await ref
          .read(batchRepositoryProvider)
          .getActiveBatches();
      final activeBatches = batches;
      final students = await ref
          .read(studentRepositoryProvider)
          .getActiveStudents();
      final studentsById = {
        for (final student in students) student.id: student,
      };
      final lastDay = monthEnd(key);
      final preview = <FeeGenerationPreviewItem>[];
      final feeRepo = ref.read(feeRepositoryProvider);
      for (final batch in activeBatches) {
        if (state.selectedBatchId != null &&
            batch.id != state.selectedBatchId) {
          continue;
        }
        final enrollments = await ref
            .read(enrollmentRepositoryProvider)
            .getEnrollmentsByBatch(batch.id);
        for (final enrollment in enrollments) {
          final student = studentsById[enrollment.studentId];
          if (student == null || !enrollment.isActive) continue;
          if (normalizeDate(enrollment.joiningDate).isAfter(lastDay)) continue;
          final existing = await feeRepo.getFeeRecord(
            student.id,
            batch.id,
            key,
          );
          preview.add(
            FeeGenerationPreviewItem(
              student: student,
              batch: batch,
              enrollment: enrollment,
              effectiveFee: enrollment.effectiveFee(batch.monthlyFeeDefault),
              alreadyExists: existing != null,
              existingRecord: existing,
            ),
          );
        }
      }
      preview.sort((a, b) => a.student.fullName.compareTo(b.student.fullName));
      state = state.copyWith(
        activeBatches: activeBatches,
        previewItems: preview,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.toString());
    }
  }

  Future<int> generateFees() async {
    if (state.isGenerating) return 0;
    state = state.copyWith(isGenerating: true, clearError: true);
    try {
      final now = DateTime.now();
      final feeRepo = ref.read(feeRepositoryProvider);
      var generated = 0;
      for (final item in state.previewItems.where(
        (item) => !item.alreadyExists,
      )) {
        final amount = item.effectiveFee < 0 ? 0.0 : item.effectiveFee;
        await feeRepo.addFeeRecord(
          FeeRecordEntity(
            id: _uuid.v4(),
            studentId: item.student.id,
            batchId: item.batch.id,
            monthKey: state.selectedMonthKey,
            assignedFee: amount,
            discountAmount: 0,
            finalFee: amount,
            createdAt: now,
            updatedAt: now,
          ),
        );
        generated++;
      }
      ref.invalidate(feeDashboardProvider);
      ref.invalidate(feeOverviewProvider(state.selectedMonthKey));
      ref.invalidate(totalDueProvider);
      ref.invalidate(collectedThisMonthProvider);
      ref.invalidate(studentFeeHistoryProvider);
      ref.invalidate(studentFeeSummaryProvider);
      ref.invalidate(batchFeeSummaryProvider);
      state = state.copyWith(isGenerating: false);
      await loadPreview();
      return generated;
    } catch (error) {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: error.toString(),
      );
      return 0;
    }
  }

  Future<void> changeMonth(String key) =>
      loadPreview(key, state.selectedBatchId);

  Future<void> filterBatch(String? batchId) =>
      loadPreview(state.selectedMonthKey, batchId);
}
