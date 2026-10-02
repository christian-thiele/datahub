import 'dart:convert';
import 'dart:typed_data';

import 'package:datahub_redis/datahub_redis.dart';
import 'package:datahub_redis/src/protocol/resp_parser.dart';
import 'package:test/test.dart';

Uint8List _bytes(String value) => Uint8List.fromList(latin1.encode(value));

List<RedisReply> _parseAll(RespParser parser) => [
  for (var reply = parser.next(); reply != null; reply = parser.next()) reply,
];

List<RedisReply> _parse(String data) {
  final parser = RespParser()..add(_bytes(data));
  final replies = _parseAll(parser);
  expect(parser.hasPartialReply, isFalse);
  return replies;
}

/// Feeds [data] in chunks of [chunkSize] bytes and collects all replies.
List<RedisReply> _parseChunked(Uint8List data, int chunkSize) {
  final parser = RespParser();
  final replies = <RedisReply>[];
  for (var offset = 0; offset < data.length; offset += chunkSize) {
    final end = offset + chunkSize > data.length
        ? data.length
        : offset + chunkSize;
    parser.add(Uint8List.sublistView(data, offset, end));
    replies.addAll(_parseAll(parser));
  }
  expect(parser.hasPartialReply, isFalse);
  return replies;
}

void main() {
  group('RespParser', () {
    test('parses simple strings, errors and integers', () {
      expect(
        _parse('+OK\r\n-ERR unknown command\r\n:42\r\n:-7\r\n:0\r\n'),
        equals([
          const RedisSimpleString('OK'),
          const RedisErrorReply('ERR unknown command'),
          const RedisInteger(42),
          const RedisInteger(-7),
          const RedisInteger(0),
        ]),
      );
    });

    test('parses 64 bit integers', () {
      expect(
        _parse(':9223372036854775807\r\n:-9223372036854775808\r\n'),
        equals([
          const RedisInteger(9223372036854775807),
          const RedisInteger(-9223372036854775808),
        ]),
      );
    });

    test('parses bulk strings, empty and null bulk strings', () {
      expect(
        _parse('\$5\r\nhello\r\n\$0\r\n\r\n\$-1\r\n'),
        equals([
          RedisBulkString.fromString('hello'),
          RedisBulkString(Uint8List(0)),
          const RedisNull(),
        ]),
      );
    });

    test('bulk strings are binary safe', () {
      final payload = Uint8List.fromList([0, 13, 10, 255, 254, 36, 42]);
      final data = BytesBuilder()
        ..add(_bytes('\$7\r\n'))
        ..add(payload)
        ..add(_bytes('\r\n'));
      final parser = RespParser()..add(data.takeBytes());

      final reply = parser.next();
      expect(reply, isA<RedisBulkString>());
      expect((reply as RedisBulkString).bytes, equals(payload));
      expect(() => reply.asString, throwsFormatException);
    });

    test('parses arrays, empty arrays and null arrays', () {
      expect(
        _parse('*2\r\n\$3\r\nfoo\r\n:1\r\n*0\r\n*-1\r\n'),
        equals([
          RedisArray([
            RedisBulkString.fromString('foo'),
            const RedisInteger(1),
          ]),
          const RedisArray([]),
          const RedisNull(),
        ]),
      );
    });

    test('distinguishes a null array from an array holding null', () {
      // MGET of a single missing key vs. an aborted EXEC
      expect(
        _parse('*1\r\n\$-1\r\n*-1\r\n'),
        equals([
          const RedisArray([RedisNull()]),
          const RedisNull(),
        ]),
      );
    });

    test('parses nested arrays with errors inside', () {
      expect(
        _parse(
          '*3\r\n'
          '*2\r\n:1\r\n*1\r\n+inner\r\n'
          '-WRONGTYPE Operation against a key\r\n'
          '*0\r\n',
        ),
        equals([
          const RedisArray([
            RedisArray([
              RedisInteger(1),
              RedisArray([RedisSimpleString('inner')]),
            ]),
            RedisErrorReply('WRONGTYPE Operation against a key'),
            RedisArray([]),
          ]),
        ]),
      );
    });

    test('decodes UTF-8 in simple strings and bulk strings', () {
      final data = BytesBuilder()
        ..add(_bytes('+'))
        ..add(utf8.encode('grüße'))
        ..add(_bytes('\r\n\$${utf8.encode('日本').length}\r\n'))
        ..add(utf8.encode('日本'))
        ..add(_bytes('\r\n'));
      final parser = RespParser()..add(data.takeBytes());

      expect(parser.next()?.asString, equals('grüße'));
      expect(parser.next()?.asString, equals('日本'));
    });

    test('returns replies split at every possible byte', () {
      final data = _bytes(
        '+OK\r\n'
        '*3\r\n\$5\r\nhello\r\n*2\r\n:1\r\n\$-1\r\n-ERR x\r\n'
        '\$12\r\nhello\r\nworld\r\n'
        ':123456789\r\n',
      );
      final expected = [
        const RedisSimpleString('OK'),
        RedisArray([
          RedisBulkString.fromString('hello'),
          const RedisArray([RedisInteger(1), RedisNull()]),
          const RedisErrorReply('ERR x'),
        ]),
        RedisBulkString.fromString('hello\r\nworld'),
        const RedisInteger(123456789),
      ];

      for (var chunkSize = 1; chunkSize <= data.length; chunkSize++) {
        expect(
          _parseChunked(data, chunkSize),
          equals(expected),
          reason: 'chunk size $chunkSize',
        );
      }
    });

    test('returns null until a reply is complete', () {
      final parser = RespParser()..add(_bytes('*2\r\n\$3\r\nfo'));
      expect(parser.next(), isNull);
      expect(parser.hasPartialReply, isTrue);

      parser.add(_bytes('o\r\n'));
      expect(parser.next(), isNull);

      parser.add(_bytes(':5\r\n+next'));
      expect(
        parser.next(),
        equals(
          RedisArray([
            RedisBulkString.fromString('foo'),
            const RedisInteger(5),
          ]),
        ),
      );
      expect(parser.next(), isNull);

      parser.add(_bytes('\r\n'));
      expect(parser.next(), equals(const RedisSimpleString('next')));
      expect(parser.hasPartialReply, isFalse);
    });

    test('parses large replies arriving in many chunks', () {
      const count = 20000;
      final builder = BytesBuilder()..add(_bytes('*$count\r\n'));
      for (var i = 0; i < count; i++) {
        final value = 'value-$i';
        builder.add(_bytes('\$${value.length}\r\n$value\r\n'));
      }
      final big = Uint8List(3 * 1024 * 1024);
      for (var i = 0; i < big.length; i++) {
        big[i] = i % 251;
      }
      builder
        ..add(_bytes('\$${big.length}\r\n'))
        ..add(big)
        ..add(_bytes('\r\n'));

      final replies = _parseChunked(builder.takeBytes(), 1500);

      expect(replies, hasLength(2));
      final items = replies.first.asList!;
      expect(items, hasLength(count));
      expect(items.first.asString, equals('value-0'));
      expect(items.last.asString, equals('value-${count - 1}'));
      expect(replies.last.asBytes, equals(big));
    });

    test('copies bulk strings out of the receive buffer', () {
      final chunk = _bytes('\$3\r\nabc\r\n');
      final parser = RespParser()..add(chunk);
      final reply = parser.next() as RedisBulkString;

      chunk.fillRange(0, chunk.length, 0);
      expect(reply.asString, equals('abc'));
    });

    group('rejects invalid data', () {
      for (final (description, data) in [
        ('unknown type byte', '?foo\r\n'),
        ('RESP3 map', '%1\r\n+a\r\n+b\r\n'),
        ('RESP3 null', '_\r\n'),
        ('invalid integer', ':12a\r\n'),
        ('empty integer', ':\r\n'),
        ('integer with too many digits', ':123456789012345678901\r\n'),
        ('negative bulk length', '\$-2\r\n'),
        ('bulk length above limit', '\$${RespParser.maxBulkLength + 1}\r\n'),
        ('missing bulk terminator', '\$3\r\nabcde\r\n'),
        ('negative array length', '*-2\r\n'),
        ('CR without LF', '+OK\rX\n'),
      ]) {
        test(description, () {
          final parser = RespParser()..add(_bytes(data));
          expect(parser.next, throwsA(isA<RespProtocolException>()));
        });
      }

      test('lines exceeding the maximum length', () {
        final parser = RespParser()
          ..add(Uint8List(RespParser.maxLineLength + 2)..[0] = 43);
        expect(parser.next, throwsA(isA<RespProtocolException>()));
      });
    });
  });

  group('RedisReply conversions', () {
    test('asString', () {
      expect(const RedisSimpleString('OK').asString, equals('OK'));
      expect(RedisBulkString.fromString('x').asString, equals('x'));
      expect(const RedisInteger(3).asString, equals('3'));
      expect(const RedisNull().asString, isNull);
      expect(
        () => const RedisArray([]).asString,
        throwsA(isA<RedisException>()),
      );
      expect(
        () => const RedisErrorReply('WRONGTYPE bad').asString,
        throwsA(
          isA<RedisServerException>().having(
            (e) => e.code,
            'code',
            'WRONGTYPE',
          ),
        ),
      );
    });

    test('asInt and asDouble parse string replies', () {
      expect(RedisBulkString.fromString('17').asInt, equals(17));
      expect(RedisBulkString.fromString('1.5').asDouble, equals(1.5));
      expect(RedisBulkString.fromString('inf').asDouble, double.infinity);
      expect(
        RedisBulkString.fromString('-inf').asDouble,
        double.negativeInfinity,
      );
      expect(const RedisInteger(2).asDouble, equals(2.0));
      expect(
        () => RedisBulkString.fromString('abc').asInt,
        throwsA(isA<RedisException>()),
      );
    });
  });
}
