import '../../../batches/domain/entities/batch_entity.dart';
import '../../../students/domain/entities/student_entity.dart';
import 'fee_record_entity.dart';
import 'payment_entity.dart';

class StudentFeeMonthView {
  const StudentFeeMonthView({
    required this.feeRecord,
    required this.payments,
    required this.student,
    required this.batch,
  });

  final FeeRecordEntity feeRecord;
  final List<PaymentEntity> payments;
  final StudentEntity student;
  final BatchEntity batch;
}
