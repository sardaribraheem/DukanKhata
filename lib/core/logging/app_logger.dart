import 'dart:developer' as developer;

/// Development-only business event logging. Never include credentials or tokens.
class AppLogger {
  AppLogger._();

  static void business(String event, Map<String, Object?> values) {
    final details = values.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(' | ');
    developer.log('[$event] $details', name: 'DukanKhata.business');
  }

  static void saved(String event, Map<String, Object?> values) {
    business('$event SAVED', values);
  }

  static void loaded(String event, Map<String, Object?> values) {
    business('$event LOADED', values);
  }
}
