import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/src/api/api_request.dart';
import 'package:cl_datahub/src/api/api_response.dart';
import 'package:cl_datahub/src/api/middleware/middleware.dart';
import 'package:cl_datahub/src/api/middleware/request_handler.dart';

class LogMiddleware extends Middleware {
  final bool verbose;
  final _logService = resolve<LogService>();

  /// Logs requests, handling times and status codes to the [LogService].
  ///
  /// [verbose] log as verbose instead of info
  LogMiddleware(RequestHandler internal, [this.verbose = false])
      : super(internal);

  @override
  Future<ApiResponse> handleRequest(ApiRequest request) async {
    // Pre-Handler
    final stopwatch = Stopwatch()..start();
    final log = verbose ? _logService.v : _logService.i;
    log('${request.method}: ${request.route}', sender: 'DataHub');

    final result = await next(request);

    // Post-Handler
    stopwatch.stop();

    if (result.statusCode >= 500) {
      _logService.error(
          '${result.statusCode}: ${request.route} (${stopwatch.elapsedMilliseconds} ms)',
          sender: 'DataHub');
    } else {
      log('${result.statusCode}: ${request.route} (${stopwatch.elapsedMilliseconds} ms)',
          sender: 'DataHub');
    }
    return result;
  }
}
