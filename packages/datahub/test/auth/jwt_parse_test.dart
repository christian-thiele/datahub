import 'dart:convert';
import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

void main() {
  String encode(String value) =>
      stripBase64Padding(base64UrlEncode(utf8.encode(value)));

  final header = encode('{"alg":"RS256","typ":"JWT","kid":"test"}');
  final payload = encode('{"iss":"https://example.com","sub":"user"}');
  final signature = stripBase64Padding(
    base64UrlEncode(Uint8List.fromList(List.generate(256, (i) => i))),
  );

  final isUnauthorized = isA<ApiRequestException>().having(
    (e) => e.statusCode,
    'statusCode',
    401,
  );

  group('Jwt parsing', () {
    test('parses a well-formed token', () {
      final jwt = Jwt('$header.$payload.$signature');
      expect(jwt.kid, 'test');
      expect(jwt.sub, 'user');
      expect(jwt.signature.length, 256);
    });

    test('rejects wrong part count', () {
      expect(() => Jwt('$header.$payload'), throwsA(isUnauthorized));
    });

    test('rejects malformed base64 in header', () {
      expect(
        () => Jwt('$header*.$payload.$signature'),
        throwsA(isUnauthorized),
      );
      expect(() => Jwt('a.$payload.$signature'), throwsA(isUnauthorized));
    });

    test('rejects malformed base64 in payload', () {
      expect(
        () => Jwt('$header.$payload*.$signature'),
        throwsA(isUnauthorized),
      );
      expect(() => Jwt('$header.a.$signature'), throwsA(isUnauthorized));
    });

    test('rejects malformed base64 in signature', () {
      expect(
        () => Jwt('$header.$payload.${signature}x'),
        throwsA(isUnauthorized),
      );
      expect(
        () => Jwt('$header.$payload.$signature*'),
        throwsA(isUnauthorized),
      );
      expect(() => Jwt('$header.$payload.a'), throwsA(isUnauthorized));
    });

    test('rejects invalid json in header and payload', () {
      final invalidJson = encode('{"alg":');
      expect(
        () => Jwt('$invalidJson.$payload.$signature'),
        throwsA(isUnauthorized),
      );
      expect(
        () => Jwt('$header.$invalidJson.$signature'),
        throwsA(isUnauthorized),
      );
    });

    test('rejects non-object header and payload', () {
      final array = encode('[1,2,3]');
      expect(() => Jwt('$array.$payload.$signature'), throwsA(isUnauthorized));
      expect(() => Jwt('$header.$array.$signature'), throwsA(isUnauthorized));
    });

    test('fromAuthorizationHeader rejects malformed bearer token', () {
      expect(
        () => Jwt.fromAuthorizationHeader(
          'Bearer $header.$payload.${signature}x',
        ),
        throwsA(isUnauthorized),
      );
    });
  });
}
