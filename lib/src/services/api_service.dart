import 'package:boost/boost.dart';

import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/ioc.dart';

/// A wrapper for [ApiBase] APIs that runs [ApiBase.serve] as a [ServiceHost]
/// service.
class ApiService extends BaseService {
  final ApiBase api;
  final dynamic address;
  final int port;
  late Future _serveTask;
  final token = CancellationToken();

  ApiService(this.api, this.address, this.port);

  @override
  Future<void> initialize() async {
    _serveTask = api.serve(address, port, cancellationToken: token);
  }

  @override
  Future<void> shutdown() async {
    token.cancel();
    await _serveTask;
  }
}
