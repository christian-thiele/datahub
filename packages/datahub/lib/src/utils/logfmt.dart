String logFmtEncode(Map<String, String> values) {
  const order = ['severity', 'msg'];

  final buffer = StringBuffer();
  for (final key in order) {
    if (values[key] case final value?) {
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write('$key=${_escapeValue(value)}');
    }
  }

  for (final key in values.keys.where((e) => !order.contains(e))) {
    if (buffer.isNotEmpty) {
      buffer.write(' ');
    }

    if (RegExp('[^a-zA-Z0-9_.-]').hasMatch(key)) {
      continue;
    }

    buffer.write('$key=${_escapeValue(values[key]!)}');
  }

  return buffer.toString();
}

String _escapeValue(String value) {
  return '"${value.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"';
}
