import 'package:datahub/test.dart';
import 'package:test/test.dart';

import 'lib/echo_api.dart';

void main() {
  final host = TestHost([EchoApi.new]);

  test('GET /echo', host.apiTest((client) async {
    final response = await client.getObject('/echo');
    expect(response, isSuccess);
    expect(response, isNot(hasBody()));
  }), timeout: Timeout.none);

  test('POST /echo', host.apiTest((client) async {
    final response = await client
        .postObject<Map<String, dynamic>>('/echo', {'success': true});
    expect(response, isSuccess);
    expect(response, hasBody(equals({'success': true})));
  }), timeout: Timeout.none);

  test('PATCH /echo', host.apiTest((client) async {
    final response = await client.patchObject('/echo', {'success': false});
    expect(response, isNot(isSuccess));
  }), timeout: Timeout.none);

  test('PUT /echo', host.apiTest((client) async {
    final response = await client.putObject('/echo', {'whatever': 123});
    expect(response, isNot(isSuccess));
  }), timeout: Timeout.none);

  test('DELETE /echo', host.apiTest((client) async {
    final response = await client.delete('/echo');
    expect(response, isSuccess);
  }), timeout: Timeout.none);
}
