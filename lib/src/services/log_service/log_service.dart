import 'package:datahub/ioc.dart';

import 'log_backend.dart';
import 'log_level.dart';
import 'log_message.dart';

/// DataHubs logging solution.
///
/// This service is automatically added to any [ServiceHost] to provide
/// logging functionality to other modules of the DataHub framework.
///
/// The configuration value `datahub.log` defines the initial log level.
/// See enum values in [LogLevel].
///
/// Messages can be logged by resolving the [LogService] and calling
/// its logging methods.
///
/// ```
///   final log = resolve<LogService>();
///   log.w('This is a warning!');
/// ```
///
/// The default [LogService] uses a [ConsoleLogBackend] to write messages
/// to stdout. If a different [LogBackend] implementation is required, simply
/// pass it into ServiceHost constructor.
///
/// ```
///   final host = ServiceHost([
///     ...
///   ], logBackend: CustomLogBackendImpl());
/// ```
class LogService extends BaseService {
  final LogBackend _backend;

  LogService(this._backend) : super('datahub');

  void setLogLevel(LogLevel level) => _backend.setLogLevel(level);

  void d(
    String message, {
    String? sender,
    Map<String, dynamic> meta = const {},
  }) =>
      debug(
        message,
        sender: sender,
        meta: meta,
      );

  void v(
    String message, {
    String? sender,
    Map<String, dynamic> meta = const {},
  }) =>
      verbose(
        message,
        sender: sender,
        meta: meta,
      );

  void i(
    String message, {
    String? sender,
    Map<String, dynamic> meta = const {},
  }) =>
      info(
        message,
        sender: sender,
        meta: meta,
      );

  void w(String message,
          {String? sender,
          dynamic error,
          StackTrace? trace,
          Map<String, dynamic> meta = const {}}) =>
      warn(
        message,
        sender: sender,
        error: error,
        trace: trace,
        meta: meta,
      );

  void e(String message,
          {String? sender,
          dynamic error,
          StackTrace? trace,
          Map<String, dynamic> meta = const {}}) =>
      this.error(
        message,
        sender: sender,
        error: error,
        trace: trace,
        meta: meta,
      );

  void c(String message,
          {String? sender,
          dynamic error,
          StackTrace? trace,
          Map<String, dynamic> meta = const {}}) =>
      critical(
        message,
        sender: sender,
        error: error,
        trace: trace,
        meta: meta,
      );

  void debug(String message,
      {String? sender, Map<String, dynamic> meta = const {}}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogLevel.debug,
        null,
        null,
        meta,
      ),
    );
  }

  void verbose(String message,
      {String? sender, Map<String, dynamic> meta = const {}}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogLevel.verbose,
        null,
        null,
        meta,
      ),
    );
  }

  void info(String message,
      {String? sender, Map<String, dynamic> meta = const {}}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogLevel.info,
        null,
        null,
        meta,
      ),
    );
  }

  void warn(String message,
      {String? sender,
      dynamic error,
      StackTrace? trace,
      Map<String, dynamic> meta = const {}}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogLevel.warning,
        error,
        trace,
        meta,
      ),
    );
  }

  void error(String message,
      {String? sender,
      dynamic error,
      StackTrace? trace,
      Map<String, dynamic> meta = const {}}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogLevel.error,
        error,
        trace,
        meta,
      ),
    );
  }

  void critical(String message,
      {String? sender,
      dynamic error,
      StackTrace? trace,
      Map<String, dynamic> meta = const {}}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogLevel.critical,
        error,
        trace,
        meta,
      ),
    );
  }

  @override
  Future<void> initialize() async => await _backend.initialize();

  @override
  Future<void> shutdown() async => await _backend.shutdown();
}
