import 'package:boost/boost.dart';
import 'package:test/test.dart';

void main() {
  test('parseConfig', _parseConfig);
  test('throwInvalid', _throwInvalid);
  test('throwConflict', _throwConflict);
}

void _parseConfig() {
  final config = ConfigParser()
    ..addOption('string', abbr: 's')
    ..addOption('int', abbr: 'i', type: int)
    ..addOption('double', abbr: 'd', type: double, environment: 'SOME_DOUBLE')
    ..addOption('bool', abbr: 'b', type: bool)
    ..addOption('other', abbr: 'o', type: int, environment: 'TEST_OTHER')
    ..addOption('otherStr',
        abbr: 'x', type: String, environment: 'TEST_OTHER_STR');

  final vars = config.parse([
    '--string',
    '"hello',
    'boost',
    'world"',
    '-i',
    '254',
    '--bool',
    '"TRUE"',
    '-d',
    '2.4556',
  ]);

  expect(
      vars,
      equals({
        'string': 'hello boost world',
        'int': 254,
        'double': 2.4556,
        'bool': true,
        'other': null,
        'otherStr': null,
      }));
}

void _throwInvalid() {
  final config = ConfigParser()
    ..addOption('string', abbr: 's')
    ..addOption('int', abbr: 'i', type: int)
    ..addOption('double', abbr: 'd', type: double, environment: 'SOME_DOUBLE')
    ..addOption('bool', abbr: 'b', type: bool)
    ..addOption('other', abbr: 'o', type: int, environment: 'TEST_OTHER');

  expect(() => config.parse(['--doesntexist']), throwsA(isA<BoostException>()));

  expect(() => config.parse(['-invalid', 'whatever']),
      throwsA(isA<BoostException>()));

  expect(
      () => config.parse(['-string', 'abc']), throwsA(isA<BoostException>()));

  expect(() => config.parse(['--i', '20']), throwsA(isA<BoostException>()));

  expect(() => config.parse(['--string', '"this', 'is', 'invalid']),
      throwsA(isA<BoostException>()));

  expect(() => config.parse(['invalid']), throwsA(isA<BoostException>()));
}

void _throwConflict() {
  expect(
      () => ConfigParser()
        ..addOption('string', abbr: 's')
        ..addOption('string', abbr: 'o', type: int, environment: 'TEST_OTHER'),
      throwsA(isA<BoostException>()));

  expect(
      () => ConfigParser()
        ..addOption('string', abbr: 's')
        ..addOption('string2', abbr: 's', type: int, environment: 'TEST_OTHER'),
      throwsA(isA<BoostException>()));

  expect(
      () => ConfigParser()
        ..addOption('string', abbr: 'x', environment: 'SAME')
        ..addOption('string2', abbr: 's', type: int, environment: 'SAME'),
      throwsA(isA<BoostException>()));
}
