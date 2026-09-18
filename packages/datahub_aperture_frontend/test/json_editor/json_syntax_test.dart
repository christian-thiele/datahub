import 'dart:convert';

import 'package:datahub_aperture_frontend/widgets/json_editor/model/json_syntax.dart';
import 'package:flutter_test/flutter_test.dart';

const _valid = [
  '{}',
  '[]',
  '{"a": 1}',
  '[1, 2.5, -3e10, 0, -0.0, 1E+2, 4e-1]',
  '"text"',
  'true',
  'false',
  'null',
  '123',
  '{"a": {"b": [true, false, null, {}, []]}}',
  r'"\" \\ \/ \b \f \n \r \t \u00e9 \uD83D\uDE00"',
  ' \t\r\n{ "a" : [ ] }\n ',
  '"ü 😀 \u2028"',
  '{"a": 1, "a": 2}',
];

/// Invalid JSON and the error [findJsonSyntaxError] finds in it.
const _invalid = {
  '': (0, 0),
  '  ': (2, 2),
  '{': (1, 1),
  '[1, 2': (5, 5),
  '{"a"': (4, 4),
  '{"a":': (5, 5),
  '{"a": 1,}': (8, 9),
  '{"a" 1}': (5, 6),
  '{a: 1}': (1, 2),
  "{'a': 1}": (1, 4),
  '[1 2]': (3, 4),
  '[1,]': (3, 4),
  '[}': (1, 2),
  '{]': (1, 2),
  '[1}': (2, 3),
  '{"a": 1]': (7, 8),
  '{"a": 1} x': (9, 10),
  '{"a": 1}}': (8, 9),
  '{1: 2}': (1, 2),
  '["a": 1]': (4, 5),
  '{"a": 01}': (6, 8),
  '{"a": 1.}': (6, 8),
  '{"a": .5}': (6, 8),
  '{"a": -}': (6, 7),
  '{"a": 1e}': (6, 8),
  '{"a": tru}': (6, 9),
  'NaN': (0, 3),
  '-Infinity': (0, 9),
  '"abc': (0, 4),
  '"abc\n"': (0, 4),
  r'"a\x"': (2, 3),
  r'"a\u12"': (2, 3),
  '"a\tb"': (2, 3),
  r'["a", "b\q", 1 2]': (8, 9),
  r'["a" "b\q"]': (5, 10),
};

void main() {
  group('tokenizeJson', () {
    test('tells keys from strings', () {
      expect(tokenizeJson('{"a" : "b", "c": ["d"]}'), const [
        JsonToken(JsonTokenType.punctuation, 0, 1),
        JsonToken(JsonTokenType.key, 1, 4),
        JsonToken(JsonTokenType.punctuation, 5, 6),
        JsonToken(JsonTokenType.string, 7, 10),
        JsonToken(JsonTokenType.punctuation, 10, 11),
        JsonToken(JsonTokenType.key, 12, 15),
        JsonToken(JsonTokenType.punctuation, 15, 16),
        JsonToken(JsonTokenType.punctuation, 17, 18),
        JsonToken(JsonTokenType.string, 18, 21),
        JsonToken(JsonTokenType.punctuation, 21, 22),
        JsonToken(JsonTokenType.punctuation, 22, 23),
      ]);
    });

    test('tells numbers, literals and invalid words apart', () {
      expect(tokenizeJson('[-1.5e3, true, nul, 01]'), const [
        JsonToken(JsonTokenType.punctuation, 0, 1),
        JsonToken(JsonTokenType.number, 1, 7),
        JsonToken(JsonTokenType.punctuation, 7, 8),
        JsonToken(JsonTokenType.literal, 9, 13),
        JsonToken(JsonTokenType.punctuation, 13, 14),
        JsonToken(JsonTokenType.invalid, 15, 18, JsonSyntaxError(15, 18)),
        JsonToken(JsonTokenType.punctuation, 18, 19),
        JsonToken(JsonTokenType.number, 20, 22, JsonSyntaxError(20, 22)),
        JsonToken(JsonTokenType.punctuation, 22, 23),
      ]);
    });

    test('ends an unterminated string at the end of its line', () {
      expect(tokenizeJson('"abc\n"def"'), const [
        JsonToken(JsonTokenType.string, 0, 4, JsonSyntaxError(0, 4)),
        JsonToken(JsonTokenType.string, 5, 10),
      ]);
    });

    test('keeps escaped quotes in the string', () {
      expect(tokenizeJson(r'"a\"b"'), const [
        JsonToken(JsonTokenType.string, 0, 6),
      ]);
    });
  });

  group('findJsonSyntaxError', () {
    for (final text in _valid) {
      test('accepts ${jsonEncode(text)}', () {
        expect(findJsonSyntaxError(text), isNull);
      });
    }

    for (final MapEntry(key: text, value: (start, end)) in _invalid.entries) {
      test('finds the error in ${jsonEncode(text)}', () {
        expect(findJsonSyntaxError(text), JsonSyntaxError(start, end));
      });
    }

    test('agrees with jsonDecode', () {
      for (final text in [..._valid, ..._invalid.keys]) {
        bool decodes;
        try {
          jsonDecode(text);
          decodes = true;
        } on FormatException {
          decodes = false;
        }

        expect(
          findJsonSyntaxError(text) == null,
          decodes,
          reason: jsonEncode(text),
        );
      }
    });
  });

  group('JsonSyntaxError.positionIn', () {
    test('counts lines and columns from 1', () {
      const text = '{\n  "a": 1\n  "b": 2\n}';
      final error = findJsonSyntaxError(text)!;

      expect(error.positionIn(text), (3, 3));
    });

    test('points behind the text at its end', () {
      expect(const JsonSyntaxError(8, 8).positionIn('{\n  "a"\n'), (3, 1));
    });
  });
}
