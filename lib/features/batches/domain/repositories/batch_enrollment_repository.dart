import '../entities/batch_enrollment_entity.dart';

abstract class BatchEnrollmentRepository {
  Future<List<BatchEnrollmentEntity>> getAllEnrollments();
  Future<List<BatchEnrollmentEntity>> getEnrollmentsByBatch(String batchId);
  Future<List<BatchEnrollmentEntity>> getEnrollmentsByStudent(String studentId);
  Future<BatchEnrollmentEntity?> getEnrollmentById(String id);
  Future<BatchEnrollmentEntity?> getActiveEnrollment(
    String studentId,
    String batchId,
  );
  Future<void> enrollStudent(BatchEnrollmentEntity enrollment);
  Future<void> updateEnrollment(BatchEnrollmentEntity enrollment);
  Future<void> removeStudentFromBatch(String enrollmentId);
  Future<void> deleteEnrollment(String enrollmentId);
  Future<void> deleteEnrollmentsByBatch(String batchId);
  Future<void> deleteEnrollmentsByStudent(String studentId);
  Future<int> getEnrolledStudentCount(String batchId);
  Future<bool> isStudentAlreadyEnrolled(String studentId, String batchId);
}
