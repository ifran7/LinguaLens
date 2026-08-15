import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../data/models/message_template_model.dart';

class TemplateSeeder {
  const TemplateSeeder._();

  static Future<void> seedIfNeeded() async {
    final box = Hive.box<MessageTemplateModel>('messageTemplatesBox');
    if (box.isNotEmpty) return;
    final now = DateTime.now();
    final templates = [
      MessageTemplateModel(
        id: 'default_fee_reminder',
        title: 'Monthly fee reminder',
        bodyEn: 'Dear {parent_name}, this is a kind reminder that {student_name}\'s fee for {month} is ৳{amount_due}. Thank you. — {teacher_name}',
        bodyBn: 'প্রিয় {parent_name}, {month} মাসে {student_name}-এর বকেয়া ফি ৳{amount_due}। অনুগ্রহ করে সময়মতো পরিশোধ করুন। — {teacher_name}',
        category: 'fee_reminder',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      MessageTemplateModel(
        id: 'default_fee_due',
        title: 'Fee due notice',
        bodyEn: 'Hello {parent_name}, {student_name} has ৳{amount_due} outstanding for {batch_name}. Please contact me if you need any clarification.',
        bodyBn: 'আসসালামু আলাইকুম {parent_name}, {batch_name}-এর জন্য {student_name}-এর ৳{amount_due} বকেয়া রয়েছে। প্রয়োজনে যোগাযোগ করুন।',
        category: 'fee_reminder',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      MessageTemplateModel(
        id: 'default_absence_alert',
        title: 'Attendance alert',
        bodyEn: 'Dear {parent_name}, {student_name} was marked absent from {batch_name}. Please let me know if there is anything I should be aware of.',
        bodyBn: 'প্রিয় {parent_name}, {student_name} আজ {batch_name} ক্লাসে অনুপস্থিত ছিল। কোনো বিষয় থাকলে জানাবেন।',
        category: 'attendance_alert',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      MessageTemplateModel(
        id: 'default_low_attendance',
        title: 'Attendance progress',
        bodyEn: '{student_name}\'s attendance is currently {attendance_percentage}% ({attendance_present_days}/{attendance_total_days} days). Let us work together to keep the learning rhythm strong.',
        bodyBn: '{student_name}-এর উপস্থিতি বর্তমানে {attendance_percentage}% ({attendance_present_days}/{attendance_total_days} দিন)। নিয়মিত ক্লাসে অংশ নিতে উৎসাহিত করুন।',
        category: 'attendance_alert',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      MessageTemplateModel(
        id: 'default_progress_update',
        title: 'Progress update',
        bodyEn: 'Hello {parent_name}, I wanted to share a quick update on {student_name}. We are continuing to build confidence in {subject}.',
        bodyBn: 'আসসালামু আলাইকুম {parent_name}, {student_name}-এর পড়াশোনার একটি সংক্ষিপ্ত আপডেট জানাতে চাই। {subject}-এ আত্মবিশ্বাস তৈরি হচ্ছে।',
        category: 'progress_update',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      MessageTemplateModel(
        id: 'default_payment_confirmation',
        title: 'Payment confirmation',
        bodyEn: 'Thank you, {parent_name}. I received ৳{amount_paid} for {student_name}\'s {month} fee. The remaining due is ৳{amount_due}.',
        bodyBn: 'ধন্যবাদ {parent_name}। {student_name}-এর {month} মাসের ফি বাবদ ৳{amount_paid} পেয়েছি। অবশিষ্ট বকেয়া ৳{amount_due}।',
        category: 'payment_confirmation',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      MessageTemplateModel(
        id: 'default_class_reminder',
        title: 'Class reminder',
        bodyEn: 'Reminder for {parent_name}: {student_name} has a scheduled lesson for {batch_name}. Please help them join on time.',
        bodyBn: '{parent_name}-এর জন্য স্মরণিকা: {student_name}-এর {batch_name} ক্লাস নির্ধারিত আছে। সময়মতো যোগ দিতে সাহায্য করুন।',
        category: 'custom',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      MessageTemplateModel(
        id: const Uuid().v4(),
        title: 'Teacher note follow-up',
        bodyEn:
            'Dear {parent_name}, a note from {teacher_name}: {teacher_note}',
        bodyBn: 'প্রিয় {parent_name}, {teacher_name}-এর একটি বার্তা: {teacher_note}',
        category: 'custom',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    await box.putAll({for (final template in templates) template.id: template});
  }
}
