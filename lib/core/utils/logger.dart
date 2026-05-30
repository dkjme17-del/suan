import 'package:flutter/foundation.dart';

/// Classe pour gérer les messages de log
class Logger {
  static const String _tag = '[SUAN]';
  static const bool _isDebugMode = kDebugMode;

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_isDebugMode) {
      print('$_tag [DEBUG] $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  static void info(String message) {
    if (_isDebugMode) {
      print('$_tag [INFO] $message');
    }
  }

  static void warning(String message) {
    if (_isDebugMode) {
      print('$_tag [WARNING] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_isDebugMode) {
      print('$_tag [ERROR] $message');
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }
}
