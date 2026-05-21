import 'package:test/test.dart';
import 'package:boost/boost.dart';

void main() {
  test('compare', _compareTest);
  test('operators', _operatorTest);
  test('toString', _toStringTest);
}

void _compareTest() {
  final oldVersion = Version('0.6.2');
  final newVersion = Version('0.6.2.0.1');
  final newVersion2 = Version('1.0');
  final sameVersion = Version('0.6.2.0.0.0');

  expect(oldVersion.compareTo(newVersion), equals(-1));
  expect(newVersion.compareTo(oldVersion), equals(1));
  expect(oldVersion.compareTo(newVersion2), equals(-1));
  expect(newVersion2.compareTo(oldVersion), equals(1));
  expect(oldVersion.compareTo(sameVersion), equals(0));
}

void _operatorTest() {
  expect(Version('0.2.4') == Version('0.2.4'), isTrue);
  expect(Version('0.2.4') == Version('0.2.3'), isFalse);

  expect(Version('0.2.3') < Version('0.2.4'), isTrue);
  expect(Version('0.2.4') < Version('0.2.4'), isFalse);
  expect(Version('0.2.4') < Version('0.2.3'), isFalse);

  expect(Version('0.2.4') > Version('0.2.3'), isTrue);
  expect(Version('0.2.4') > Version('0.2.4'), isFalse);
  expect(Version('0.2.3') > Version('0.2.4'), isFalse);

  expect(Version('0.2.3') <= Version('0.2.4'), isTrue);
  expect(Version('0.2.4') <= Version('0.2.4'), isTrue);
  expect(Version('0.2.5') <= Version('0.2.4'), isFalse);

  expect(Version('0.2.5') >= Version('0.2.4'), isTrue);
  expect(Version('0.2.4') >= Version('0.2.4'), isTrue);
  expect(Version('0.2.3') >= Version('0.2.4'), isFalse);

  expect(Version('0.2.4')[2], equals(4));
}

void _toStringTest() {
  expect(Version('0.2.5.0').toString(), equals('0.2.5.0'));
}
