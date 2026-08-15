import '../entities/fee_aggregate.dart';
import '../entities/fee_record_entity.dart';

abstract class FeeRepository {
  Future<List<FeeRecordEntity>> getAllFeeRecords();
  Future<List<FeeRecordEntity>> getFeeRecordsByStudent(String studentId);
  Future<List<FeeRecordEntity>> getFeeRecordsByBatch(String batchId);
  Future<List<FeeRecordEntity>> getFeeRecordsByMonthKey(String monthKey);
  Future<List<FeeRecordEntity>> getFeeRecordsByStudentAndBatch(
    String studentId,
    String batchId,
  );
  Future<FeeRecordEntity?> getFeeRecord(
    String studentId,
    String batchId,
    String monthKey,
  );
  Future<void> addFeeRecord(FeeRecordEntity record);
  Future<void> updateFeeRecord(FeeRecordEntity record);
  Future<void> deleteFeeRecord(String id);
  Future<void> deleteFeeRecordsByStudent(String studentId);
  Future<void> deleteFeeRecordsByBatch(String batchId);
  Future<FeeAggregate> getFeeAggregate();
  Future<FeeAggregate> getFeeAggregateByStudent(String studentId);
  Future<FeeAggregate> getFeeAggregateByBatch(String batchId);
  Future<FeeAggregate> getFeeAggregateByMonthKey(String monthKey);
  Future<double> getTotalDueAmount();
  Future<double> getTotalCollectedThisMonth();
  Future<List<FeeRecordEntity>> getOverdueFeeRecords();
  Future<List<FeeRecordEntity>> getUnpaidFeeRecords();
}
