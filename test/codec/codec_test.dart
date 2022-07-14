import 'package:test/test.dart';
import 'package:datahub/datahub.dart';

void main() {
  group('Encoding', () {
    test('encodeTyped', _encodeTypedTest);
    test('decodeTyped', _decodeTypedTest);
  });
}

void _decodeTypedTest() {
  expect(decodeTypedNullable<int>(123), equals(123));
  expect(decodeTypedNullable<int?>(123), equals(123));
  expect(decodeTypedNullable<int>('123'), equals(123));
  expect(decodeTypedNullable<int?>('123'), equals(123));
  expect(decodeTypedNullable<int?>(null), equals(null));
  expect(decodeTypedNullable<String>(null), equals(null));
  expect(decodeTypedNullable<String?>(null), equals(null));
  expect(decodeTypedNullable<String?>('abc'), equals('abc'));
  expect(decodeTypedNullable<String?>(123.456), equals('123.456'));
  expect(decodeTypedNullable<bool?>(1), equals(true));
  expect(decodeTypedNullable<bool?>('abc'), equals(null));
  expect(decodeTypedNullable<bool?>('true'), equals(true));
  expect(decodeTypedNullable<bool>('false'), equals(false));
}

void _encodeTypedTest() {
  expect(encodeTyped(123), equals(123));
  expect(encodeTyped('123'), equals('123'));
  expect(encodeTyped('123'), equals('123'));
  expect(encodeTyped(true), equals(true));
  expect(encodeTyped(DateTime(2022, 06, 15)),
      equals(DateTime(2022, 06, 15).toIso8601String()));
}
