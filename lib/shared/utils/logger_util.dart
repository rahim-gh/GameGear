import 'package:logger/logger.dart';

class LoggerUtil {
  static final LoggerUtil _singleton = LoggerUtil._internal();
  late final Logger _logger;

  factory LoggerUtil() => _singleton;

  LoggerUtil._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTime,
      ),
      output: ConsoleOutput(),
      filter: ProductionFilter(),
    );
  }

  Logger get logger => _logger;
}

/// Enhanced logs function to accept error and stacktrace.
void logs(
  String message, {
  Level level = Level.info,
  dynamic error,
  StackTrace? stackTrace,
}) {
  LoggerUtil().logger.log(level, message, error: error, stackTrace: stackTrace);
}
