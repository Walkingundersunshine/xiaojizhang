import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jizhangben/app/app.dart';
import 'package:jizhangben/core/logging/app_logging.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        await AppLogging.initialize();
      } catch (_) {
        // Logging must never prevent the accounting app from starting.
      }

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        AppLogging.reportError(
          source: 'flutter.framework',
          safeMessage: 'Unhandled Flutter framework error',
          error: details.exception,
          stackTrace: details.stack,
        );
      };
      PlatformDispatcher.instance.onError = (error, stackTrace) {
        AppLogging.reportError(
          source: 'dart.platform',
          safeMessage: 'Unhandled platform asynchronous error',
          error: error,
          stackTrace: stackTrace,
        );
        return true;
      };

      runApp(const ProviderScope(child: JizhangbenApp()));
    },
    (error, stackTrace) => AppLogging.reportError(
      source: 'dart.zone',
      safeMessage: 'Unhandled zoned asynchronous error',
      error: error,
      stackTrace: stackTrace,
    ),
  );
}
