import 'dart:io';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:stack_trace/stack_trace.dart';

import 'log_level.dart';
import 'log_message.dart';

abstract interface class LogWriter {
  void write(LogMessage message);
}

class StdoutLogWriter implements LogWriter {
  static const _colorReset = '\u001b[0m';
  static const _colorRed = '\u001b[31m';
  static const _colorBrightRed = '\u001b[31;1m';
  static const _colorGreen = '\u001b[32m';
  static const _colorYellow = '\u001b[33m';
  static const _colorCyan = '\u001b[36m';

  const StdoutLogWriter();

  @override
  void write(LogMessage message) {
    final buffer = StringBuffer();
    final color = _severityColor(message.level);

    var prefixLength = 0;
    void writePrefix(String val) {
      prefixLength += val.length;
      buffer.write(val);
    }

    writePrefix(_timestamp(message.timestamp));
    writePrefix(' ');

    if (color != null) {
      buffer.write(color);
    }

    writePrefix(_severityPrefix(message.level));
    writePrefix(' ');

    /*
    final pathInfo = LogService.currentPathInfo();

    for (final entry in pathInfo.entries) {
      if (entry.value != null) {
        if (entry.key == 'isolate') {
          continue;
        }
        writePrefix(_brackets(entry.value.toString(), null));
        writePrefix(' ');
      }
    }*/

    final indent = ' ' * prefixLength;
    buffer.write(message.line.replaceAll('\n', '\n$indent'));

    if (message.error != null) {
      buffer.write('\n');
      buffer.write(indent);
      buffer.write(message.error);
    }

    if (message.stack != null) {
      buffer.write('\n');
      buffer.write(indent);
      buffer.write(Trace.format(message.stack!).replaceAll('\n', '\n$indent'));
    }

    if (color != null) {
      buffer.write(_colorReset);
    }
    buffer.write('\n');

    stdout.write(buffer.toString());
  }

  static String? _severityColor(LogLevel severity) {
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

  static String _timestamp(DateTime timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
  }

  static String _severityPrefix(LogLevel severity) {
    return _brackets(severity.name.toUpperCase(), 8);
  }

  static String _brackets(String text, int length) {
    return '[${text.substring(0, min(text.length, length)).padRight(length)}]';
  }
}
