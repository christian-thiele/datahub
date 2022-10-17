import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:datahub/datahub.dart';

void main() {
  group('Encode', () {
    test('String', _encodeString);
    test('double', _encodeDouble);
    test('int', _encodeInt);
    test('num', _encodeNum);
    test('bool', _encodeBool);
    test('DateTime', _encodeDateTime);
    test('Duration', _encodeDuration);
    test('Uint8List', _encodeUint8List);
  });

  group('Encode List', () {
    test('List<String>', _encodeListString);
    test('List<int>', _encodeListInt);
    test('List<DateTime>', _encodeListDateTime);
    test('List<Uint8List>', _encodeListUint8List);
  });

  group('Encode Map', () {
    test('Map<String, String>', _encodeMapString);
    test('Map<String, int>', _encodeMapInt);
    test('Map<String, DateTime>', _encodeMapDateTime);
    test('Map<String, Uint8List>', _encodeMapUint8List);
    test('Map<String, dynamic>', _encodeMapDynamic);
  });

  group('Decode', () {
    test('String', _decodeString);
    test('double', _decodeDouble);
    test('int', _decodeInt);
    test('num', _decodeNum);
    test('bool', _decodeBool);
    test('DateTime', _decodeDateTime);
    test('Duration', _decodeDuration);
    test('Uint8List', _decodeUint8List);
  });

  group('Decode List', () {
    test('List<String>', _decodeListString);
    test('List<int>', _decodeListInt);
    test('List<DateTime>', _decodeListDateTime);
    test('List<Uint8List>', _decodeListUint8List);
  });

  group('Decode Map', () {
    test('Map<String, String>', _decodeMapString);
    test('Map<String, int>', _decodeMapInt);
    test('Map<String, dynamic>', _decodeMapDynamic);
  });
}

void _encodeString() {
  expect(encodeTyped<String>('123'), equals('123'));
  expect(encodeTyped<String?>('123'), equals('123'));
  expect(encodeTyped<String>(''), equals(''));
  expect(encodeTyped<String?>(null), equals(null));
}

void _encodeDouble() {
  expect(encodeTyped<double>(123.456), equals(123.456));
  expect(encodeTyped<double?>(123.456), equals(123.456));
  expect(encodeTyped<double?>(null), equals(null));
}

void _encodeInt() {
  expect(encodeTyped<int>(123), equals(123));
  expect(encodeTyped<int?>(123), equals(123));
  expect(encodeTyped<int?>(null), equals(null));
}

void _encodeNum() {
  expect(encodeTyped<num>(123), equals(123));
  expect(encodeTyped<num>(123.456), equals(123.456));
  expect(encodeTyped<num?>(123), equals(123));
  expect(encodeTyped<num?>(123.456), equals(123.456));
  expect(encodeTyped<num?>(null), equals(null));
  expect(encodeTyped<num?>(null), equals(null));
}

void _encodeBool() {
  expect(encodeTyped<bool>(true), equals(true));
  expect(encodeTyped<bool?>(false), equals(false));
  expect(encodeTyped<bool?>(null), equals(null));
}

void _encodeDateTime() {
  expect(encodeTyped<DateTime>(DateTime(2022, 06, 15)),
      equals(DateTime(2022, 06, 15).toIso8601String()));
  expect(encodeTyped<DateTime?>(DateTime(1999, 12, 31)),
      equals(DateTime(1999, 12, 31).toIso8601String()));
  expect(encodeTyped<DateTime?>(null), equals(null));
}

void _encodeDuration() {
  expect(encodeTyped<Duration>(Duration(days: 50)),
      equals(Duration(days: 50).inMilliseconds));
  expect(encodeTyped<Duration?>(Duration(seconds: 12)),
      equals(Duration(seconds: 12).inMilliseconds));
  expect(encodeTyped<Duration?>(null), equals(null));
}

void _encodeUint8List() {
  final bytes = randomBytes(256);

  expect(encodeTyped<Uint8List>(bytes), equals(base64Encode(bytes)));
  expect(encodeTyped<Uint8List?>(bytes), equals(base64Encode(bytes)));
  expect(encodeTyped<Uint8List?>(null), equals(null));
}

