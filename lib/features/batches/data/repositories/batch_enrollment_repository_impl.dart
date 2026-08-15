import 'package:hive/hive.dart';

import '../../../../core/utils/exceptions.dart';
import '../../domain/entities/batch_enrollment_entity.dart';
import '../../domain/repositories/batch_enrollment_repository.dart';
import '../models/batch_enrollment_model.dart';

class BatchEnrollmentRepositoryImpl implements BatchEnrollmentRepository {
  BatchEnrollmentRepositoryImpl({Box<BatchEnrollmentModel>? enrollmentsBox})
    : _enrollmentsBox =
          enrollmentsBox ??
          Hive.box<BatchEnrollmentModel>('batchEnrollmentsBox');

  final Box<BatchEnrollmentModel> _enrollmentsBox;

  List<BatchEnrollmentEntity> _entities() =>
      _enrollmentsBox.values.map(BatchEnrollmentEntity.fromModel).toList();

  @override
  Future<List<BatchEnrollmentEntity>> getAllEnrollments() async => _entities();

  @override
  Future<List<BatchEnrollmentEntity>> getEnrollmentsByBatch(
    String batchId,
  ) async {
    final items = _entities()
        .where(
          (enrollment) => enrollment.batchId == batchId && enrollment.isActive,
        )
        .toList();
    items.sort((a, b) => a.joiningDate.compareTo(b.joiningDate));
    return items;
  }

  @override
  Future<List<BatchEnrollmentEntity>> getEnrollmentsByStudent(
    String studentId,
  ) async {
    final items = _entities()
        .where(
          (enrollment) =>
              enrollment.studentId == studentId && enrollment.isActive,
        )
        .toList();
    items.sort((a, b) => b.joiningDate.compareTo(a.joiningDate));
    return items;
  }

  @override
  Future<BatchEnrollmentEntity?> getEnrollmentById(String id) async {
    final model = _enrollmentsBox.get(id);
    return model == null ? null : BatchEnrollmentEntity.fromModel(model);
  }

  @override
  Future<BatchEnrollmentEntity?> getActiveEnrollment(
    String studentId,
    String batchId,
  ) async {
    for (final enrollment in _entities()) {
      if (enrollment.studentId == studentId &&
          enrollment.batchId == batchId &&
          enrollment.isActive) {
        return enrollment;
      }
    }
    return null;
  }

  @override
  Future<void> enrollStudent(BatchEnrollmentEntity enrollment) async {
    if (await isStudentAlreadyEnrolled(
      enrollment.studentId,
      enrollment.batchId,
    )) {
      throw const StudentAlreadyEnrolledException();
    }
    await _enrollmentsBox.put(enrollment.id, enrollment.toModel());
  }

  @override
  Future<void> updateEnrollment(BatchEnrollmentEntity enrollment) async {
    await _enrollmentsBox.put(
      enrollment.id,
      enrollment.copyWith(updatedAt: DateTime.now()).toModel(),
    );
  }

  @override
  Future<void> removeStudentFromBatch(String enrollmentId) async {
    final enrollment = await getEnrollmentById(enrollmentId);
    if (enrollment != null) {
      await updateEnrollment(enrollment.copyWith(isActive: false));
    }
  }

  @override
  Future<void> deleteEnrollment(String enrollmentId) async {
    await _enrollmentsBox.delete(enrollmentId);
  }

  @override
  Future<void> deleteEnrollmentsByBatch(String batchId) async {
    final keys = _enrollmentsBox.keys
        .where((key) => _enrollmentsBox.get(key)?.batchId == batchId)
        .toList();
    await _enrollmentsBox.deleteAll(keys);
  }

  @override
  Future<void> deleteEnrollmentsByStudent(String studentId) async {
    final keys = _enrollmentsBox.keys
        .where((key) => _enrollmentsBox.get(key)?.studentId == studentId)
        .toList();
    await _enrollmentsBox.deleteAll(keys);
  }

  @override
  Future<int> getEnrolledStudentCount(String batchId) async => _enrollmentsBox
      .values
      .where(
        (enrollment) => enrollment.batchId == batchId && enrollment.isActive,
      )
      .length;

  @override
  Future<bool> isStudentAlreadyEnrolled(
    String studentId,
    String batchId,
  ) async => await getActiveEnrollment(studentId, batchId) != null;
}
