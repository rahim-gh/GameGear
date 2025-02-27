import 'package:logger/web.dart';

class LoggerUtil {
  static final LoggerUtil _singleton = LoggerUtil._internal();
  late final Logger _logger;

  factory LoggerUtil() {
    return _singleton;
  }

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

// Call this
void applog(String message, {Level level = Level.info}) {
  LoggerUtil().logger.log(level, message);
}
