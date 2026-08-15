import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<List<PaymentEntity>> getAllPayments();
  Future<List<PaymentEntity>> getPaymentsByFeeRecord(String feeRecordId);
  Future<List<PaymentEntity>> getPaymentsByStudent(String studentId);
  Future<List<PaymentEntity>> getPaymentsByBatch(String batchId);
  Future<List<PaymentEntity>> getPaymentsByMonthKey(String monthKey);
  Future<List<PaymentEntity>> getPaymentsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  Future<void> addPayment(PaymentEntity payment);
  Future<void> updatePayment(PaymentEntity payment);
  Future<void> deletePayment(String id);
  Future<void> deletePaymentsByFeeRecord(String feeRecordId);
  Future<void> deletePaymentsByStudent(String studentId);
  Future<void> deletePaymentsByBatch(String batchId);
  Future<double> getTotalPaidForFeeRecord(String feeRecordId);
  Future<double> getTotalCollectedToday();
  Future<double> getTotalCollectedThisMonth();
  Future<List<PaymentEntity>> getRecentPayments(int limit);
}
