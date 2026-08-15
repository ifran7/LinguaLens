import 'package:hive/hive.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({Box<PaymentModel>? box})
    : _box = box ?? Hive.box<PaymentModel>('paymentsBox');

  final Box<PaymentModel> _box;

  @override
  Future<List<PaymentEntity>> getAllPayments() async =>
      _sorted(_box.values.map(PaymentEntity.fromModel).toList());

  @override
  Future<List<PaymentEntity>> getPaymentsByFeeRecord(
    String feeRecordId,
  ) async => _sorted(
    _box.values
        .where((payment) => payment.feeRecordId == feeRecordId)
        .map(PaymentEntity.fromModel)
        .toList(),
    ascending: true,
  );

  @override
  Future<List<PaymentEntity>> getPaymentsByStudent(String studentId) async =>
      _sorted(
        _box.values
            .where((payment) => payment.studentId == studentId)
            .map(PaymentEntity.fromModel)
            .toList(),
      );

  @override
  Future<List<PaymentEntity>> getPaymentsByBatch(String batchId) async =>
      _sorted(
        _box.values
            .where((payment) => payment.batchId == batchId)
            .map(PaymentEntity.fromModel)
            .toList(),
      );

  @override
  Future<List<PaymentEntity>> getPaymentsByMonthKey(String key) async =>
      _sorted(
        _box.values
            .where((payment) => payment.monthKey == key)
            .map(PaymentEntity.fromModel)
            .toList(),
      );

  @override
  Future<List<PaymentEntity>> getPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = normalizeDate(startDate);
    final end = normalizeDate(endDate);
    return _sorted(
      _box.values
          .where((payment) {
            final date = normalizeDate(payment.paymentDate);
            return !date.isBefore(start) && !date.isAfter(end);
          })
          .map(PaymentEntity.fromModel)
          .toList(),
      ascending: true,
    );
  }

  @override
  Future<void> addPayment(PaymentEntity payment) async {
    if (payment.amount <= 0) {
      throw ArgumentError.value(
        payment.amount,
        'amount',
        'Must be greater than zero',
      );
    }
    await _box.put(payment.id, payment.toModel());
  }

  @override
  Future<void> updatePayment(PaymentEntity payment) async {
    if (payment.amount <= 0) {
      throw ArgumentError.value(
        payment.amount,
        'amount',
        'Must be greater than zero',
      );
    }
    await _box.put(
      payment.id,
      payment.copyWith(updatedAt: DateTime.now()).toModel(),
    );
  }

  @override
  Future<void> deletePayment(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> deletePaymentsByFeeRecord(String feeRecordId) async {
    final keys = _box.keys
        .where((key) => _box.get(key)?.feeRecordId == feeRecordId)
        .toList();
    await _box.deleteAll(keys);
  }

  @override
  Future<void> deletePaymentsByStudent(String studentId) async {
    final keys = _box.keys
        .where((key) => _box.get(key)?.studentId == studentId)
        .toList();
    await _box.deleteAll(keys);
  }

  @override
  Future<void> deletePaymentsByBatch(String batchId) async {
    final keys = _box.keys
        .where((key) => _box.get(key)?.batchId == batchId)
        .toList();
    await _box.deleteAll(keys);
  }

  @override
  Future<double> getTotalPaidForFeeRecord(String feeRecordId) async => _box
      .values
      .where((payment) => payment.feeRecordId == feeRecordId)
      .fold<double>(0.0, (sum, payment) => sum + payment.amount);

  @override
  Future<double> getTotalCollectedToday() async {
    final today = normalizeDate(DateTime.now());
    return _box.values
        .where((payment) => isSameNormalizedDate(payment.paymentDate, today))
        .fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }

  @override
  Future<double> getTotalCollectedThisMonth() async {
    final key = monthKey(DateTime.now());
    return _box.values
        .where((payment) => payment.monthKey == key)
        .fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }

  @override
  Future<List<PaymentEntity>> getRecentPayments(int limit) async {
    final payments = _sorted(_box.values.map(PaymentEntity.fromModel).toList());
    return payments.take(limit).toList();
  }

  List<PaymentEntity> _sorted(
    List<PaymentEntity> payments, {
    bool ascending = false,
  }) {
    payments.sort(
      (a, b) => ascending
          ? a.paymentDate.compareTo(b.paymentDate)
          : b.paymentDate.compareTo(a.paymentDate),
    );
    return payments;
  }
}
