import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class StudentModel extends HiveObject {
  StudentModel({
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
    this.preferredStartTime = '',
    this.preferredWeekdays = const [],
    this.preferredScheduleNote = '',
  });

  @HiveField(0)
  String id;
  @HiveField(1)
  String fullName;
  @HiveField(2)
  String studentCode;
  @HiveField(3)
  String phone;
  @HiveField(4)
  String parentName;
  @HiveField(5)
  String parentPhone;
  @HiveField(6)
  String address;
  @HiveField(7)
  String schoolName;
  @HiveField(8)
  String className;
  @HiveField(9)
  String notes;
  @HiveField(10)
  String photoPath;
  @HiveField(11)
  bool isActive;
  @HiveField(12)
  DateTime createdAt;
  @HiveField(13)
  DateTime updatedAt;
  @HiveField(14)
  String preferredStartTime;
  @HiveField(15)
  List<int> preferredWeekdays;
  @HiveField(16)
  String preferredScheduleNote;

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'studentCode': studentCode,
    'phone': phone,
    'parentName': parentName,
    'parentPhone': parentPhone,
    'address': address,
    'schoolName': schoolName,
    'className': className,
    'notes': notes,
    'photoPath': photoPath,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'preferredStartTime': preferredStartTime,
    'preferredWeekdays': preferredWeekdays,
    'preferredScheduleNote': preferredScheduleNote,
  };

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String? ?? '',
    studentCode: json['studentCode'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    parentName: json['parentName'] as String? ?? '',
    parentPhone: json['parentPhone'] as String? ?? '',
    address: json['address'] as String? ?? '',
    schoolName: json['schoolName'] as String? ?? '',
    className: json['className'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    photoPath: json['photoPath'] as String? ?? '',
    isActive: json['isActive'] as bool? ?? true,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    preferredStartTime: json['preferredStartTime'] as String? ?? '',
    preferredWeekdays: (json['preferredWeekdays'] as List<dynamic>? ?? const [])
        .whereType<num>()
        .map((value) => value.toInt())
        .toList(),
    preferredScheduleNote: json['preferredScheduleNote'] as String? ?? '',
  );
}

class StudentModelAdapter extends TypeAdapter<StudentModel> {
  @override
  final int typeId = 1;

  @override
  StudentModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (var i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };
    return StudentModel(
      id: fields[0] as String,
      fullName: fields[1] as String,
      studentCode: fields[2] as String,
      phone: fields[3] as String? ?? '',
      parentName: fields[4] as String? ?? '',
      parentPhone: fields[5] as String,
      address: fields[6] as String? ?? '',
      schoolName: fields[7] as String? ?? '',
      className: fields[8] as String,
      notes: fields[9] as String? ?? '',
      photoPath: fields[10] as String? ?? '',
      isActive: fields[11] as bool? ?? true,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
      preferredStartTime: fields[14] as String? ?? '',
      preferredWeekdays: (fields[15] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((value) => value.toInt())
          .toList(),
      preferredScheduleNote: fields[16] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, StudentModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.studentCode)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.parentName)
      ..writeByte(5)
      ..write(obj.parentPhone)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.schoolName)
      ..writeByte(8)
      ..write(obj.className)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.photoPath)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.preferredStartTime)
      ..writeByte(15)
      ..write(obj.preferredWeekdays)
      ..writeByte(16)
      ..write(obj.preferredScheduleNote);
  }
}
