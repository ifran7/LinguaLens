import '../../data/models/student_model.dart';

class StudentEntity {
  const StudentEntity({
    required this.id,
    required this.fullName,
    required this.studentCode,
    this.phone = '',
    this.parentName = '',
    required this.parentPhone,
    this.address = '',
    this.schoolName = '',
    required this.className,
    this.notes = '',
    this.photoPath = '',
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String studentCode;
  final String phone;
  final String parentName;
  final String parentPhone;
  final String address;
  final String schoolName;
  final String className;
  final String notes;
  final String photoPath;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  StudentEntity copyWith({
    String? id,
    String? fullName,
    String? studentCode,
    String? phone,
    String? parentName,
    String? parentPhone,
    String? address,
    String? schoolName,
    String? className,
    String? notes,
    String? photoPath,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => StudentEntity(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    studentCode: studentCode ?? this.studentCode,
    phone: phone ?? this.phone,
    parentName: parentName ?? this.parentName,
    parentPhone: parentPhone ?? this.parentPhone,
    address: address ?? this.address,
    schoolName: schoolName ?? this.schoolName,
    className: className ?? this.className,
    notes: notes ?? this.notes,
    photoPath: photoPath ?? this.photoPath,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  StudentModel toModel() => StudentModel(
    id: id,
    fullName: fullName,
    studentCode: studentCode,
    phone: phone,
    parentName: parentName,
    parentPhone: parentPhone,
    address: address,
    schoolName: schoolName,
    className: className,
    notes: notes,
    photoPath: photoPath,
    isActive: isActive,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static StudentEntity fromModel(StudentModel model) => StudentEntity(
    id: model.id,
    fullName: model.fullName,
    studentCode: model.studentCode,
    phone: model.phone,
    parentName: model.parentName,
    parentPhone: model.parentPhone,
    address: model.address,
    schoolName: model.schoolName,
    className: model.className,
    notes: model.notes,
    photoPath: model.photoPath,
    isActive: model.isActive,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is StudentEntity &&
      other.id == id &&
      other.fullName == fullName &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(id, fullName, updatedAt);
}
