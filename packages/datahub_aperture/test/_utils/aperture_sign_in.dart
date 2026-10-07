import 'dart:convert';
import 'dart:io' as io;

import 'package:datahub/datahub.dart';
import 'package:test/test.dart';

/// Signs in at the demo provider and returns a client of the Aperture API.
Future<RestClient> signInToAperture({
  required String issuer,
  required int apiPort,
}) async {
  const redirectUri = 'http://localhost/callback';
  final http = io.HttpClient();
  try {
    final authorize = await http.getUrl(
      Uri.parse('$issuer/protocol/openid-connect/auth').replace(
        queryParameters: {
          'response_type': 'code',
          'client_id': 'aperture',
          'redirect_uri': redirectUri,
          'scope': 'openid',
        },
      ),
    );
    authorize.followRedirects = false;
    final redirect = await authorize.close();
    await redirect.drain<void>();
    final code = Uri.parse(
      redirect.headers.value(io.HttpHeaders.locationHeader)!,
    ).queryParameters['code']!;

    final token = await http.postUrl(
      Uri.parse('$issuer/protocol/openid-connect/token'),
    );
    token.headers.contentType = io.ContentType(
      'application',
      'x-www-form-urlencoded',
    );
    token.write(
      Uri(
        queryParameters: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'client_id': 'aperture',
        },
      ).query,
    );
    final response = await token.close();
    final body = jsonDecode(await utf8.decodeStream(response));

    final client = await RestClient.connect(
      Uri.parse('http://localhost:$apiPort/aperture'),
    );
    client.auth = TokenAuth(body['access_token'] as String);
    addTearDown(client.close);
    return client;
  } finally {
    http.close();
  }
}
