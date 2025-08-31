class Writer {
  final buffer = StringBuffer();

  void w(dynamic text) => buffer.write(text);

  void call(dynamic text) => buffer.writeln(text);

  @override
  String toString() => buffer.toString();
}


String firstUp(String text) =>
    text.substring(0, 1).toUpperCase() + text.substring(1);