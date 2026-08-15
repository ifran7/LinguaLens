/// Canonical application routes.
class RouteNames {
  const RouteNames._();

  static const shell = '/';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const students = '/students';
  static const studentAdd = '/students/add';
  static const studentEdit = '/students/edit/:id';
  static const studentDetail = '/students/:id';
  static const batches = '/batches';
  static const batchAdd = '/batches/add';
  static const batchEdit = '/batches/edit/:id';
  static const batchDetail = '/batches/:id';
  static const batchEnroll = '/batches/:id/enroll';
  static const batchSyllabus = '/batches/:id/syllabus';
  static const attendance = '/attendance';
  static const attendanceBatch = '/attendance/batch/:batchId';
  static const attendanceCalendar = '/attendance/student/:id/calendar';
  static const fees = '/fees';
  static const feeOverview = '/fees/overview';
  static const feeStudent = '/fees/student/:studentId';
  static const feeCollect = '/fees/collect';
  static const feeGenerate = '/fees/generate';
  static const lessons = '/lessons';
  static const lessonAdd = '/lessons/new';
  static const lessonEdit = '/lessons/edit/:id';
  static const lessonDetail = '/lessons/:id';
  static const messages = '/messages';
  static const messageCompose = '/messages/compose';
  static const messageTemplates = '/messages/templates';
  static const messageLogs = '/messages/logs';
  static const settings = '/settings';
  static const settingsLanguage = '/settings/language';
  static const settingsTheme = '/settings/theme';
  static const settingsBackup = '/settings/backup';
  static const settingsSubscription = '/settings/subscription';
  static const search = '/search';
}
