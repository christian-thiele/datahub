import 'package:datahub_aperture_frontend/widgets/json_editor/model/json_syntax.dart';
import 'package:datahub_aperture_frontend/widgets/json_editor/model/json_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseJsonText', () {
    test('returns null for blank text', () {
      expect(parseJsonText(''), isNull);
      expect(parseJsonText(' \n\t'), isNull);
    });

    test('decodes valid JSON', () {
      expect(parseJsonText('{"a": [1, "b"]}'), {
        'a': [1, 'b'],
      });
      expect(parseJsonText('[true]'), [true]);
    });

    test('returns the text and the error location of invalid JSON', () {
      final value = parseJsonText('{"a": }');

      expect(value, isA<InvalidJson>());
      expect((value as InvalidJson).text, '{"a": }');
      expect(value.error, const JsonSyntaxError(6, 7));
    });
  });

  group('formatJson', () {
    test('indents by two spaces', () {
      expect(
        formatJson({
          'a': [1, 2],
          'b': {'c': null},
        }),
        '{\n'
        '  "a": [\n'
        '    1,\n'
        '    2\n'
        '  ],\n'
        '  "b": {\n'
        '    "c": null\n'
        '  }\n'
        '}',
      );
    });

    test('shows null as blank text', () {
      expect(formatJson(null), '');
    });

    test('keeps the text of invalid JSON', () {
      expect(formatJson(const InvalidJson('{"a"')), '{"a"');
    });
  });

  group('findInvalidJson', () {
    test('finds invalid JSON nested in maps and lists', () {
      const invalid = InvalidJson('[');

      expect(findInvalidJson(invalid), invalid);
      expect(
        findInvalidJson({
          'a': 1,
          'b': [
            {'c': invalid},
          ],
        }),
        invalid,
      );
    });

    test('finds nothing in values', () {
      expect(findInvalidJson(null), isNull);
      expect(
        findInvalidJson({
          'a': [1, 'b'],
        }),
        isNull,
      );
    });
  });

  test('JsonRootType accepts its kind of value only', () {
    expect(JsonRootType.object.accepts(<String, dynamic>{}), isTrue);
    expect(JsonRootType.object.accepts([]), isFalse);
    expect(JsonRootType.array.accepts([]), isTrue);
    expect(JsonRootType.array.accepts('[]'), isFalse);
  });
}
