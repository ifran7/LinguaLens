import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('bn')];

  static const _en = <String, String>{
    'appName': 'LinguaLens',
    'appTagline': 'A calmer way to teach',
    'welcome': 'Welcome back, teacher',
    'dashboard': 'Dashboard',
    'students': 'Students',
    'batches': 'Batches',
    'attendance': 'Attendance',
    'fees': 'Fees',
    'lessons': 'Lessons',
    'messages': 'Messages',
    'settings': 'Settings',
    'manageTeaching': 'Your teaching, at a glance',
    'todayFocus': 'Today’s focus',
    'quickActions': 'Quick actions',
    'recentActivity': 'Recent activity',
    'viewAll': 'View all',
    'totalStudents': 'Total students',
    'activeBatches': 'Active batches',
    'pendingFees': 'Pending fees',
    'attendanceToday': 'Attendance today',
    'onboarding1Title': 'Keep every student in view',
    'onboarding1Body':
        'Organize profiles, batches, and parent details in one calm workspace.',
    'onboarding2Title': 'Stay ahead of the month',
    'onboarding2Body': 'Track attendance, fees, and lesson plans without the spreadsheet shuffle.',
    'onboarding3Title': 'Built for your routine',
    'onboarding3Body': 'Use English or Bangla, choose your theme, and keep a local backup in your control.',
    'skip': 'Skip',
    'next': 'Next',
    'getStarted': 'Get started',
    'appearance': 'Appearance',
    'language': 'Language',
    'theme': 'Theme',
    'backupRestore': 'Backup & restore',
    'subscription': 'Premium features',
    'about': 'About',
    'light': 'Light',
    'dark': 'Dark',
    'english': 'English',
    'bangla': 'বাংলা',
    'backupTitle': 'Your data stays close',
    'backupBody': 'Export a portable backup whenever you need peace of mind.',
    'backupNow': 'Back up now',
    'restoreBackup': 'Restore backup',
    'backupSuccess': 'Backup saved successfully',
    'restoreSuccess': 'Backup restored successfully',
    'comingSoon': 'Coming next in your build sequence',
    'comingSoonBody': 'The foundation is ready. This module will grow into a focused workspace for your daily teaching flow.',
    'addStudent': 'Add student',
    'addBatch': 'Add batch',
    'startMarking': 'Start marking',
    'recordPayment': 'Record payment',
    'planLesson': 'Plan a lesson',
    'messageParent': 'Message a parent',
    'openBackup': 'Open backup',
    'noRecentActivity': 'No recent activity yet',
    'noRecentActivityBody':
        'Add your first student or batch to make this dashboard yours.',
    'aboutBody': 'LinguaLens is a local-first teaching companion. Account sync and Google login are reserved for a future release.',
    'version': 'Version 0.1.0',
    'changeLanguage': 'Change language',
    'chooseTheme': 'Choose your theme',
    'premiumTitle': 'A little more room to grow',
    'premiumBody': 'Premium architecture is ready for future features such as reports, cloud sync, and advanced templates.',
    'plannedFeatures': 'Planned features',
    'unlimitedStudents': 'Unlimited students',
    'advancedReports': 'Advanced reports',
    'cloudSync': 'Cloud sync',
  };

  static const _bn = <String, String>{
    'appName': 'লিঙ্গুয়ালেন্স',
    'appTagline': 'পড়ানোর আরও সহজ উপায়',
    'welcome': 'স্বাগতম, শিক্ষক',
    'dashboard': 'ড্যাশবোর্ড',
    'students': 'শিক্ষার্থী',
    'batches': 'ব্যাচ',
    'attendance': 'উপস্থিতি',
    'fees': 'ফি',
    'lessons': 'পাঠ পরিকল্পনা',
    'messages': 'বার্তা',
    'settings': 'সেটিংস',
    'manageTeaching': 'আপনার পড়ানো, এক নজরে',
    'todayFocus': 'আজকের ফোকাস',
    'quickActions': 'দ্রুত কাজ',
    'recentActivity': 'সাম্প্রতিক কার্যক্রম',
    'viewAll': 'সব দেখুন',
    'totalStudents': 'মোট শিক্ষার্থী',
    'activeBatches': 'সক্রিয় ব্যাচ',
    'pendingFees': 'বকেয়া ফি',
    'attendanceToday': 'আজকের উপস্থিতি',
    'onboarding1Title': 'প্রতিটি শিক্ষার্থীকে কাছে রাখুন',
    'onboarding1Body': 'প্রোফাইল, ব্যাচ এবং অভিভাবকের তথ্য এক জায়গায় গোছান।',
    'onboarding2Title': 'মাসের হিসাব সহজ রাখুন',
    'onboarding2Body':
        'স্প্রেডশিট ছাড়াই উপস্থিতি, ফি এবং পাঠ পরিকল্পনা দেখুন।',
    'onboarding3Title': 'আপনার রুটিনের জন্য তৈরি',
    'onboarding3Body':
        'বাংলা বা ইংরেজি বেছে নিন, থিম বদলান, আর নিজের স্থানীয় ব্যাকআপ রাখুন।',
    'skip': 'এড়িয়ে যান',
    'next': 'পরবর্তী',
    'getStarted': 'শুরু করুন',
    'appearance': 'দেখতে কেমন হবে',
    'language': 'ভাষা',
    'theme': 'থিম',
    'backupRestore': 'ব্যাকআপ ও পুনরুদ্ধার',
    'subscription': 'প্রিমিয়াম ফিচার',
    'about': 'অ্যাপ সম্পর্কে',
    'light': 'লাইট',
    'dark': 'ডার্ক',
    'english': 'English',
    'bangla': 'বাংলা',
    'backupTitle': 'আপনার ডেটা আপনার কাছেই',
    'backupBody': 'নির্ভরতার জন্য যেকোনো সময় একটি ব্যাকআপ নিন।',
    'backupNow': 'ব্যাকআপ নিন',
    'restoreBackup': 'ব্যাকআপ ফিরিয়ে আনুন',
    'backupSuccess': 'ব্যাকআপ সফলভাবে সংরক্ষিত হয়েছে',
    'restoreSuccess': 'ব্যাকআপ সফলভাবে ফিরিয়ে আনা হয়েছে',
    'comingSoon': 'আপনার বিল্ড সিকোয়েন্সে শিগগিরই আসছে',
    'comingSoonBody': 'ভিত্তি প্রস্তুত। এই মডিউলটি আপনার দৈনন্দিন পড়ানোর কাজে আরও ফোকাসড হবে।',
    'addStudent': 'শিক্ষার্থী যোগ করুন',
    'addBatch': 'ব্যাচ যোগ করুন',
    'startMarking': 'উপস্থিতি নিন',
    'recordPayment': 'পেমেন্ট লিখুন',
    'planLesson': 'পাঠ পরিকল্পনা',
    'messageParent': 'অভিভাবককে বার্তা',
    'openBackup': 'ব্যাকআপ খুলুন',
    'noRecentActivity': 'এখনও কোনো কার্যক্রম নেই',
    'noRecentActivityBody':
        'প্রথম শিক্ষার্থী বা ব্যাচ যোগ করলে ড্যাশবোর্ডটি আপনার হয়ে উঠবে।',
    'aboutBody': 'লিঙ্গুয়ালেন্স একটি লোকাল-ফার্স্ট টিচিং কমপ্যানিয়ন। অ্যাকাউন্ট সিঙ্ক ও গুগল লগইন ভবিষ্যৎ সংস্করণের জন্য রাখা হয়েছে।',
    'version': 'সংস্করণ ০.১.০',
    'changeLanguage': 'ভাষা বদলান',
    'chooseTheme': 'আপনার থিম বেছে নিন',
    'premiumTitle': 'আরও বড় হওয়ার জায়গা',
    'premiumBody': 'রিপোর্ট, ক্লাউড সিঙ্ক এবং উন্নত টেমপ্লেটের মতো ফিচারের জন্য প্রিমিয়াম আর্কিটেকচার প্রস্তুত।',
    'plannedFeatures': 'পরিকল্পিত ফিচার',
    'unlimitedStudents': 'সীমাহীন শিক্ষার্থী',
    'advancedReports': 'উন্নত রিপোর্ট',
    'cloudSync': 'ক্লাউড সিঙ্ক',
  };

  String t(String key) => (locale.languageCode == 'bn' ? _bn : _en)[key] ?? key;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'bn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension LocalizationX on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizations(const Locale('en'));
}
