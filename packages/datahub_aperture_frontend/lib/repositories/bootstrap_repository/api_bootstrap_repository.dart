import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';
import 'package:flutter/foundation.dart';

import 'bootstrap_repository.dart';

class ApiBootstrapRepository implements BootstrapRepository {
  ApiBootstrapRepository();

  @override
  Future<(Uri, ApertureBootstrap)> fetch() async {
    final Uri baseUri;

    if (const String.fromEnvironment('API_URL') case final value
        when value.isNotEmpty) {
      baseUri = Uri.parse(value);
    } else if (kIsWeb) {
      final baseClient = await RestClient.connect(
        Uri.base,
        timeout: const Duration(seconds: 10),
      );

      try {
        final environment = await baseClient.get('/.env').thenGetJsonBody();
        if (environment['API_URL'] case final String value) {
          baseUri = Uri.parse(value).resolveUri(Uri.base);
        } else {
          baseUri = Uri.base;
        }
      } finally {
        await baseClient.close();
      }
    } else {
      baseUri = Uri(
        scheme: 'http',
        host: 'localhost',
        port: 8080,
        path: '/aperture',
      );
    }

    final client = await RestClient.connect(
      baseUri,
      timeout: const Duration(seconds: 10),
    );

    try {
      final bootstrap = await client
          .get('/api/bootstrap')
          .thenGetData($ApertureBootstrap.bean);
      return (baseUri, bootstrap);
    } finally {
      client.close();
    }
  }
}
