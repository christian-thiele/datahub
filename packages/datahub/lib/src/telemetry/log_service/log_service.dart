import 'dart:async';
import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';

import 'log_message.dart';
import 'log_level.dart';
import 'log_writer.dart';

abstract interface class LogReceiver {
  void publish(LogMessage message);
}

class LogService implements Service {
  final Config<LogLevel> logLevel;
  final LogWriter logWriter;

  LogService({
    this.logWriter = const StdoutLogWriter(),
    this.logLevel = const Config<LogLevel>(
      'logLevel',
      defaultValue: LogLevel.debug,
      values: LogLevel.values,
    ),
  });

  @override
  ServiceInstance<LogService> createInstance() => _LogServiceInstance();
}

class _LogServiceInstance extends ServiceInstance<LogService>
    implements LogReceiver {
  late final LogLevel logLevel;

  @override
  FutureOr<void> initialize() async {
    await super.initialize();
    logLevel = read(service.logLevel);
  }

  @override
  void publish(LogMessage message) {
    if (logLevel.index > message.level.index) {
      return;
    }

    service.logWriter.write(message);
  }
}
