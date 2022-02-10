import 'package:cl_datahub/cl_datahub.dart';

import 'log_backend.dart';
import 'log_message.dart';

/// DataHubs logging solution.
///
/// This service is automatically added to any [ServiceHost] to provide
/// logging functionality to other modules of the DataHub framework.
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

  LogService(this._backend);

  void d(String message, {String? sender}) => debug(message, sender: sender);

  void v(String message, {String? sender}) => verbose(message, sender: sender);

  void i(String message, {String? sender}) => info(message, sender: sender);

  void w(String message, {String? sender, dynamic error, StackTrace? trace}) =>
      warn(message, sender: sender, error: error, trace: trace);

  void e(String message, {String? sender, dynamic error, StackTrace? trace}) =>
      error(message, sender: sender, error: error, trace: trace);

  void c(String message, {String? sender, dynamic error, StackTrace? trace}) =>
      critical(message, sender: sender, error: error, trace: trace);

  void debug(String message, {String? sender}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogMessage.debug,
        null,
        null,
      ),
    );
  }

  void verbose(String message, {String? sender}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogMessage.verbose,
        null,
        null,
      ),
    );
  }

  void info(String message, {String? sender}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogMessage.info,
        null,
        null,
      ),
    );
  }

  void warn(String message,
      {String? sender, dynamic error, StackTrace? trace}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogMessage.warning,
        error,
        trace,
      ),
    );
  }

  void error(String message,
      {String? sender, dynamic error, StackTrace? trace}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogMessage.error,
        error,
        trace,
      ),
    );
  }

  void critical(String message,
      {String? sender, dynamic error, StackTrace? trace}) {
    _backend.publish(
      LogMessage(
        DateTime.now(),
        sender,
        message,
        LogMessage.critical,
        error,
        trace,
      ),
    );
  }

  @override
  Future<void> initialize() async => await _backend.initialize();

  @override
  Future<void> shutdown() async {}
}
