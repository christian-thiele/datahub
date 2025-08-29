import 'package:boost/boost.dart';

enum NamingConvention {
  none,
  lowerSnakeCase,
  upperSnakeCase,
  camelCase,
  lowerCamelCase
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
      return splitWords(input)
          .mapIndexed((e, i) => i == 0 ? e.toLowerCase() : firstUpper(e))
          .join();
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
        canBreak = false;
      } else {
        buffer.add(it.current);
        canBreak = !isUppercase(it.current);
      }
    } else if (RegExp('[^a-zA-Z0-9]')
        .hasMatch(String.fromCharCode(it.current))) {
      if (buffer.isNotEmpty) {
        yield String.fromCharCodes(buffer);
        buffer.clear();
        canBreak = false;
      }
    } else {
      canBreak = true;
      buffer.add(it.current);
    }
  }
  yield String.fromCharCodes(buffer);
}

bool isUppercase(int ascii) {
  return ascii >= 65 && ascii <= 90;
}

String firstUpper(String input) {
  if (input.length > 1) {
    return input.substring(0, 1).toUpperCase() +
        input.substring(1, input.length).toLowerCase();
  } else {
    return input.toUpperCase();
  }
}
