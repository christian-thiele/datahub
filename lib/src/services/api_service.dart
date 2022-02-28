import 'package:boost/boost.dart';

import 'package:cl_datahub/api.dart';
import 'package:cl_datahub/config.dart';
import 'package:cl_datahub/ioc.dart';
import 'package:cl_datahub/services.dart';

/// A wrapper for [ApiBase] APIs that runs [ApiBase.serve] as a [ServiceHost]
/// service.
///
/// Requires a resolvable [ConfigService<ApiConfig>].
class ApiService extends BaseService {
  final _logService = resolve<LogService>();
  final _configService = ServiceHost.tryResolve<ConfigService<ApiConfig>>();

  final ApiBase api;

  late Future _serveTask;
  final token = CancellationToken();

  ApiService(this.api);

  @override
  Future<void> initialize() async {
    if (_configService == null) {
      _logService.c('No ConfigService<ApiConfig> could be resolved. '
          'ApiService cannot start api without configuration. '
          'Try to register a ConfigService that implements '
          'ConfigService<ApiConfig> on the applications ServiceHost.');
      throw Exception('Could not resolve ConfigService<ApiConfig>.');
    }

    final apiConfig = _configService!.config;
    _serveTask =
        api.serve(apiConfig.address, apiConfig.port, cancellationToken: token);
  }

  @override
  Future<void> shutdown() async {
    token.cancel();
    await _serveTask;
  }
}
