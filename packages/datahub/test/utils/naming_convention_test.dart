import 'package:datahub/src/utils/naming_convention.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

const lowerLetters = 'abcdefghijklmnopqrstuvwxyz';
const upperLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const numbers = '0123456789';
const specialChars = '!"§\$%&/()=?¹²³¼½¬{[]}\\\'';

void main() {
  group('Naming Conventions', () {
    test('isLowercase', () {
      for (final char in lowerLetters.codeUnits) {
        expect(isLowercase(char), isTrue);
      }

      for (final char in upperLetters.codeUnits) {
        expect(isLowercase(char), isFalse);
      }

      for (final char in numbers.codeUnits) {
        expect(isLowercase(char), isFalse);
      }

      for (final char in specialChars.codeUnits) {
        expect(isLowercase(char), isFalse);
      }
    });

    test('isUppercase', () {
      for (final char in lowerLetters.codeUnits) {
        expect(isUppercase(char), isFalse);
      }

      for (final char in upperLetters.codeUnits) {
        expect(isUppercase(char), isTrue);
      }

      for (final char in numbers.codeUnits) {
        expect(isUppercase(char), isFalse);
      }

      for (final char in specialChars.codeUnits) {
        expect(isUppercase(char), isFalse);
      }
    });

    test('isNumber', () {
      for (final char in lowerLetters.codeUnits) {
        expect(isNumber(char), isFalse);
      }

      for (final char in upperLetters.codeUnits) {
        expect(isNumber(char), isFalse);
      }

      for (final char in numbers.codeUnits) {
        expect(isNumber(char), isTrue);
      }

      for (final char in specialChars.codeUnits) {
        expect(isNumber(char), isFalse);
      }
    });

    test('splitWords', () {
      expect(
        splitWords('thisIsABCTest'),
        orderedEquals(['this', 'Is', 'ABC', 'Test']),
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
          'Upper',
        ]),
      );
      expect(splitWords('IPRange'), orderedEquals(['IP', 'Range']));
      expect(splitWords('IP_Range'), orderedEquals(['IP', 'Range']));
      expect(splitWords('IP Range'), orderedEquals(['IP', 'Range']));
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
