import 'package:hive/hive.dart';

import '../../domain/entities/student_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  Box<StudentModel> get _studentsBox => Hive.box<StudentModel>('studentsBox');

  @override
  Future<List<StudentEntity>> getAllStudents() async {
    final students = _studentsBox.values.map(StudentEntity.fromModel).toList();
    students.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return students;
  }

  @override
  Future<List<StudentEntity>> getActiveStudents() async {
    final students = _studentsBox.values
        .where((student) => student.isActive)
        .map(StudentEntity.fromModel)
        .toList();
    students.sort(
      (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
    );
    return students;
  }

  @override
  Future<StudentEntity?> getStudentById(String id) async {
    final model = _studentsBox.get(id);
    return model == null ? null : StudentEntity.fromModel(model);
  }

  @override
  Future<void> addStudent(StudentEntity student) async {
    await _studentsBox.put(student.id, student.toModel());
  }

  @override
  Future<void> updateStudent(StudentEntity student) async {
    await _studentsBox.put(
      student.id,
      student.copyWith(updatedAt: DateTime.now()).toModel(),
    );
  }

  @override
  Future<void> deleteStudent(String id) async {
    await _studentsBox.delete(id);
    // Related boxes can be added here as later modules are introduced.
    for (final boxName in [
      'attendanceBox',
      'feeRecordsBox',
      'enrollmentsBox',
    ]) {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        final keys = box.keys
            .where((key) => box.get(key)?.studentId == id)
            .toList();
        await box.deleteAll(keys);
      }
    }
  }

  @override
  Future<void> archiveStudent(String id) async {
    final student = await getStudentById(id);
    if (student != null) await updateStudent(student.copyWith(isActive: false));
  }

  @override
  Future<void> restoreStudent(String id) async {
    final student = await getStudentById(id);
    if (student != null) await updateStudent(student.copyWith(isActive: true));
  }

  @override
  Future<int> getTotalStudentCount() async => _studentsBox.length;

  @override
  Future<int> getActiveStudentCount() async =>
      _studentsBox.values.where((student) => student.isActive).length;
}
