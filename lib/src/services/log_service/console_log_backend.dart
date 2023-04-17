import 'dart:async';
import 'dart:io';

import 'package:boost/boost.dart';
import 'package:intl/intl.dart';

import 'log_backend.dart';
import 'log_level.dart';
import 'log_message.dart';

/// The default [LogBackend] implementation.
///
/// It logs messages to stdout. Every message with a severity below the
/// log level is dropped. The log level can be changed by setting the config
/// value "datahub.log". The default log level is debug (0).
class ConsoleLogBackend extends LogBackend {
  static const _colorReset = '\u001b[0m';
  static const _colorRed = '\u001b[31m';
  static const _colorBrightRed = '\u001b[31;1m';
  static const _colorGreen = '\u001b[32m';
  static const _colorYellow = '\u001b[33m';
  static const _colorCyan = '\u001b[36m';

  LogLevel _logLevel = LogLevel.debug;

  @override
  void publish(LogMessage message) {
    if (_logLevel.level > message.level.level) {
      return;
    }

    final color = _severityColor(message.level);

    var prefixLength = 0;
    void writePrefix(String val) {
      prefixLength += val.length;
      stdout.write(val);
    }

    writePrefix(_timestampString(message.timestamp));
    writePrefix(' ');

    if (color != null) {
      stdout.write(color);
    }

    writePrefix(_severityPrefix(message.level));
    writePrefix(' ');

    final pathInfo = [
      Zone.current[#apiRequestId],
      Zone.current[#schedulerExecutionId],
      message.sender,
      //TODO other log path segments
    ];

    for (final entry in pathInfo.whereNotNull) {
      writePrefix(_brackets(entry.toString(), null));
      writePrefix(' ');
    }

    final indent = ' ' * prefixLength;
    stdout.write(message.message.replaceAll('\n', '\n$indent'));

    if (message.exception != null) {
      stdout.write('\n');
      stdout.write(indent);
      stdout.write(message.exception);
    }

    if (message.trace != null) {
      stdout.write('\n');
      stdout.write(indent);
      stdout.write(message.trace.toString().replaceAll('\n', '\n$indent'));
    }

    if (color != null) {
      stdout.write(_colorReset);
    }
    stdout.write('\n');
  }

  @override
  void setLogLevel(LogLevel level) => _logLevel = level;

  String? _severityColor(LogLevel severity) {
    switch (severity) {
      case LogLevel.debug:
        return _colorGreen;
      case LogLevel.verbose:
        return _colorCyan;
      case LogLevel.warning:
        return _colorYellow;
      case LogLevel.error:
        return _colorRed;
      case LogLevel.critical:
        return _colorBrightRed;
      default:
        return null;
    }
  }

  String _timestampString(DateTime timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
  }

  String _severityPrefix(LogLevel severity) {
    switch (severity) {
      case LogLevel.debug:
        return '[DEBUG   ]';
      case LogLevel.verbose:
        return '[VERBOSE ]';
      case LogLevel.info:
        return '[INFO    ]';
      case LogLevel.warning:
        return '[WARNING ]';
      case LogLevel.error:
        return '[ERROR   ]';
      case LogLevel.critical:
        return '[CRITICAL]';
      default:
        return '[UNKNOWN ]';
    }
  }

  String _brackets(String text, int? length) {
    length ??= text.length;
    return '[' + text.substring(0, length).padRight(length) + ']';
  }
}
