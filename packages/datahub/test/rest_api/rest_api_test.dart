import 'dart:typed_data';

import 'package:datahub/api.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

import 'lib/echo_api.dart';
import 'lib/simple_dto.dart';

void main() {
  TestHost([
    EchoApi.new
  ], config: {
    'echoApi': {'port': 8081}
  }).declare(
    (host) {
      host.apiTest('PUT /echo', (client) async {
        expect(client.put('/echo', {'whatever': 123}),
            throwsA(isA<ApiRequestException>()));
      });

      host.apiTest('GET /echo', (client) async {
        final response = await client.get('/echo');
        expect(response, isSuccess);
        final responseBody = await response.getBody<Uint8List>();
        expect(responseBody, isEmpty);
      });

      host.apiTest('POST /echo', (client) async {
        final response = await client.post('/echo', {'success': true});
        expect(response, isSuccess);
        final responseBody = await response.getBody();
        expect(responseBody, equals({'success': true}));

        final response2 = await client.post('/echo', [
          {'success': true}
        ]);
        expect(response2, isSuccess);
        final response2Body = await response2.getBody();
        expect(
          response2Body,
          equals([
            {'success': true}
          ]),
        );
      });

      host.apiTest('PATCH /echo', (client) async {
        final response = await client.patch('/echo', {'success': false},
            throwOnError: false);
        expect(response, isNot(isSuccess));
      });

      host.apiTest('DELETE /echo', (client) async {
        final response = await client.delete('/echo');
        expect(response, isSuccess);
      });

      host.apiTest('OPTIONS /echo', (client) async {
        final response = await client.request(
          ApiRequestMethod.OPTIONS,
          RoutePattern('/echo'),
          {},
          throwOnError: false,
        );
        expect(response, isNot(isSuccess));
        expect(response, hasStatusCode(equals(405)));
      });

      host.apiTest('POST /list', (client) async {
        final response = await client.post(
          '/list',
          [
            SimpleDto(text: 'test1', number: 1),
            SimpleDto(text: 'test2', number: 2),
          ],
        );
        final data = await response.getList<SimpleDto>(SimpleDto.bean);
        expect(data, isA<List<SimpleDto>>());
        expect(data, hasLength(2));
        expect(data[0],
            isA<SimpleDto>().having((e) => e.text, 'text', equals('test1')));
        expect(data[1],
            isA<SimpleDto>().having((e) => e.text, 'text', equals('test2')));
      });
    },
    useCommonHost: true,
  );
}
