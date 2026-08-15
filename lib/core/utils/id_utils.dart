import 'package:hive/hive.dart';

Future<String> generateStudentCode() async {
  final metaBox = Hive.box('metaBox');
  final counter =
      (metaBox.get('student_code_counter', defaultValue: 0) as int) + 1;
  await metaBox.put('student_code_counter', counter);
  return 'STU-${counter.toString().padLeft(4, '0')}';
}
