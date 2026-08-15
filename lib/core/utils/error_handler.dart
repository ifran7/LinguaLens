import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class AppErrorHandler {
  const AppErrorHandler._();

  static void handleError(Object error, StackTrace? stack) {
    if (kDebugMode) {
      debugPrint('ERROR: $error');
      if (stack != null) debugPrint(stack.toString());
    }
  }

  static String getReadableError(Object error) {
    if (error is HiveError) {
      return 'Storage error. Please restart the app.';
    }
    if (error is FileSystemException) {
      return 'File access error. Check permissions.';
    }
    if (error is FormatException) {
      return 'The selected file is not a valid LinguaLens backup.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