void _encodeListString() {
  expect(encodeListTyped<List<String>, String>(['123', '456', '789']),
      equals(['123', '456', '789']));
  expect(encodeListTyped<List<String?>, String?>(['123', null, '789']),
      equals(['123', null, '789']));
  expect(encodeListTyped<List<String?>?, String?>(['123', null, '789']),
      equals(['123', null, '789']));
  expect(encodeListTyped<List<String>, String>([]), equals([]));
  expect(encodeListTyped<List<String?>?, String?>(null), equals(null));
  expect(encodeListTyped<List<String>?, String?>(null), equals(null));
  expect(encodeListTyped<List<String>, String?>(['123', '456', '789']),
      equals(['123', '456', '789']));
}

void _encodeListInt() {
  expect(encodeListTyped<List<int>, int>([123, 456, 789]),
      equals([123, 456, 789]));
  expect(encodeListTyped<List<int?>, int?>([123, null, 789]),
      equals([123, null, 789]));
  expect(encodeListTyped<List<int?>?, int?>([123, null, 789]),
      equals([123, null, 789]));
  expect(encodeListTyped<List<int>, int>([]), equals([]));
  expect(encodeListTyped<List<int?>?, int?>(null), equals(null));
  expect(encodeListTyped<List<int>?, int?>(null), equals(null));
  expect(encodeListTyped<List<int>, int?>([123, 456, 789]),
      equals([123, 456, 789]));
}

void _encodeListDateTime() {
  expect(
    encodeListTyped<List<DateTime>, DateTime>([
      DateTime(2022, 12, 10),
      DateTime(2020, 2, 5),
      DateTime(1999, 2, 3),
    ]),
    equals([
      DateTime(2022, 12, 10).toIso8601String(),
      DateTime(2020, 2, 5).toIso8601String(),
      DateTime(1999, 2, 3).toIso8601String(),
    ]),
  );
  expect(
    encodeListTyped<List<DateTime?>, DateTime?>([
      DateTime(2022, 12, 10),
      DateTime(2020, 2, 5),
      DateTime(1999, 2, 3),
    ]),
    equals([
      DateTime(2022, 12, 10).toIso8601String(),
      DateTime(2020, 2, 5).toIso8601String(),
      DateTime(1999, 2, 3).toIso8601String(),
    ]),
  );
  expect(
    encodeListTyped<List<DateTime?>, DateTime?>([
      DateTime(2022, 12, 10),
      null,
      DateTime(1999, 2, 3),
    ]),
    equals([
      DateTime(2022, 12, 10).toIso8601String(),
      null,
      DateTime(1999, 2, 3).toIso8601String(),
    ]),
  );
  expect(encodeListTyped<List<DateTime>, DateTime>([]), equals([]));
  expect(encodeListTyped<List<DateTime?>?, DateTime?>(null), equals(null));
  expect(encodeListTyped<List<DateTime>?, DateTime?>(null), equals(null));
  expect(encodeListTyped<List<DateTime>, DateTime?>([DateTime(2022, 12, 10)]),
      equals([DateTime(2022, 12, 10).toIso8601String()]));
}

void _encodeListUint8List() {
  final bytes1 = randomBytes(256);
  final bytes2 = randomBytes(256);

  expect(
    encodeListTyped<List<Uint8List>, Uint8List>([bytes1, bytes2]),
    equals([base64Encode(bytes1), base64Encode(bytes2)]),
  );
  expect(
    encodeListTyped<List<Uint8List>, Uint8List>([bytes1, bytes2]),
    equals([base64Encode(bytes1), base64Encode(bytes2)]),
  );
  expect(encodeListTyped<List<Uint8List>?, Uint8List>(null), equals(null));
  expect(
      encodeListTyped<List<Uint8List?>?, Uint8List?>([null]), equals([null]));
}

