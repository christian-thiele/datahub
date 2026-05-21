import 'package:boost/boost.dart';
import 'package:test/test.dart';

void main() {
  test('nullOrEmpty', _nullOrEmptyTest);
  test('nullOrWhitespace', _nullOrWhitespaceTest);
}

void _nullOrEmptyTest() {
  expect(nullOrEmpty(''), isTrue);
  expect(nullOrEmpty(null), isTrue);
  expect(nullOrEmpty(' '), isFalse);
  expect(nullOrEmpty('abc'), isFalse);
  expect(nullOrEmpty('\t'), isFalse);
  expect(nullOrEmpty('.'), isFalse);
}

void _nullOrWhitespaceTest() {
  expect(nullOrWhitespace(''), isTrue);
  expect(nullOrWhitespace(null), isTrue);
  expect(nullOrWhitespace(' '), isTrue);
  expect(nullOrWhitespace('\t '), isTrue);
  expect(nullOrWhitespace('\t'), isTrue);
  expect(nullOrWhitespace(' abc'), isFalse);
  expect(nullOrWhitespace('.'), isFalse);
}
