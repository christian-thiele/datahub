import 'package:datahub/src/utils/naming_convention.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Naming Conventions', () {
    test('splitWords', () {
      expect(
        splitWords('thisIsABCTest'),
        orderedEquals(['this', 'Is', 'ABCTest']),
      );
      expect(
        splitWords('Words1 are 3not div1d3d by numbers'),
        orderedEquals(['Words1', 'are', '3not', 'div1d3d', 'by', 'numbers']),
      );
      expect(
        splitWords('Words1 are 3not div1d3d by numbers'),
        orderedEquals(['Words1', 'are', '3not', 'div1d3d', 'by', 'numbers']),
      );
      expect(
        splitWords('Words are divided_BY_underscore'),
        orderedEquals(['Words', 'are', 'divided', 'BY', 'underscore']),
      );
      expect(
        splitWords('Words are divided_BY_underscore but alsoByUpper'),
        orderedEquals([
          'Words',
          'are',
          'divided',
          'BY',
          'underscore',
          'but',
          'also',
          'By',
          'Upper'
        ]),
      );
    });

    test('none', () {
      expect(
        toNamingConvention(
          'Words are divided_BY_underscore but alsoByUpper',
          NamingConvention.none,
        ),
        'Words are divided_BY_underscore but alsoByUpper',
      );
    });

    test('camelCase', () {
      expect(
        toNamingConvention(
          'Words are divided_BY_underscore but alsoByUpper',
          NamingConvention.camelCase,
        ),
        'WordsAreDividedByUnderscoreButAlsoByUpper',
      );
    });

    test('lowerCamelCase', () {
      expect(
        toNamingConvention(
          'Words are divided_BY_underscore but alsoByUpper',
          NamingConvention.lowerCamelCase,
        ),
        'wordsAreDividedByUnderscoreButAlsoByUpper',
      );
    });

    test('lowerSnakeCase', () {
      expect(
        toNamingConvention(
          'Words are divided_BY_underscore but alsoByUpper',
          NamingConvention.lowerSnakeCase,
        ),
        'words_are_divided_by_underscore_but_also_by_upper',
      );
    });

    test('upperSnakeCase', () {
      expect(
        toNamingConvention(
          'Words are divided_BY_underscore but alsoByUpper',
          NamingConvention.upperSnakeCase,
        ),
        'WORDS_ARE_DIVIDED_BY_UNDERSCORE_BUT_ALSO_BY_UPPER',
      );
    });
  });
}
