import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

class EchoLengthEndpoint extends ApiEndpoint {
  EchoLengthEndpoint() : super(RoutePattern('/'));

  @override
  Future<ApiResponse> handleRequest(ApiRequest request) async {
    final length = (await request.getByteBody()).length;
    return JsonResponse({'length': length});
  }
}

void main() {
  TestHost(
    [
      () => ApiService('api', [EchoLengthEndpoint()])
    ],
    config: {
      'api': {'port': 8080},
    },
  ).declare((host) {
    host.test(
      'Test GET Payload fix',
      () async {
        final uri = Uri.parse('http://localhost:8080/');

        final restClient = RestClient.connectHttp11(uri);
        final response = await restClient.get(
          '/',
          headers: {
            HttpHeaders.accept: [Mime.json],
            HttpHeaders.contentType: [Mime.json],
          },
        ).thenGetJsonBody();

        expect(response['length'], equals(0));

        final request = http.Request('GET', uri);
        request.headers.addAll({
          'accept': 'application/json',
        });

        final response2 = await request.send().timeout(Duration(seconds: 20));
        if (response2.statusCode != 200) {
          throw Exception(response2.reasonPhrase);
        }

        final responseData =
            await response2.stream.bytesToString().then(jsonDecode);

        expect(responseData['length'], equals(0));
      },
    );
  });
}
