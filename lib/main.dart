import 'dart:ui';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch and log Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    developer.log('Flutter Error', error: details.exception, stackTrace: details.stack);
  };

  // Catch and log asynchronous Dart errors
  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log('Async Error', error: error, stackTrace: stack);
    return true;
  };

  runApp(const BnwemsApp());
}