void _encodeMapString() {
  expect(
    encodeMapTyped<Map<String, String>, String>(
        {'key1': 'value1', 'key2': 'value2'}),
    equals({'key1': 'value1', 'key2': 'value2'}),
  );
  expect(
    encodeMapTyped<Map<String, String>?, String>(
        {'key1': 'value1', 'key2': 'value2'}),
    equals({'key1': 'value1', 'key2': 'value2'}),
  );
  expect(
    encodeMapTyped<Map<String, String>?, String>(null),
    equals(null),
  );
  expect(
    encodeMapTyped<Map<String, String?>, String?>(
        {'key1': 'value1', 'key2': null}),
    equals({'key1': 'value1', 'key2': null}),
  );
  expect(
    encodeMapTyped<Map<String, String?>?, String?>(
        {'key1': 'value1', 'key2': null}),
    equals({'key1': 'value1', 'key2': null}),
  );
}

void _encodeMapInt() {
  expect(
    encodeMapTyped<Map<String, int>, int>({'key1': 123, 'key2': 456}),
    equals({'key1': 123, 'key2': 456}),
  );
  expect(
    encodeMapTyped<Map<String, int>?, int>({'key1': 123, 'key2': 456}),
    equals({'key1': 123, 'key2': 456}),
  );
  expect(
    encodeMapTyped<Map<String, int>?, int>(null),
    equals(null),
  );
  expect(
    encodeMapTyped<Map<String, int?>, int?>({'key1': 123, 'key2': null}),
    equals({'key1': 123, 'key2': null}),
  );
  expect(
    encodeMapTyped<Map<String, int?>?, int?>({'key1': 123, 'key2': null}),
    equals({'key1': 123, 'key2': null}),
  );
}

void _encodeMapDateTime() {
  expect(
    encodeMapTyped<Map<String, DateTime>, DateTime>({
      'key1': DateTime(2022, 12, 2),
      'key2': DateTime(2023, 15, 2, 12, 2, 4),
    }),
    equals({
      'key1': DateTime(2022, 12, 2).toIso8601String(),
      'key2': DateTime(2023, 15, 2, 12, 2, 4).toIso8601String(),
    }),
  );
  expect(
    encodeMapTyped<Map<String, DateTime>?, DateTime>({
      'key1': DateTime(2022, 12, 2),
      'key2': DateTime(2023, 15, 2, 12, 2, 4),
    }),
    equals({
      'key1': DateTime(2022, 12, 2).toIso8601String(),
      'key2': DateTime(2023, 15, 2, 12, 2, 4).toIso8601String(),
    }),
  );
  expect(
    encodeMapTyped<Map<String, DateTime?>, DateTime?>({
      'key1': DateTime(2022, 12, 2),
      'key2': null,
    }),
    equals({
      'key1': DateTime(2022, 12, 2).toIso8601String(),
      'key2': null,
    }),
  );
  expect(
    encodeMapTyped<Map<String, DateTime>?, DateTime>(null),
    equals(null),
  );
}

void _encodeMapUint8List() {
  final bytes1 = randomBytes(256);
  final bytes2 = randomBytes(256);
  expect(
    encodeMapTyped<Map<String, Uint8List>, Uint8List>({
      'key1': bytes1,
      'key2': bytes2,
    }),
    equals({
      'key1': base64Encode(bytes1),
      'key2': base64Encode(bytes2),
    }),
  );
  expect(
    encodeMapTyped<Map<String, Uint8List>?, Uint8List>({
      'key1': bytes1,
      'key2': bytes2,
    }),
    equals({
      'key1': base64Encode(bytes1),
      'key2': base64Encode(bytes2),
    }),
  );
  expect(
    encodeMapTyped<Map<String, Uint8List?>, Uint8List?>({
      'key1': bytes1,
      'key2': null,
    }),
    equals({
      'key1': base64Encode(bytes1),
      'key2': null,
    }),
  );
  expect(
    encodeMapTyped<Map<String, Uint8List>?, Uint8List>(null),
    equals(null),
  );
}

