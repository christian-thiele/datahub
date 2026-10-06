import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:boost/boost.dart';
import 'package:datahub/utils.dart';
import 'package:intl/intl.dart';
import 'package:stack_trace/stack_trace.dart';

import 'log_exporter.dart';
import 'log_message.dart';
import 'severity_level.dart';

enum LogBodyFormat { logfmt, json, message, pretty }

/// Writes log messages to stdout.
///
/// The `logfmt` and `json` formats write the labels of a message and the
/// fields `severity`, `msg`, `error`, `stack`, `trace_id` and `span_id`.
class StdoutLogExporter extends LogExporter {
  final LogBodyFormat format;

  StdoutLogExporter(this.format);

  @override
  void add(LogMessage message) {
    final body = {
      for (final (key, value) in message.labels.tuples) key: value,
      'severity': message.level.severityText,
      'msg': message.line,
      if (message.error != null) 'error': message.error.toString(),
      if (message.stack != null) 'stack': message.stack.toString(),
      if (message.span?.traceId case final traceId?) 'trace_id': traceId.hexId,
      if (message.span?.spanId case final spanId?) 'span_id': spanId.hexId,
    };

    switch (format) {
      case LogBodyFormat.logfmt:
        stdout.writeln(logFmtEncode(body));
      case LogBodyFormat.json:
        stdout.writeln(jsonEncode(body));
      case LogBodyFormat.message:
        stdout.writeln(message.line);
      case LogBodyFormat.pretty:
        _PrettyLog.write(message);
    }
  }
}

class _PrettyLog {
  static const _colorReset = '\u001b[0m';
  static const _colorRed = '\u001b[31m';
  static const _colorBrightRed = '\u001b[31;1m';
  static const _colorGreen = '\u001b[32m';
  static const _colorYellow = '\u001b[33m';
  static const _colorBlue = '\u001b[34m';
  static const _colorCyan = '\u001b[36m';

  const _PrettyLog();

  static void write(LogMessage message) {
    final maxLength = stdout.hasTerminal ? stdout.terminalColumns : 128;
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

    final indent = ' ' * prefixLength;
    final lines = message.line
        .splitLineLength(maxLength - prefixLength)
        .join('\n');

    buffer.write(lines.replaceAll('\n', '\n$indent'));

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

  static String? _severityColor(SeverityLevel severity) {
    switch (severity) {
      case SeverityLevel.trace:
        return _colorBlue;
      case SeverityLevel.debug:
        return _colorGreen;
      case SeverityLevel.info:
        return _colorCyan;
      case SeverityLevel.warning:
        return _colorYellow;
      case SeverityLevel.error:
        return _colorRed;
      case SeverityLevel.fatal:
        return _colorBrightRed;
    }
  }

  static String _timestamp(DateTime timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);
  }

  static String _severityPrefix(SeverityLevel severity) {
    return _brackets(severity.severityText, 5);
  }

  static String _brackets(String text, int length) {
    return '[${text.substring(0, min(text.length, length)).padRight(length)}]';
  }
}
