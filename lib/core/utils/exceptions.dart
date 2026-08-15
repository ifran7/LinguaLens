class StudentAlreadyEnrolledException implements Exception {
  const StudentAlreadyEnrolledException();

  @override
  String toString() => 'Student is already enrolled in this batch';
}