void _encodeMapDynamic() {
  expect(
    encodeMapTyped<Map<String, dynamic>, dynamic>({
      'key': {'other': 123, 'mayBeNull': null}
    }),
    equals({
      'key': {'other': 123, 'mayBeNull': null}
    }),
  );
  expect(
    encodeMapTyped<Map<String, dynamic>?, dynamic>({
      'key': {'other': 123, 'mayBeNull': null}
    }),
    equals({
      'key': {'other': 123, 'mayBeNull': null}
    }),
  );
  expect(
    encodeMapTyped<Map<String, dynamic>?, dynamic>(null),
    equals(null),
  );
}

void _decodeString() {
  expect(decodeTyped<String>('abc'), equals('abc'));
  expect(decodeTyped<String>(123.456), equals('123.456'));
  expect(decodeTyped<String>(true), equals('true'));
  expect(decodeTyped<String?>('abc'), equals('abc'));
  expect(decodeTyped<String?>(123.456), equals('123.456'));
  expect(decodeTyped<String?>(true), equals('true'));
  expect(decodeTyped<String?>(null), equals(null));

  expect(() => decodeTyped<String>(null), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<String>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<String>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<String?>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<String?>(Object()), throwsA(isA<CodecException>()));
}

void _decodeDouble() {
  expect(decodeTyped<double>(123.456), equals(123.456));
  expect(decodeTyped<double>('123.456'), equals(123.456));
  expect(decodeTyped<double>(123), equals(123));
  expect(decodeTyped<double>('123'), equals(123));
  expect(decodeTyped<double?>(123.456), equals(123.456));
  expect(decodeTyped<double?>('123.456'), equals(123.456));
  expect(decodeTyped<double?>(123), equals(123));
  expect(decodeTyped<double?>('123'), equals(123));
  expect(decodeTyped<double?>(null), equals(null));

  expect(() => decodeTyped<double>(null), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<double>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<double>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<double>(true), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<double?>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<double?>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<double?>(true), throwsA(isA<CodecException>()));
}

void _decodeInt() {
  expect(decodeTyped<int>(123), equals(123));
  expect(decodeTyped<int>('123'), equals(123));
  expect(decodeTyped<int?>(123), equals(123));
  expect(decodeTyped<int?>('123'), equals(123));
  expect(decodeTyped<int?>(null), equals(null));

  expect(() => decodeTyped<int>(null), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<int>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<int>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<int>(true), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<int>(123.4), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<int?>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<int?>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<int?>(true), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<int?>(123.4), throwsA(isA<CodecException>()));
}

void _decodeNum() {
  expect(decodeTyped<num>(123.456), equals(123.456));
  expect(decodeTyped<num>('123.456'), equals(123.456));
  expect(decodeTyped<num>(123), equals(123));
  expect(decodeTyped<num>('123'), equals(123));
  expect(decodeTyped<num?>(123.456), equals(123.456));
  expect(decodeTyped<num?>('123.456'), equals(123.456));
  expect(decodeTyped<num?>(123), equals(123));
  expect(decodeTyped<num?>('123'), equals(123));
  expect(decodeTyped<num?>(null), equals(null));

  expect(() => decodeTyped<num>(null), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<num>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<num>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<num>(true), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<num?>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<num?>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<num?>(true), throwsA(isA<CodecException>()));
}

void _decodeBool() {
  expect(decodeTyped<bool>(1), equals(true));
  expect(decodeTyped<bool>(100), equals(true));
  expect(decodeTyped<bool>(0), equals(false));
  expect(decodeTyped<bool>(-10), equals(false));
  expect(decodeTyped<bool>(true), equals(true));
  expect(decodeTyped<bool>(false), equals(false));
  expect(decodeTyped<bool>('true'), equals(true));
  expect(decodeTyped<bool>('false'), equals(false));
  expect(decodeTyped<bool?>(1), equals(true));
  expect(decodeTyped<bool?>(100), equals(true));
  expect(decodeTyped<bool?>(0), equals(false));
  expect(decodeTyped<bool?>(-10), equals(false));
  expect(decodeTyped<bool?>(true), equals(true));
  expect(decodeTyped<bool?>(false), equals(false));
  expect(decodeTyped<bool?>('true'), equals(true));
  expect(decodeTyped<bool?>('false'), equals(false));
  expect(decodeTyped<bool?>(null), equals(null));

  expect(() => decodeTyped<bool>(null), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<bool>('abc'), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<bool>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<bool>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<bool?>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<bool?>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<bool?>('abc'), throwsA(isA<CodecException>()));
}

