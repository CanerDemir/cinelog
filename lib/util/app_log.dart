import 'package:flutter/foundation.dart';

/// Debug logging; never use for secrets.
void appLog(String message, [Object? error, StackTrace? stack]) {
  debugPrint('[CineLog] $message');
  if (error != null) {
    debugPrint('[CineLog] error: $error');
  }
  if (stack != null) {
    debugPrintStack(stackTrace: stack, label: 'CineLog');
  }
}
