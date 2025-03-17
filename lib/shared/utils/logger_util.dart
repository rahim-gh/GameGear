import 'package:logger/logger.dart';

/// A robust, enterprise-grade logger that allows for dynamic configuration.
/// This class leverages the singleton pattern to ensure consistent logging
/// throughout your application while providing static helpers for ease of use.
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  late Logger _logger;

  /// Factory constructor with optional dependency injection for customization.
  factory AppLogger({
    PrettyPrinter? printer,
    LogOutput? output,
    LogFilter? filter,
  }) {
    _instance._configure(
      printer: printer,
      output: output,
      filter: filter,
    );
    return _instance;
  }

  AppLogger._internal() {
    _configure();
  }

  /// Configures the logger with provided or default settings.
  void _configure({
    PrettyPrinter? printer,
    LogOutput? output,
    LogFilter? filter,
  }) {
    _logger = Logger(
      printer: printer ??
          PrettyPrinter(
            colors: true,
            printEmojis: true,
            dateTimeFormat: DateTimeFormat.onlyTime,
          ),
      output: output ?? ConsoleOutput(),
      filter: filter ?? ProductionFilter(),
    );
  }

  /// Returns the underlying logger instance.
  Logger get logger => _logger;

  /// Logs a message with the provided level, error, and stacktrace.
  static void log(
    String message, {
    Level level = Level.info,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _instance._logger.log(level, message, error: error, stackTrace: stackTrace);
  }
}

/// A shorthand function to log messages using AppLogger.
void logs(
  String message, {
  Level level = Level.info,
  dynamic error,
  StackTrace? stackTrace,
}) {
  AppLogger.log(message, level: level, error: error, stackTrace: stackTrace);
}
