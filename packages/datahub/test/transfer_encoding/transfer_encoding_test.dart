import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:datahub/datahub.dart';

const codec = JsonDataCodec();

void main() {
  group('Encode', () {
    test('String', _encodeString);
    test('double', _encodeDouble);
    test('int', _encodeInt);
    test('bool', _encodeBool);
    test('DateTime', _encodeDateTime);
    test('Duration', _encodeDuration);
    test('Uint8List', _encodeUint8List);
  });

  group('Encode List', () {
    test('List<String>', _encodeListString);
    test('List<int>', _encodeListInt);
    test('List<DateTime>', _encodeListDateTime);
  });
/*
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
  });*/
}

void _encodeString() {
  expect(codec.encodeString('123'), equals('123'));
  expect(
      codec.encodeNullable<String>('123', codec.encodeString), equals('123'));
  expect(codec.encodeString(''), equals(''));
  expect(codec.encodeNullable<String>(null, codec.encodeString), equals(null));
}

void _encodeDouble() {
  expect(codec.encodeDouble(123.456), equals(123.456));
  expect(codec.encodeNullable<double>(123.456, codec.encodeDouble),
      equals(123.456));
  expect(codec.encodeNullable<double>(123, codec.encodeDouble), equals(123.0));
  expect(codec.encodeNullable<double>(null, codec.encodeDouble), equals(null));
}

void _encodeInt() {
  expect(codec.encodeInt(123), equals(123));
  expect(codec.encodeNullable<int>(123, codec.encodeInt), equals(123));
  expect(codec.encodeNullable<int>(null, codec.encodeInt), equals(null));
}

void _encodeBool() {
  expect(codec.encodeBool(true), equals(true));
  expect(codec.encodeNullable<bool>(false, codec.encodeBool), equals(false));
  expect(codec.encodeNullable<bool>(null, codec.encodeBool), equals(null));
}

void _encodeDateTime() {
  expect(codec.encodeDateTime(DateTime.utc(2022, 06, 15)),
      equals(DateTime.utc(2022, 06, 15).toIso8601String()));
  expect(
      codec.encodeNullable<DateTime>(
          DateTime.utc(1999, 12, 31), codec.encodeDateTime),
      equals(DateTime.utc(1999, 12, 31).toIso8601String()));
  expect(
      codec.encodeNullable<DateTime>(null, codec.encodeDateTime), equals(null));
}

void _encodeDuration() {
  expect(codec.encodeDuration(Duration(days: 50)),
      equals(Duration(days: 50).inMilliseconds));
  expect(
      codec.encodeNullable<Duration>(
          Duration(seconds: 12), codec.encodeDuration),
      equals(Duration(seconds: 12).inMilliseconds));
  expect(
      codec.encodeNullable<Duration>(null, codec.encodeDuration), equals(null));
}

void _encodeUint8List() {
  final bytes = randomBytes(256).toList();

  expect(codec.encodeUint8List(Uint8List.fromList(bytes)),
      equals(base64Encode(bytes)));
}

void _encodeListString() {
  expect(codec.encodeList<String>(['123', '456', '789'], codec.encodeString),
      equals(['123', '456', '789']));
  expect(codec.encodeList<String>([], codec.encodeString), equals([]));
  expect(codec.encodeList<String>(['123', '456', '789'], codec.encodeString),
      equals(['123', '456', '789']));
}

void _encodeListInt() {
  expect(codec.encodeList<int>([123, 456, 789], codec.encodeInt),
      equals([123, 456, 789]));
  expect(codec.encodeList<int>([], codec.encodeInt), equals([]));
}

