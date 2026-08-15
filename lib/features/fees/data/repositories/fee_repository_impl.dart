import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/exceptions.dart';
import '../../domain/entities/fee_aggregate.dart';
import '../../domain/entities/fee_record_entity.dart';
import '../../domain/entities/fee_status.dart';
import '../../domain/repositories/fee_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/fee_record_model.dart';

class FeeRepositoryImpl implements FeeRepository {
  FeeRepositoryImpl(this._paymentRepository, {Box<FeeRecordModel>? box})
    : _box = box ?? Hive.box<FeeRecordModel>('feeRecordsBox');

  final PaymentRepository _paymentRepository;
  final Box<FeeRecordModel> _box;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<FeeRecordEntity>> getAllFeeRecords() async =>
      _buildEntities(_box.values.toList());

  @override
  Future<List<FeeRecordEntity>> getFeeRecordsByStudent(
    String studentId,
  ) async => _buildEntities(
    _box.values.where((record) => record.studentId == studentId).toList(),
  );

  @override
  Future<List<FeeRecordEntity>> getFeeRecordsByBatch(String batchId) async =>
      _buildEntities(
        _box.values.where((record) => record.batchId == batchId).toList(),
      );

  @override
  Future<List<FeeRecordEntity>> getFeeRecordsByMonthKey(String key) async =>
      _buildEntities(
        _box.values.where((record) => record.monthKey == key).toList(),
      );

  @override
  Future<List<FeeRecordEntity>> getFeeRecordsByStudentAndBatch(
    String studentId,
    String batchId,
  ) async => _buildEntities(
    _box.values
        .where(
          (record) =>
              record.studentId == studentId && record.batchId == batchId,
        )
        .toList(),
  );

  @override
  Future<FeeRecordEntity?> getFeeRecord(
    String studentId,
    String batchId,
    String key,
  ) async {
    final matches = _box.values
        .where(
          (record) =>
              record.studentId == studentId &&
              record.batchId == batchId &&
              record.monthKey == key,
        )
        .toList();
    if (matches.isEmpty) return null;
    final entities = await _buildEntities([matches.first]);
    return entities.first;
  }

  @override
  Future<void> addFeeRecord(FeeRecordEntity record) async {
    final duplicate = _box.values.any(
      (item) =>
          item.studentId == record.studentId &&
          item.batchId == record.batchId &&
          item.monthKey == record.monthKey,
    );
    if (duplicate) throw const FeeRecordAlreadyExistsException();
    final id = record.id.isEmpty ? _uuid.v4() : record.id;
    await _box.put(id, record.copyWith(id: id).toModel());
  }

  @override
  Future<void> updateFeeRecord(FeeRecordEntity record) async {
    await _box.put(
      record.id,
      record.copyWith(updatedAt: DateTime.now()).toModel(),
    );
  }

  @override
  Future<void> deleteFeeRecord(String id) async {
    await _box.delete(id);
    await _paymentRepository.deletePaymentsByFeeRecord(id);
  }

  @override
  Future<void> deleteFeeRecordsByStudent(String studentId) async {
    final records = _box.values
        .where((record) => record.studentId == studentId)
        .toList();
    for (final record in records) {
      await deleteFeeRecord(record.id);
    }
  }

  @override
  Future<void> deleteFeeRecordsByBatch(String batchId) async {
    final records = _box.values
        .where((record) => record.batchId == batchId)
        .toList();
    for (final record in records) {
      await deleteFeeRecord(record.id);
    }
  }

  @override
  Future<FeeAggregate> getFeeAggregate() async =>
      FeeAggregate.fromRecords(await getAllFeeRecords());

  @override
  Future<FeeAggregate> getFeeAggregateByStudent(String studentId) async =>
      FeeAggregate.fromRecords(await getFeeRecordsByStudent(studentId));

  @override
  Future<FeeAggregate> getFeeAggregateByBatch(String batchId) async =>
      FeeAggregate.fromRecords(await getFeeRecordsByBatch(batchId));

  @override
  Future<FeeAggregate> getFeeAggregateByMonthKey(String key) async =>
      FeeAggregate.fromRecords(await getFeeRecordsByMonthKey(key));

  @override
  Future<double> getTotalDueAmount() async {
    final records = await getAllFeeRecords();
    return records.fold<double>(0.0, (sum, record) => sum + record.dueAmount);
  }

  @override
  Future<double> getTotalCollectedThisMonth() async =>
      _paymentRepository.getTotalCollectedThisMonth();

  @override
  Future<List<FeeRecordEntity>> getOverdueFeeRecords() async {
    final current = monthKey(DateTime.now());
    final records = await getAllFeeRecords();
    final overdue = records
        .where(
          (record) =>
              record.monthKey.compareTo(current) < 0 &&
              record.status != FeeStatus.paid,
        )
        .toList();
    overdue.sort((a, b) => a.monthKey.compareTo(b.monthKey));
    return overdue;
  }

  @override
  Future<List<FeeRecordEntity>> getUnpaidFeeRecords() async =>
      (await getAllFeeRecords())
          .where((record) => record.status == FeeStatus.unpaid)
          .toList();

  Future<List<FeeRecordEntity>> _buildEntities(
    List<FeeRecordModel> models,
  ) async {
    final entities = await Future.wait(
      models.map((model) async {
        final paid = await _paymentRepository.getTotalPaidForFeeRecord(
          model.id,
        );
        return FeeRecordEntity.fromModelWithPayments(model, paid);
      }),
    );
    entities.sort((a, b) {
      final byMonth = b.monthKey.compareTo(a.monthKey);
      return byMonth == 0 ? a.studentId.compareTo(b.studentId) : byMonth;
    });
    return entities;
  }
}
