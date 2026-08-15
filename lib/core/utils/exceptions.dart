class StudentAlreadyEnrolledException implements Exception {
  const StudentAlreadyEnrolledException();

  @override
  String toString() => 'Student is already enrolled in this batch';
}

class FeeRecordAlreadyExistsException implements Exception {
  const FeeRecordAlreadyExistsException();

  @override
  String toString() =>
      'A fee record already exists for this student, batch, and month';
}
