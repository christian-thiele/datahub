import 'dart:convert';
import 'package:datahub/src/test/test_host.dart';
import 'package:http/http.dart' as http;

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

class EchoLengthEndpoint extends ApiEndpoint {
  EchoLengthEndpoint({super.matcher});

  @override
  Future<ApiResponse> onRequest(ApiRequest request) async {
    final length = (await request.getByteBody()).length;
    return JsonResponse({'length': length});
  }
}

void main() {
  declareTest(
    'Test GET Payload fix',
    [
      ApiService(port: Config.value(8080), routes: [EchoLengthEndpoint()]),
    ],
    () async {
      final uri = Uri.parse('http://localhost:8080/');

      final restClient = RestClient.connectHttp11(uri);
      final response = await restClient
          .get(
            '/',
            headers: {
              HttpHeaders.accept: [Mime.json],
              HttpHeaders.contentType: [Mime.json],
            },
          )
          .thenGetJsonBody();

      expect(response['length'], equals(0));

      final request = http.Request('GET', uri);
      request.headers.addAll({'accept': Mime.json});

      final response2 = await request.send().timeout(Duration(seconds: 20));
      if (response2.statusCode != 200) {
        throw Exception(response2.reasonPhrase);
      }

      final responseData = await response2.stream.bytesToString().then(
        jsonDecode,
      );

      expect(responseData['length'], equals(0));
    },
  );
}
