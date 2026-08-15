import '../../../batches/domain/entities/batch_enrollment_entity.dart';
import '../../../batches/domain/entities/batch_entity.dart';
import '../../../students/domain/entities/student_entity.dart';
import 'fee_record_entity.dart';

class FeeGenerationPreviewItem {
  const FeeGenerationPreviewItem({
    required this.student,
    required this.batch,
    required this.enrollment,
    required this.effectiveFee,
    required this.alreadyExists,
    this.existingRecord,
  });

  final StudentEntity student;
  final BatchEntity batch;
  final BatchEnrollmentEntity enrollment;
  final double effectiveFee;
  final bool alreadyExists;
  final FeeRecordEntity? existingRecord;
}
