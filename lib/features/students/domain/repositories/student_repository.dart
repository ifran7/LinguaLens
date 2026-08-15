import '../entities/student_entity.dart';

abstract class StudentRepository {
  Future<List<StudentEntity>> getAllStudents();
  Future<List<StudentEntity>> getActiveStudents();
  Future<StudentEntity?> getStudentById(String id);
  Future<void> addStudent(StudentEntity student);
  Future<void> updateStudent(StudentEntity student);
  Future<void> deleteStudent(String id);
  Future<void> archiveStudent(String id);
  Future<void> restoreStudent(String id);
  Future<int> getTotalStudentCount();
  Future<int> getActiveStudentCount();
}
