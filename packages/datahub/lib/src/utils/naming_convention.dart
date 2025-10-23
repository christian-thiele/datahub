import 'package:boost/boost.dart';

enum NamingConvention {
  /// no formatting applied
  none,

  /// lower snake case => lower_snake_case
  lowerSnakeCase,

  /// upper snake case => UPPER_SNAKE_CASE
  upperSnakeCase,

  /// camel case => CamelCase
  camelCase,

  /// lower camel case => lowerCamelCase
  lowerCamelCase,
}

String toNamingConvention(String input, NamingConvention convention) {
  switch (convention) {
    case NamingConvention.none:
      return input;
    case NamingConvention.lowerSnakeCase:
      return splitWords(input).map((e) => e.toLowerCase()).join('_');
    case NamingConvention.upperSnakeCase:
      return splitWords(input).map((e) => e.toUpperCase()).join('_');
    case NamingConvention.camelCase:
      return splitWords(input).map((e) => firstUpper(e)).join();
    case NamingConvention.lowerCamelCase:
      return splitWords(
        input,
      ).mapIndexed((e, i) => i == 0 ? e.toLowerCase() : firstUpper(e)).join();
  }
}

Iterable<String> splitWords(String input) sync* {
  final it = input.codeUnits.iterator;
  var buffer = <int>[];

  var canBreak = false;
  while (it.moveNext()) {
    if (isUppercase(it.current)) {
      if (canBreak) {
        yield String.fromCharCodes(buffer);
        buffer.clear();
        buffer.add(it.current);
      } else {
        buffer.add(it.current);
      }
      canBreak = false;
    } else if (isLowercase(it.current) || isNumber(it.current)) {
      if (buffer.length > 1 && isUppercase(buffer.last)) {
        final previous = buffer.removeLast();
        yield String.fromCharCodes(buffer);
        buffer.clear();
        buffer.add(previous);
      }
      canBreak = true;
      buffer.add(it.current);
    } else {
      if (buffer.isNotEmpty) {
        yield String.fromCharCodes(buffer);
        buffer.clear();
        canBreak = false;
      }
    }
  }
  yield String.fromCharCodes(buffer);
}

bool isUppercase(int ascii) {
  return ascii >= 65 && ascii <= 90;
}

bool isLowercase(int ascii) {
  return ascii >= 97 && ascii <= 122;
}

bool isNumber(int ascii) {
  return ascii >= 48 && ascii <= 57;
}

String firstUpper(String input) {
  if (input.length > 1) {
    return input.substring(0, 1).toUpperCase() +
        input.substring(1, input.length).toLowerCase();
  } else {
    return input.toUpperCase();
  }
}
