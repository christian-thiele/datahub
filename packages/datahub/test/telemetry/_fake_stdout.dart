import 'dart:async';
import 'dart:convert';
import 'dart:io';

class FakeStdout implements Stdout {
  final StringBuffer buffer;

  FakeStdout(this.buffer);

  @override
  void writeln([Object? obj = ""]) {
    buffer.writeln(obj);
  }

  @override
  void write(Object? obj) {
    buffer.write(obj);
  }

  @override
  Encoding encoding = utf8;

  @override
  String lineTerminator = '\n';

  @override
  void add(List<int> data) {
    buffer.write(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
  }

  @override
  Future<dynamic> addStream(Stream<List<int>> stream) async {
    await for (final entry in stream) {
      add(entry);
    }
  }

  @override
  Future<dynamic> close() async {
  }

  @override
  Future<dynamic> get done => StreamController().done;

  @override
  Future<dynamic> flush() async {}

  @override
  bool get hasTerminal => false;

  @override
  IOSink get nonBlocking => throw UnimplementedError();

  @override
  bool get supportsAnsiEscapes => true;

  @override
  int get terminalColumns => 48;

  @override
  int get terminalLines => 24;

  @override
  void writeAll(Iterable<dynamic> objects, [String sep = ""]) {
    buffer.writeAll(objects, sep);
  }

  @override
  void writeCharCode(int charCode) {
    buffer.writeCharCode(charCode);
  }
}
