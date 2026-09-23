/// Converts [input] to lower snake case the way `toNamingConvention` from
/// `package:datahub` does, which is how field names become column names.
String lowerSnakeCase(String input) =>
    _splitWords(input).map((e) => e.toLowerCase()).join('_');

/// Mirrors `splitWords` from `package:datahub`.
Iterable<String> _splitWords(String input) sync* {
  final buffer = <int>[];
  var canBreak = false;

  for (final unit in input.codeUnits) {
    if (_isUppercase(unit)) {
      if (canBreak) {
        yield String.fromCharCodes(buffer);
        buffer.clear();
      }
      buffer.add(unit);
      canBreak = false;
    } else if (_isLowercase(unit) || _isNumber(unit)) {
      if (buffer.length > 1 && _isUppercase(buffer.last)) {
        final previous = buffer.removeLast();
        yield String.fromCharCodes(buffer);
        buffer.clear();
        buffer.add(previous);
      }
      canBreak = true;
      buffer.add(unit);
    } else if (buffer.isNotEmpty) {
      yield String.fromCharCodes(buffer);
      buffer.clear();
      canBreak = false;
    }
  }
  yield String.fromCharCodes(buffer);
}

bool _isUppercase(int unit) => unit >= 65 && unit <= 90;

bool _isLowercase(int unit) => unit >= 97 && unit <= 122;

bool _isNumber(int unit) => unit >= 48 && unit <= 57;
