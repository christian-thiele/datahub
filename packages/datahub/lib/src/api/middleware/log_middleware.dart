import 'dart:async';

import 'package:datahub/api.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';

import 'request_handler.dart';

class LogMiddleware extends Middleware {
  final bool verbose;
  final String logSender;
  final _logService = resolve<LogService>();

  /// Logs requests, handling times and status codes to the [LogService].
  ///
  /// [verbose] log as verbose instead of info
  LogMiddleware(RequestHandler internal,
      {this.verbose = false, this.logSender = 'API'})
      : super(internal);

  @override
  Future<ApiResponse> handleRequest(ApiRequest request) async {
    // Pre-Handler
    final stopwatch = Stopwatch()..start();
    final log = verbose ? _logService.v : _logService.i;
    log('Request: ${request.method.name} ${request.route}', sender: logSender);

    final result = await next(request);

    // Post-Handler
    stopwatch.stop();

    if (result.statusCode >= 500) {
      _logService.error(
        'Response: ${result.statusCode} (${stopwatch.elapsedMilliseconds} ms)',
        sender: logSender,
      );
    } else {
      log(
        '${result.statusCode} (${stopwatch.elapsedMilliseconds} ms)',
        sender: logSender,
      );
    }

    return result;
  }
}
