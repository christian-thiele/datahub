import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';

import 'bootstrap_repository.dart';

class ApiBootstrapRepository implements BootstrapRepository {
  final Uri? selfUri;

  ApiBootstrapRepository({this.selfUri});

  @override
  Future<ApertureBootstrap> fetch() async {
    final client = await RestClient.connect(
      selfUri ?? Uri(scheme: 'http', host: 'localhost', port: 8080),
      timeout: const Duration(seconds: 10),
    );

    try {
      return await client
          .get('/api/bootstrap')
          .thenGetData(ApertureBootstrap.bean);
    } finally {
      client.close();
    }
  }

  @override
  Future<void> close() async {}

  @override
  Future<void> initialize() async {}
}
