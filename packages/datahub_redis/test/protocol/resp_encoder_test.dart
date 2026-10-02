import 'dart:convert';
import 'dart:typed_data';

import 'package:datahub_redis/src/protocol/resp_encoder.dart';
import 'package:test/test.dart';

String _encode(List<Object> command) =>
    latin1.decode(RespEncoder.encode(command));

void main() {
  group('RespEncoder', () {
    test('encodes commands as arrays of bulk strings', () {
      expect(
        _encode(['SET', 'key', 'value']),
        equals('*3\r\n\$3\r\nSET\r\n\$3\r\nkey\r\n\$5\r\nvalue\r\n'),
      );
    });

    test('encodes strings as UTF-8 with byte lengths', () {
      final encoded = RespEncoder.encode(['ECHO', 'grüße']);
      expect(
        encoded,
        equals([
          ...ascii.encode('*2\r\n\$4\r\nECHO\r\n\$7\r\n'),
          ...utf8.encode('grüße'),
          ...ascii.encode('\r\n'),
        ]),
      );
    });

    test('encodes numbers as bulk strings', () {
      expect(
        _encode(['X', 42, -1, 1.5, double.infinity, double.negativeInfinity]),
        equals(
          '*6\r\n\$1\r\nX\r\n\$2\r\n42\r\n\$2\r\n-1\r\n\$3\r\n1.5\r\n'
          '\$4\r\n+inf\r\n\$4\r\n-inf\r\n',
        ),
      );
    });

    test('encodes bytes unchanged', () {
      final bytes = Uint8List.fromList([0, 13, 10, 255]);
      expect(
        RespEncoder.encode(['SET', 'k', bytes]),
        equals([
          ...ascii.encode('*3\r\n\$3\r\nSET\r\n\$1\r\nk\r\n\$4\r\n'),
          ...bytes,
          ...ascii.encode('\r\n'),
        ]),
      );
    });

    test('encodes empty arguments', () {
      expect(_encode(['SET', 'k', '']), endsWith('\$0\r\n\r\n'));
    });

    test('rejects unsupported arguments', () {
      expect(() => RespEncoder.encode([]), throwsArgumentError);
      expect(() => RespEncoder.encode(['SET', 'k', true]), throwsArgumentError);
      expect(
        () => RespEncoder.encode([
          'DEL',
          ['a', 'b'],
        ]),
        throwsArgumentError,
      );
      expect(
        () => RespEncoder.encode(['SET', 'k', double.nan]),
        throwsArgumentError,
      );
    });
  });
}
