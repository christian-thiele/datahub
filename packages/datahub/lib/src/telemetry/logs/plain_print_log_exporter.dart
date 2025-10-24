import 'dart:io';

import 'log_exporter.dart';
import 'log_message.dart';

class PlainPrintLogExporter implements LogExporter {
  PlainPrintLogExporter();

  @override
  void add(LogMessage message) {
    stdout.writeln(message.line);
  }

  @override
  void close() {}
}
