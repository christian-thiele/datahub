import 'dart:convert';

import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

import '../rest_client/placeholder_user.dart';

void main() {
  group('getData', () {
    test('valid body', () async {
      final user = await _request('{"id": "1", "name": "John"}')
          .getData($PlaceholderUser.bean);
      expect(user.id, '1');
      expect(user.name, 'John');
    });

    test('malformed json', () async {
      await expectLater(
        _request('{"id": ').getData($PlaceholderUser.bean),
        _throwsBadRequest,
      );
    });

    test('json list instead of object', () async {
      await expectLater(
        _request('[]').getData($PlaceholderUser.bean),
        _throwsBadRequest,
      );
    });

    test('missing field', () async {
      await expectLater(
        _request('{"id": "1"}').getData($PlaceholderUser.bean),
        _throwsBadRequest,
      );
    });

    test('mismatching field type', () async {
      await expectLater(
        _request('{"id": "1", "name": {}}').getData($PlaceholderUser.bean),
        _throwsBadRequest,
      );
    });
  });

  group('getList', () {
    test('valid body', () async {
      final users = await _request('[{"id": "1", "name": "John"}]')
          .getList($PlaceholderUser.bean);
      expect(users.single.name, 'John');
    });

    test('single flat object', () async {
      final users = await _request('{"id": "1", "name": "John"}')
          .getList($PlaceholderUser.bean, allowSingleFlat: true);
      expect(users.single.name, 'John');
    });

    test('single flat object not allowed', () async {
      await expectLater(
        _request('{"id": "1", "name": "John"}').getList($PlaceholderUser.bean),
        _throwsBadRequest,
      );
    });

    test('malformed json', () async {
      await expectLater(
        _request('[{"id": ').getList($PlaceholderUser.bean),
        _throwsBadRequest,
      );
    });

    test('invalid utf8', () async {
      await expectLater(
        ApiRequest(
          Uri.parse('http://localhost/'),
          HttpRequestMethod.post,
          {},
          {},
          Stream.value([0xff, 0xfe]),
        ).getList($PlaceholderUser.bean),
        _throwsBadRequest,
      );
    });

    test('missing field in item', () async {
      await expectLater(
        _request('[{"id": "1"}]').getList($PlaceholderUser.bean),
        _throwsBadRequest,
      );
    });
  });
}

final _throwsBadRequest = throwsA(
  isA<ApiRequestException>().having((e) => e.statusCode, 'statusCode', 400),
);

ApiRequest _request(String body) => ApiRequest(
  Uri.parse('http://localhost/'),
  HttpRequestMethod.post,
  {},
  {},
  Stream.value(utf8.encode(body)),
);