void _encodeListDateTime() {
  expect(
    codec.encodeList(
      [
        DateTime.utc(2022, 12, 10),
        DateTime.utc(2020, 2, 5),
        DateTime.utc(1999, 2, 3),
      ],
      codec.encodeDateTime,
    ),
    equals([
      DateTime.utc(2022, 12, 10).toIso8601String(),
      DateTime.utc(2020, 2, 5).toIso8601String(),
      DateTime.utc(1999, 2, 3).toIso8601String(),
    ]),
  );
  expect(
    codec.encodeList(
      [
        DateTime.utc(2022, 12, 10),
        DateTime.utc(2020, 2, 5),
        DateTime.utc(1999, 2, 3),
      ],
      codec.encodeDateTime,
    ),
    equals([
      DateTime.utc(2022, 12, 10).toIso8601String(),
      DateTime.utc(2020, 2, 5).toIso8601String(),
      DateTime.utc(1999, 2, 3).toIso8601String(),
    ]),
  );
  expect(
    codec.encodeList<DateTime?>(
      [
        DateTime.utc(2022, 12, 10),
        null,
        DateTime.utc(1999, 2, 3),
      ],
      (v) => codec.encodeNullable(v, codec.encodeDateTime),
    ),
    equals([
      DateTime.utc(2022, 12, 10).toIso8601String(),
      null,
      DateTime.utc(1999, 2, 3).toIso8601String(),
    ]),
  );
}
/*

void _encodeMapString() {
  expect(
    codec.encodeMap<Map<String, String>, String>(
        {'key1': 'value1', 'key2': 'value2'}),
    equals({'key1': 'value1', 'key2': 'value2'}),
  );
  expect(
    codec.encodeMap<Map<String, String>?, String>(
        {'key1': 'value1', 'key2': 'value2'}),
    equals({'key1': 'value1', 'key2': 'value2'}),
  );
  expect(
    codec.encodeMap<Map<String, String>?, String>(null),
    equals(null),
  );
  expect(
    codec.encodeMap<Map<String, String?>, String?>(
        {'key1': 'value1', 'key2': null}),
    equals({'key1': 'value1', 'key2': null}),
  );
  expect(
    codec.encodeMap<Map<String, String?>?, String?>(
        {'key1': 'value1', 'key2': null}),
    equals({'key1': 'value1', 'key2': null}),
  );
}

void _encodeMapInt() {
  expect(
    codec.encodeMap<Map<String, int>, int>({'key1': 123, 'key2': 456}),
    equals({'key1': 123, 'key2': 456}),
  );
  expect(
    codec.encodeMap<Map<String, int>?, int>({'key1': 123, 'key2': 456}),
    equals({'key1': 123, 'key2': 456}),
  );
  expect(
    codec.encodeMap<Map<String, int>?, int>(null),
    equals(null),
  );
  expect(
    codec.encodeMap<Map<String, int?>, int?>({'key1': 123, 'key2': null}),
    equals({'key1': 123, 'key2': null}),
  );
  expect(
    codec.encodeMap<Map<String, int?>?, int?>({'key1': 123, 'key2': null}),
    equals({'key1': 123, 'key2': null}),
  );
}

void _encodeMapDateTime() {
  expect(
    codec.encodeMap<Map<String, DateTime>, DateTime>({
      'key1': DateTime.utc(2022, 12, 2),
      'key2': DateTime.utc(2023, 15, 2, 12, 2, 4),
    }),
    equals({
      'key1': DateTime.utc(2022, 12, 2).toIso8601String(),
      'key2': DateTime.utc(2023, 15, 2, 12, 2, 4).toIso8601String(),
    }),
  );
  expect(
    codec.encodeMap<Map<String, DateTime>?, DateTime>({
      'key1': DateTime.utc(2022, 12, 2),
      'key2': DateTime.utc(2023, 15, 2, 12, 2, 4),
    }),
    equals({
      'key1': DateTime.utc(2022, 12, 2).toIso8601String(),
      'key2': DateTime.utc(2023, 15, 2, 12, 2, 4).toIso8601String(),
    }),
  );
  expect(
    codec.encodeMap<Map<String, DateTime?>, DateTime?>({
      'key1': DateTime.utc(2022, 12, 2),
      'key2': null,
    }),
    equals({
      'key1': DateTime.utc(2022, 12, 2).toIso8601String(),
      'key2': null,
    }),
  );
  expect(
    codec.encodeMap<Map<String, DateTime>?, DateTime>(null),
    equals(null),
  );
}

void _encodeMapUint8List() {
  final bytes1 = randomBytes(256);
  final bytes2 = randomBytes(256);
  expect(
    codec.encodeMap<Map<String, Uint8List>, Uint8List>({
      'key1': bytes1,
      'key2': bytes2,
    }),
    equals({
      'key1': base64Encode(bytes1),
      'key2': base64Encode(bytes2),
    }),
  );
  expect(
    codec.encodeMap<Map<String, Uint8List>?, Uint8List>({
      'key1': bytes1,
      'key2': bytes2,
    }),
    equals({
      'key1': base64Encode(bytes1),
      'key2': base64Encode(bytes2),
    }),
  );
  expect(
    codec.encodeMap<Map<String, Uint8List?>, Uint8List?>({
      'key1': bytes1,
      'key2': null,
    }),
    equals({
      'key1': base64Encode(bytes1),
      'key2': null,
    }),
  );
  expect(
    codec.encodeMap<Map<String, Uint8List>?, Uint8List>(null),
    equals(null),
  );
}

void _encodeMapDynamic() {
  expect(
    codec.encodeMap<Map<String, dynamic>, dynamic>({
      'key': {'other': 123, 'mayBeNull': null}
    }),
    equals({
      'key': {'other': 123, 'mayBeNull': null}
    }),
  );
  expect(
    codec.encodeMap<Map<String, dynamic>?, dynamic>({
      'key': {'other': 123, 'mayBeNull': null}
    }),
    equals({
      'key': {'other': 123, 'mayBeNull': null}
    }),
  );
  expect(
    codec.encodeMap<Map<String, dynamic>?, dynamic>(null),
    equals(null),
  );
}

void _decodeString() {
  expect(codec.decode<String>('abc'), equals('abc'));
  expect(codec.decode<String>(123.456), equals('123.456'));
  expect(codec.decode<String>(true), equals('true'));
  expect(
      codec.decodeNullable<String>('abc', codec.decodeString), equals('abc'));
  expect(codec.decodeNullable<String>(123.456, codec.decodeString),
      equals('123.456'));
  expect(
      codec.decodeNullable<String>(true, codec.decodeString), equals('true'));
  expect(codec.decodeNullable<String>(null, codec.decodeString), equals(null));

  expect(() => codec.decode<String>(null), throwsA(isA<CodecException>()));
  expect(() => codec.decode<String>([]), throwsA(isA<CodecException>()));
  expect(() => codec.decode<String>(Object()), throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<String>([], codec.decodeString),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<String>(Object(, codec.decodeString)),
      throwsA(isA<CodecException>()));
}

void _decodeDouble() {
  expect(codec.decode<double>(123.456), equals(123.456));
  expect(codec.decode<double>('123.456'), equals(123.456));
  expect(codec.decode<double>(123), equals(123));
  expect(codec.decode<double>('123'), equals(123));
  expect(codec.decodeNullable<double>(123.456, codec.decodeDouble),
      equals(123.456));
  expect(codec.decodeNullable<double>('123.456', codec.decodeDouble),
      equals(123.456));
  expect(codec.decodeNullable<double>(123, codec.decodeDouble), equals(123));
  expect(codec.decodeNullable<double>('123', codec.decodeDouble), equals(123));
  expect(codec.decodeNullable<double>(null, codec.decodeDouble), equals(null));

  expect(() => codec.decode<double>(null), throwsA(isA<CodecException>()));
  expect(() => codec.decode<double>([]), throwsA(isA<CodecException>()));
  expect(() => codec.decode<double>(Object()), throwsA(isA<CodecException>()));
  expect(() => codec.decode<double>(true), throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<double>([], codec.decodeDouble),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<double>(Object(, codec.decodeDouble)),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<double>(true, codec.decodeDouble),
      throwsA(isA<CodecException>()));
}

void _decodeInt() {
  expect(codec.decode<int>(123), equals(123));
  expect(codec.decode<int>('123'), equals(123));
  expect(codec.decodeNullable<int>(123, codec.decodeInt), equals(123));
  expect(codec.decodeNullable<int>('123', codec.decodeInt), equals(123));
  expect(codec.decodeNullable<int>(null, codec.decodeInt), equals(null));

  expect(() => codec.decode<int>(null), throwsA(isA<CodecException>()));
  expect(() => codec.decode<int>([]), throwsA(isA<CodecException>()));
  expect(() => codec.decode<int>(Object()), throwsA(isA<CodecException>()));
  expect(() => codec.decode<int>(true), throwsA(isA<CodecException>()));
  expect(() => codec.decode<int>(123.4), throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<int>([], codec.decodeInt),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<int>(Object(, codec.decodeInt)),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<int>(true, codec.decodeInt),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<int>(123.4, codec.decodeInt),
      throwsA(isA<CodecException>()));
}

void _decodeNum() {
  expect(codec.decode<num>(123.456), equals(123.456));
  expect(codec.decode<num>('123.456'), equals(123.456));
  expect(codec.decode<num>(123), equals(123));
  expect(codec.decode<num>('123'), equals(123));
  expect(codec.decodeNullable<num>(123.456, codec.decodeNum), equals(123.456));
  expect(
      codec.decodeNullable<num>('123.456', codec.decodeNum), equals(123.456));
  expect(codec.decodeNullable<num>(123, codec.decodeNum), equals(123));
  expect(codec.decodeNullable<num>('123', codec.decodeNum), equals(123));
  expect(codec.decodeNullable<num>(null, codec.decodeNum), equals(null));

  expect(() => codec.decode<num>(null), throwsA(isA<CodecException>()));
  expect(() => codec.decode<num>([]), throwsA(isA<CodecException>()));
  expect(() => codec.decode<num>(Object()), throwsA(isA<CodecException>()));
  expect(() => codec.decode<num>(true), throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<num>([], codec.decodeNum),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<num>(Object(, codec.decodeNum)),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<num>(true, codec.decodeNum),
      throwsA(isA<CodecException>()));
}

void _decodeBool() {
  expect(codec.decode<bool>(1), equals(true));
  expect(codec.decode<bool>(100), equals(true));
  expect(codec.decode<bool>(0), equals(false));
  expect(codec.decode<bool>(-10), equals(false));
  expect(codec.decode<bool>(true), equals(true));
  expect(codec.decode<bool>(false), equals(false));
  expect(codec.decode<bool>('true'), equals(true));
  expect(codec.decode<bool>('false'), equals(false));
  expect(codec.decodeNullable<bool>(1, codec.decodeBool), equals(true));
  expect(codec.decodeNullable<bool>(100, codec.decodeBool), equals(true));
  expect(codec.decodeNullable<bool>(0, codec.decodeBool), equals(false));
  expect(codec.decodeNullable<bool>(-10, codec.decodeBool), equals(false));
  expect(codec.decodeNullable<bool>(true, codec.decodeBool), equals(true));
  expect(codec.decodeNullable<bool>(false, codec.decodeBool), equals(false));
  expect(codec.decodeNullable<bool>('true', codec.decodeBool), equals(true));
  expect(codec.decodeNullable<bool>('false', codec.decodeBool), equals(false));
  expect(codec.decodeNullable<bool>(null, codec.decodeBool), equals(null));

  expect(() => codec.decode<bool>(null), throwsA(isA<CodecException>()));
  expect(() => codec.decode<bool>('abc'), throwsA(isA<CodecException>()));
  expect(() => codec.decode<bool>([]), throwsA(isA<CodecException>()));
  expect(() => codec.decode<bool>(Object()), throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<bool>([], codec.decodeBool),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<bool>(Object(, codec.decodeBool)),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<bool>('abc', codec.decodeBool),
      throwsA(isA<CodecException>()));
}

void _decodeDateTime() {
  //TODO tests for local datetime (problematic on different machines)
  expect(
      codec.decode<DateTime>(DateTime(2022, 10, 10, 20, 10).toIso8601String()),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(codec.decode<DateTime>(DateTime(2022, 10, 10, 20, 10).toString()),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(
      codec.decode<DateTime>(
          DateTime(2022, 10, 10, 20, 10).millisecondsSinceEpoch),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(codec.decodeNullable<DateTime>(
      DateTime(2022, 10, 10, 20, 10, codec.decodeDateTime).toIso8601String()),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(codec.decodeNullable<DateTime>(
      DateTime(2022, 10, 10, 20, 10, codec.decodeDateTime).toString()),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(
      codec.decodeNullable<DateTime>(
          DateTime(2022, 10, 10, 20, 10, codec.decodeDateTime)
              .millisecondsSinceEpoch),
      equals(DateTime(2022, 10, 10, 20, 10)));
  expect(
      codec.decodeNullable<DateTime>(null, codec.decodeDateTime), equals(null));

  expect(() => codec.decode<DateTime>(null), throwsA(isA<CodecException>()));
  expect(() => codec.decode<DateTime>([]), throwsA(isA<CodecException>()));
  expect(
          () => codec.decode<DateTime>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => codec.decode<DateTime>(true), throwsA(isA<CodecException>()));
  expect(() => codec.decode<DateTime>(123.4), throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<DateTime>([], codec.decodeDateTime),
      throwsA(isA<CodecException>()));
  expect(
          () => codec.decode<DateTime?>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<DateTime>(true, codec.decodeDateTime),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<DateTime>(123.4, codec.decodeDateTime),
      throwsA(isA<CodecException>()));
}

void _decodeDuration() {
  expect(codec.decodeDuration(Duration(seconds: 50).inMilliseconds),
      equals(Duration(seconds: 50)));
  expect(codec.decodeDuration(Duration(days: 100).inMilliseconds),
      equals(Duration(days: 100)));
  expect(codec.decode<Duration?>(Duration(seconds: 50).inMilliseconds),
      equals(Duration(seconds: 50)));
  expect(codec.decode<Duration?>(Duration(days: 100).inMilliseconds),
      equals(Duration(days: 100)));
  expect(
      codec.decodeNullable<Duration>(null, codec.decodeDuration), equals(null));

  expect(() => codec.decodeDuration(null), throwsA(isA<CodecException>()));
  expect(() => codec.decodeDuration([]), throwsA(isA<CodecException>()));
  expect(
          () => codec.decodeDuration(Object()), throwsA(isA<CodecException>()));
  expect(() => codec.decodeDuration(true), throwsA(isA<CodecException>()));
  expect(() => codec.decodeDuration(123.4), throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<Duration>([], codec.decodeDuration),
      throwsA(isA<CodecException>()));
  expect(
          () => codec.decode<Duration?>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<Duration>(true, codec.decodeDuration),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<Duration>(123.4, codec.decodeDuration),
      throwsA(isA<CodecException>()));
}

void _decodeUint8List() {
  final random = Random();
  final bytes =
  Uint8List.fromList(List.generate(256, (index) => random.nextInt(256)));

  expect(codec.decodeUint8List(bytes), equals(bytes));
  expect(codec.decodeUint8List(base64Encode(bytes)), equals(bytes));
  expect(codec.decodeNullable<Uint8List>(bytes, codec.decodeUint8List),
      equals(bytes));
  expect(codec.decode<Uint8List?>(base64Encode(bytes)), equals(bytes));
  expect(codec.decodeNullable<Uint8List>(null, codec.decodeUint8List),
      equals(null));

  expect(() => codec.decodeUint8List(null), throwsA(isA<CodecException>()));
  expect(
          () => codec.decodeUint8List(Object()),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeUint8List(true), throwsA(isA<CodecException>()));
  expect(() => codec.decodeUint8List(123.4), throwsA(isA<CodecException>()));
  expect(() => codec.decodeUint8List('XX'), throwsA(isA<FormatException>()));
  expect(
          () => codec.decode<Uint8List?>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<Uint8List>(true, codec.decodeUint8List),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<Uint8List>(123.4, codec.decodeUint8List),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeNullable<Uint8List>('XX', codec.decodeUint8List),
      throwsA(isA<FormatException>()));
}

void _decodeListString() {
  expect(
      codec.decodeList(['123', '456', '789']), equals(['123', '456', '789']));
  expect(codec.decodeList([123.456, 789.012, 345.678]),
      equals(['123.456', '789.012', '345.678']));
  expect(codec.decodeList([true, false]), equals(['true', 'false']));

  expect(codec.decodeList(['123', null, '789']), equals(['123', null, '789']));
  expect(codec.decodeList([123.456, null, 345.678]),
      equals(['123.456', null, '345.678']));
  expect(
      codec.decodeList([true, null, false]), equals(['true', null, 'false']));

  expect(() => codec.decodeList(null), throwsA(isA<CodecException>()));
  expect(() => codec.decodeList('[]'), throwsA(isA<CodecException>()));
  expect(() => codec.decodeList(Object()), throwsA(isA<CodecException>()));
  expect(() => codec.decodeList(['abc', null, 'def']),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeList(['abc', Object(), 'def']),
      throwsA(isA<CodecException>()));
}

void _decodeListInt() {
  expect(codec.decodeList([123, 456, 789]), equals([123, 456, 789]));
  expect(codec.decodeList(['123', '456', '789']), equals([123, 456, 789]));
  expect(codec.decodeList([null, '456', '789']), equals([null, 456, 789]));
  expect(codec.decodeList(null), equals(null));

  expect(() => codec.decodeList(null), throwsA(isA<CodecException>()));
  expect(() => codec.decodeList('[]'), throwsA(isA<CodecException>()));
  expect(() => codec.decodeList(Object()), throwsA(isA<CodecException>()));
  expect(
          () => codec.decodeList([123, null, 789]),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeList([123, Object(), 789]),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeList([123, Object(), 789]),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeList([123, 789.012, 345]),
      throwsA(isA<CodecException>()));
}

void _decodeListDateTime() {
  expect(
    codec.decodeList(
      [
        DateTime(2022, 12, 10).toIso8601String(),
        DateTime(2001, 6, 3, 12, 5, 3).toString(),
      ],
      codec.decodeDateTime,
    ),
    equals([DateTime(2022, 12, 10), DateTime(2001, 6, 3, 12, 5, 3)]),
  );
  expect(
    codec.decodeList(
      [
        DateTime(2022, 12, 10).toIso8601String(),
        DateTime(2001, 6, 3, 12, 5, 3).toString()
      ],
      codec.decodeDateTime,
    ),
    equals([DateTime(2022, 12, 10), DateTime(2001, 6, 3, 12, 5, 3)]),
  );
  expect(codec.decodeList<DateTime>(null, codec.decodeDateTime), equals(null));

  expect(() => codec.decodeList<DateTime>(null, codec.decodeDateTime),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeList<DateTime>('[]', codec.decodeDateTime),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeList<DateTime>(Object(), codec.decodeDateTime),
      throwsA(isA<CodecException>()));
  expect(
          () =>
          codec.decodeList<DateTime>([123, null, 789], codec.decodeDateTime),
      throwsA(isA<CodecException>()));
  expect(
          () =>
          codec
              .decodeList<DateTime>([123, Object(), 789], codec.decodeDateTime),
      throwsA(isA<CodecException>()));
  expect(
          () =>
          codec
              .decodeList<DateTime>([123, Object(), 789], codec.decodeDateTime),
      throwsA(isA<CodecException>()));
  expect(
          () =>
          codec.decodeList<DateTime>([123, 789.012, 345], codec.decodeDateTime),
      throwsA(isA<CodecException>()));
}

void _decodeListUint8List() {
  final bytes1 = randomBytes(256);
  final bytes2 = randomBytes(256);
  expect(
    codec.decodeList([
      base64Encode(bytes1),
      base64Encode(bytes2),
    ]),
    equals([bytes1, bytes2]),
  );
  expect(
    codec.decodeList([
      base64Encode(bytes1),
      base64Encode(bytes2),
    ]),
    equals([bytes1, bytes2]),
  );
  expect(codec.decodeList(null), equals(null));

  expect(() => codec.decodeList(null), throwsA(isA<CodecException>()));
  expect(() => codec.decodeList('XYXY'), throwsA(isA<CodecException>()));
  expect(() => codec.decodeList(Object()), throwsA(isA<CodecException>()));
  expect(
          () => codec.decodeList([123, null, 789]),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeList([123, Object(), 789]),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeList([123, Object(), 789]),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeList([123, 789.012, 345]),
      throwsA(isA<CodecException>()));
}

void _decodeMapString() {
  expect(
      codec.decodeMap<Map<String, String>, String>(
          {'key1': 'value1', 'key2': 123, 'key3': true, 'key4': 123.456}),
      equals({
        'key1': 'value1',
        'key2': '123',
        'key3': 'true',
        'key4': '123.456'
      }));
  expect(
      codec.decodeMap<Map<String, String?>, String?>(
          {'key1': 'value1', 'key2': null, 'key3': true, 'key4': 123.456}),
      equals(
          {'key1': 'value1', 'key2': null, 'key3': 'true', 'key4': '123.456'}));
  expect(codec.decodeMap<Map<String, String>?, String>(null), equals(null));
  expect(codec.decodeMap<Map<String, String?>?, String?>({}), equals({}));
  expect(
          () =>
          codec.decodeMap<Map<String, String>, String>(
              {
                'key1': 'value1',
                'key2': Object(),
                'key3': true,
                'key4': 123.456
              }),
      throwsA(isA<CodecException>()));
  expect(
          () =>
          codec.decodeMap<Map<String, String>, String>(
              {'key1': 'value1', 'key2': null, 'key3': true, 'key4': 123.456}),
      throwsA(isA<CodecException>()));
  expect(
          () =>
          codec.decodeMap<Map<String, String>, String>(
              {'key1': 'value1', 123: 'value2', 'key3': true, 'key4': 123.456}),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeMap<Map<String, String>, String>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeMap<Map<String, String>, String>([]),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeMap<Map<String, String>, String>(null),
      throwsA(isA<CodecException>()));
}

void _decodeMapInt() {
  expect(
      codec.decodeMap<Map<String, int>, int>(
          {'key1': '123', 'key2': 456, 'key3': '789', 'key4': 123}),
      equals({'key1': 123, 'key2': 456, 'key3': 789, 'key4': 123}));
  expect(
      codec.decodeMap<Map<String, int?>, int?>(
          {'key1': 123, 'key2': null, 'key3': '789', 'key4': 123}),
      equals({'key1': 123, 'key2': null, 'key3': 789, 'key4': 123}));
  expect(codec.decodeMap<Map<String, int>?, int>(null), equals(null));
  expect(codec.decodeMap<Map<String, int?>?, int?>(<int, int?>{}), equals({}));
  expect(
          () =>
          codec.decodeMap<Map<String, int>, int>(
              {
                'key1': 'value1',
                'key2': Object(),
                'key3': true,
                'key4': 123.456
              }),
      throwsA(isA<CodecException>()));
  expect(
          () =>
          codec.decodeMap<Map<String, int>, int>(
              {'key1': 'value1', 'key2': null, 'key3': true, 'key4': 123.456}),
      throwsA(isA<CodecException>()));
  expect(
          () =>
          codec.decodeMap<Map<String, int>, int>(
              {'key1': 'value1', 123: 'value2', 'key3': true, 'key4': 123.456}),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeMap<Map<String, int>, int>(Object()),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeMap<Map<String, int>, int>([]),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeMap<Map<String, int>, int>(null),
      throwsA(isA<CodecException>()));
}

void _decodeMapDynamic() {
  expect(
    codec.decodeMap<Map<String, dynamic>, dynamic>({
      'key': {'other': 123, 'mayBeNull': null}
    }),
    equals({
      'key': {'other': 123, 'mayBeNull': null}
    }),
  );
  expect(
    codec.decodeMap<Map<String, dynamic>?, dynamic>({
      'key': {'other': 123, 'mayBeNull': null}
    }),
    equals({
      'key': {'other': 123, 'mayBeNull': null}
    }),
  );
  expect(
    codec.decodeMap<Map<String, dynamic>?, dynamic>(null),
    equals(null),
  );
  expect(() => codec.decodeMap<Map<String, dynamic>, dynamic>(null),
      throwsA(isA<CodecException>()));
  expect(() => codec.decodeMap<Map<String, dynamic>, dynamic>({123: '456'}),
      throwsA(isA<CodecException>()));
}

Uint8List randomBytes(int length) {
  final random = Random();
  return Uint8List.fromList(
      List.generate(length, (index) => random.nextInt(256)));
}
*/
