import 'package:hive/hive.dart';

String hiveString(Map<int, dynamic> fields, int index, [String fallback = '']) {
  final value = fields[index];
  return value is String ? value : fallback;
}

bool hiveBool(Map<int, dynamic> fields, int index, [bool fallback = false]) {
  final value = fields[index];
  return value is bool ? value : fallback;
}

int hiveInt(Map<int, dynamic> fields, int index, [int fallback = 0]) {
  final value = fields[index];
  return value is num ? value.toInt() : fallback;
}

double hiveDouble(Map<int, dynamic> fields, int index, [double fallback = 0]) {
  final value = fields[index];
  return value is num ? value.toDouble() : fallback;
}

DateTime hiveDate(Map<int, dynamic> fields, int index, [DateTime? fallback]) {
  final value = fields[index];
  return value is DateTime ? value : (fallback ?? DateTime.now());
}

DateTime? hiveNullableDate(Map<int, dynamic> fields, int index) {
  final value = fields[index];
  return value is DateTime ? value : null;
}

List<String> hiveStringList(Map<int, dynamic> fields, int index) {
  final value = fields[index];
  if (value is! List) return const [];
  return value.whereType<String>().toList();
}

List<int> hiveIntList(Map<int, dynamic> fields, int index) {
  final value = fields[index];
  if (value is! List) return const [];
  return value.whereType<num>().map((item) => item.toInt()).toList();
}

Map<int, dynamic> readHiveFields(BinaryReader reader) => {
  for (var i = 0; i < reader.readByte(); i++) reader.readByte(): reader.read(),
};
