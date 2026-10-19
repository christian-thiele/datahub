import 'dart:convert';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class EchoLengthEndpoint({super.matcher}) extends ApiEndpoint {
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
      ApiService(port: const Config.value(0), routes: [EchoLengthEndpoint()]),
    ],
    () async {
      final restClient = const Find<Api>().find().connectHttp11();
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

      final request = http.Request(
        'GET',
        Uri(scheme: 'http', host: '127.0.0.1', port: restClient.port),
      );
      request.headers.addAll({'accept': Mime.json});

      final response2 = await request.send().timeout(
        const Duration(seconds: 20),
      );
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