void _decodeDateTime() {
  expect(
      decodeTyped<DateTime>(DateTime(2022, 10, 10, 20, 10).toIso8601String()),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(decodeTyped<DateTime>(DateTime(2022, 10, 10, 20, 10).toString()),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(
      decodeTyped<DateTime>(
          DateTime(2022, 10, 10, 20, 10).millisecondsSinceEpoch),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(
      decodeTyped<DateTime?>(DateTime(2022, 10, 10, 20, 10).toIso8601String()),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(decodeTyped<DateTime?>(DateTime(2022, 10, 10, 20, 10).toString()),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(
      decodeTyped<DateTime?>(
          DateTime(2022, 10, 10, 20, 10).millisecondsSinceEpoch),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(decodeTyped<DateTime?>(null), equals(null));

  expect(() => decodeTyped<DateTime>(null), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<DateTime>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<DateTime>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<DateTime>(true), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<DateTime>(123.4), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<DateTime?>([]), throwsA(isA<CodecException>()));
  expect(
      () => decodeTyped<DateTime?>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<DateTime?>(true), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<DateTime?>(123.4), throwsA(isA<CodecException>()));
}

void _decodeDuration() {
  expect(decodeTyped<Duration>(Duration(seconds: 50).inMilliseconds),
      equals(Duration(seconds: 50)));
  expect(decodeTyped<Duration>(Duration(days: 100).inMilliseconds),
      equals(Duration(days: 100)));
  expect(decodeTyped<Duration?>(Duration(seconds: 50).inMilliseconds),
      equals(Duration(seconds: 50)));
  expect(decodeTyped<Duration?>(Duration(days: 100).inMilliseconds),
      equals(Duration(days: 100)));
  expect(decodeTyped<Duration?>(null), equals(null));

  expect(() => decodeTyped<Duration>(null), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Duration>([]), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Duration>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Duration>(true), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Duration>(123.4), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Duration?>([]), throwsA(isA<CodecException>()));
  expect(
      () => decodeTyped<Duration?>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Duration?>(true), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Duration?>(123.4), throwsA(isA<CodecException>()));
}

void _decodeUint8List() {
  final random = Random();
  final bytes =
      Uint8List.fromList(List.generate(256, (index) => random.nextInt(256)));

  expect(decodeTyped<Uint8List>(bytes), equals(bytes));
  expect(decodeTyped<Uint8List>(base64Encode(bytes)), equals(bytes));
  expect(decodeTyped<Uint8List?>(bytes), equals(bytes));
  expect(decodeTyped<Uint8List?>(base64Encode(bytes)), equals(bytes));
  expect(decodeTyped<Uint8List?>(null), equals(null));

  expect(() => decodeTyped<Uint8List>(null), throwsA(isA<CodecException>()));
  expect(
      () => decodeTyped<Uint8List>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Uint8List>(true), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Uint8List>(123.4), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Uint8List>('XX'), throwsA(isA<FormatException>()));
  expect(
      () => decodeTyped<Uint8List?>(Object()), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Uint8List?>(true), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Uint8List?>(123.4), throwsA(isA<CodecException>()));
  expect(() => decodeTyped<Uint8List?>('XX'), throwsA(isA<FormatException>()));
}

void _decodeListString() {
  expect(decodeListTyped<List<String>, String>(['123', '456', '789']),
      equals(['123', '456', '789']));
  expect(decodeListTyped<List<String>, String>([123.456, 789.012, 345.678]),
      equals(['123.456', '789.012', '345.678']));
  expect(decodeListTyped<List<String>, String>([true, false]),
      equals(['true', 'false']));

  expect(decodeListTyped<List<String?>, String?>(['123', null, '789']),
      equals(['123', null, '789']));
  expect(decodeListTyped<List<String?>, String?>([123.456, null, 345.678]),
      equals(['123.456', null, '345.678']));
  expect(decodeListTyped<List<String?>, String?>([true, null, false]),
      equals(['true', null, 'false']));

  expect(() => decodeListTyped<List<String>, String>(null),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<String>, String>('[]'),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<String>, String>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<String>, String>(['abc', null, 'def']),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<String>, String>(['abc', Object(), 'def']),
      throwsA(isA<CodecException>()));
}

void _decodeListInt() {
  expect(decodeListTyped<List<int>, int>([123, 456, 789]),
      equals([123, 456, 789]));
  expect(decodeListTyped<List<int>, int>(['123', '456', '789']),
      equals([123, 456, 789]));
  expect(decodeListTyped<List<int?>, int?>([null, '456', '789']),
      equals([null, 456, 789]));
  expect(decodeListTyped<List<int>?, int?>(null), equals(null));

  expect(() => decodeListTyped<List<int>, int>(null),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<int>, int>('[]'),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<int>, int>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<int>, int>([123, null, 789]),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<int>, int>([123, Object(), 789]),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<int?>, int?>([123, Object(), 789]),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<int?>, int?>([123, 789.012, 345]),
      throwsA(isA<CodecException>()));
}

void _decodeListDateTime() {
  expect(
    decodeListTyped<List<DateTime>, DateTime>([
      DateTime(2022, 12, 10).toIso8601String(),
      DateTime(2001, 6, 3, 12, 5, 3).toString()
    ]),
    equals([DateTime(2022, 12, 10), DateTime(2001, 6, 3, 12, 5, 3)]),
  );
  expect(
    decodeListTyped<List<DateTime?>, DateTime?>([
      DateTime(2022, 12, 10).toIso8601String(),
      DateTime(2001, 6, 3, 12, 5, 3).toString()
    ]),
    equals([DateTime(2022, 12, 10), DateTime(2001, 6, 3, 12, 5, 3)]),
  );
  expect(decodeListTyped<List<DateTime>?, DateTime?>(null), equals(null));

  expect(() => decodeListTyped<List<DateTime>, DateTime>(null),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<DateTime>, DateTime>('[]'),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<DateTime>, DateTime>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<DateTime>, DateTime>([123, null, 789]),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<DateTime>?, DateTime>([123, Object(), 789]),
      throwsA(isA<CodecException>()));
  expect(
      () => decodeListTyped<List<DateTime?>, DateTime?>([123, Object(), 789]),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<DateTime?>, DateTime?>([123, 789.012, 345]),
      throwsA(isA<CodecException>()));
}

void _decodeListUint8List() {
  final bytes1 = randomBytes(256);
  final bytes2 = randomBytes(256);
  expect(
    decodeListTyped<List<Uint8List>, Uint8List>([
      base64Encode(bytes1),
      base64Encode(bytes2),
    ]),
    equals([bytes1, bytes2]),
  );
  expect(
    decodeListTyped<List<Uint8List>, Uint8List>([
      base64Encode(bytes1),
      base64Encode(bytes2),
    ]),
    equals([bytes1, bytes2]),
  );
  expect(decodeListTyped<List<Uint8List>?, Uint8List>(null), equals(null));

  expect(() => decodeListTyped<List<Uint8List>, Uint8List>(null),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<Uint8List>, Uint8List>('XYXY'),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<Uint8List>, Uint8List>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => decodeListTyped<List<Uint8List>, Uint8List>([123, null, 789]),
      throwsA(isA<CodecException>()));
  expect(
      () => decodeListTyped<List<Uint8List>?, Uint8List>([123, Object(), 789]),
      throwsA(isA<CodecException>()));
  expect(
      () => decodeListTyped<List<Uint8List?>, Uint8List?>([123, Object(), 789]),
      throwsA(isA<CodecException>()));
  expect(
      () => decodeListTyped<List<Uint8List?>, Uint8List?>([123, 789.012, 345]),
      throwsA(isA<CodecException>()));
}

void _decodeMapString() {
  expect(
      decodeMapTyped<Map<String, String>, String>(
          {'key1': 'value1', 'key2': 123, 'key3': true, 'key4': 123.456}),
      equals({
        'key1': 'value1',
        'key2': '123',
        'key3': 'true',
        'key4': '123.456'
      }));
  expect(
      decodeMapTyped<Map<String, String?>, String?>(
          {'key1': 'value1', 'key2': null, 'key3': true, 'key4': 123.456}),
      equals(
          {'key1': 'value1', 'key2': null, 'key3': 'true', 'key4': '123.456'}));
  expect(decodeMapTyped<Map<String, String>?, String>(null), equals(null));
  expect(decodeMapTyped<Map<String, String?>?, String?>({}), equals({}));
  expect(
      () => decodeMapTyped<Map<String, String>, String>(
          {'key1': 'value1', 'key2': Object(), 'key3': true, 'key4': 123.456}),
      throwsA(isA<CodecException>()));
  expect(
      () => decodeMapTyped<Map<String, String>, String>(
          {'key1': 'value1', 'key2': null, 'key3': true, 'key4': 123.456}),
      throwsA(isA<CodecException>()));
  expect(
      () => decodeMapTyped<Map<String, String>, String>(
          {'key1': 'value1', 123: 'value2', 'key3': true, 'key4': 123.456}),
      throwsA(isA<CodecException>()));
  expect(() => decodeMapTyped<Map<String, String>, String>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => decodeMapTyped<Map<String, String>, String>([]),
      throwsA(isA<CodecException>()));
  expect(() => decodeMapTyped<Map<String, String>, String>(null),
      throwsA(isA<CodecException>()));
}

void _decodeMapInt() {
  expect(
      decodeMapTyped<Map<String, int>, int>(
          {'key1': '123', 'key2': 456, 'key3': '789', 'key4': 123}),
      equals({'key1': 123, 'key2': 456, 'key3': 789, 'key4': 123}));
  expect(
      decodeMapTyped<Map<String, int?>, int?>(
          {'key1': 123, 'key2': null, 'key3': '789', 'key4': 123}),
      equals({'key1': 123, 'key2': null, 'key3': 789, 'key4': 123}));
  expect(decodeMapTyped<Map<String, int>?, int>(null), equals(null));
  expect(decodeMapTyped<Map<String, int?>?, int?>(<int, int?>{}), equals({}));
  expect(
      () => decodeMapTyped<Map<String, int>, int>(
          {'key1': 'value1', 'key2': Object(), 'key3': true, 'key4': 123.456}),
      throwsA(isA<CodecException>()));
  expect(
      () => decodeMapTyped<Map<String, int>, int>(
          {'key1': 'value1', 'key2': null, 'key3': true, 'key4': 123.456}),
      throwsA(isA<CodecException>()));
  expect(
      () => decodeMapTyped<Map<String, int>, int>(
          {'key1': 'value1', 123: 'value2', 'key3': true, 'key4': 123.456}),
      throwsA(isA<CodecException>()));
  expect(() => decodeMapTyped<Map<String, int>, int>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => decodeMapTyped<Map<String, int>, int>([]),
      throwsA(isA<CodecException>()));
  expect(() => decodeMapTyped<Map<String, int>, int>(null),
      throwsA(isA<CodecException>()));
}

void _decodeMapDynamic() {
  expect(
    decodeMapTyped<Map<String, dynamic>, dynamic>({
      'key': {'other': 123, 'mayBeNull': null}
    }),
    equals({
      'key': {'other': 123, 'mayBeNull': null}
    }),
  );
  expect(
    decodeMapTyped<Map<String, dynamic>?, dynamic>({
      'key': {'other': 123, 'mayBeNull': null}
    }),
    equals({
      'key': {'other': 123, 'mayBeNull': null}
    }),
  );
  expect(
    decodeMapTyped<Map<String, dynamic>?, dynamic>(null),
    equals(null),
  );
  expect(() => decodeMapTyped<Map<String, dynamic>, dynamic>(null),
      throwsA(isA<CodecException>()));
  expect(() => decodeMapTyped<Map<String, dynamic>, dynamic>({123: '456'}),
      throwsA(isA<CodecException>()));
}

Uint8List randomBytes(int length) {
  final random = Random();
  return Uint8List.fromList(
      List.generate(length, (index) => random.nextInt(256)));
}
