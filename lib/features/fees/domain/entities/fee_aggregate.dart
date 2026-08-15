import 'fee_record_entity.dart';
import 'fee_status.dart';

class FeeAggregate {
  const FeeAggregate({
    required this.totalAssigned,
    required this.totalCollected,
    required this.totalDiscount,
    required this.paidCount,
    required this.partialCount,
    required this.unpaidCount,
    required this.totalRecordCount,
  });

  final double totalAssigned;
  final double totalCollected;
  final double totalDiscount;
  final int paidCount;
  final int partialCount;
  final int unpaidCount;
  final int totalRecordCount;

  double get totalDue =>
      (totalAssigned - totalCollected).clamp(0, double.infinity);

  factory FeeAggregate.empty() => const FeeAggregate(
    totalAssigned: 0,
    totalCollected: 0,
    totalDiscount: 0,
    paidCount: 0,
    partialCount: 0,
    unpaidCount: 0,
    totalRecordCount: 0,
  );

  factory FeeAggregate.fromRecords(List<FeeRecordEntity> records) {
    var assigned = 0.0;
    var collected = 0.0;
    var discount = 0.0;
    var paid = 0;
    var partial = 0;
    var unpaid = 0;
    for (final record in records) {
      assigned += record.finalFee;
      collected += record.totalPaid;
      discount += record.discountAmount;
      switch (record.status) {
        case FeeStatus.paid:
          paid++;
        case FeeStatus.partial:
          partial++;
        case FeeStatus.unpaid:
          unpaid++;
      }
    }
    return FeeAggregate(
      totalAssigned: assigned,
      totalCollected: collected,
      totalDiscount: discount,
      paidCount: paid,
      partialCount: partial,
      unpaidCount: unpaid,
      totalRecordCount: records.length,
    );
  }
}
