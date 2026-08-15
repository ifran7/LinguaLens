import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/app_initializer.dart';
import 'core/utils/error_handler.dart';

Future<void> main() async {
  FlutterError.onError = (details) {
    AppErrorHandler.handleError(details.exception, details.stack);
  };
  Object? startupError;
  try {
    await AppInitializer.initializeApp();
  } catch (error, stack) {
    startupError = error;
    AppErrorHandler.handleError(error, stack);
  }
  runApp(ProviderScope(child: LinguaLensApp(startupError: startupError)));
}
