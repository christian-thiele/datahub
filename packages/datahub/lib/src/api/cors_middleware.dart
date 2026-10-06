import 'package:datahub/config.dart';
import 'package:datahub/http.dart';

import '../utils/api_request_exception.dart';
import 'api_request.dart';
import 'api_response.dart';
import 'api_route.dart';
import 'websocket_response.dart';

/// Middleware implementing Cross-Origin Resource Sharing (CORS).
///
/// Preflight requests (`OPTIONS` requests carrying an
/// `Access-Control-Request-Method` header) are answered by the middleware
/// itself and never reach children. All other requests are forwarded, and
/// the CORS headers are added to their responses if the request origin is
/// allowed.
class CorsMiddleware extends ApiMiddleware {
  /// Origins allowed to access [routes], e.g. `https://example.com`.
  ///
  /// `*` allows any origin.
  final Config<List<String>> allowedOrigins;

  /// Methods allowed for cross-origin requests.
  ///
  /// `*` allows any method.
  final Config<List<String>> allowedMethods;

  /// Request headers allowed for cross-origin requests.
  ///
  /// `*` allows any header.
  final Config<List<String>> allowedHeaders;

  /// Response headers exposed to scripts in addition to the
  /// CORS-safelisted response headers.
  final Config<List<String>> exposedHeaders;

  /// Whether cross-origin requests may include credentials, such as cookies
  /// or HTTP authentication.
  ///
  /// Browsers reject credentialed requests if any origin is allowed, so
  /// [allowedOrigins] must list the origins explicitly when this is enabled.
  final Config<bool> allowCredentials;

  /// How long browsers may cache preflight responses.
  ///
  /// Null leaves it to the browser default.
  final Config<Duration?> maxAge;

  const CorsMiddleware({
    super.matcher,
    this.allowedOrigins = const Config(
      'cors.allowedOrigins',
      defaultValue: ['*'],
    ),
    this.allowedMethods = const Config(
      'cors.allowedMethods',
      defaultValue: ['GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE'],
    ),
    this.allowedHeaders = const Config(
      'cors.allowedHeaders',
      defaultValue: ['*'],
    ),
    this.exposedHeaders = const Config('cors.exposedHeaders', defaultValue: []),
    this.allowCredentials = const Config(
      'cors.allowCredentials',
      defaultValue: false,
    ),
    this.maxAge = const Config('cors.maxAge'),
    required super.routes,
    super.catchRequests = false,
  });

  @override
  Future<dynamic> onRequest(
    ApiRequest request,
    RequestHandler<ApiResponse> next,
  ) async {
    final origins = allowedOrigins.read();
    final anyOrigin = origins.contains('*');
    final origin = request.headers[HttpHeaders.origin]?.firstOrNull;
    final allowed =
        origin != null && (anyOrigin || isOriginAllowed(origin, origins));

    final headers = {
      if (allowed) ...{
        HttpHeaders.accessControlAllowOrigin: [anyOrigin ? '*' : origin],
        if (allowCredentials.read())
          HttpHeaders.accessControlAllowCredentials: ['true'],
      },
    };

    if (origin != null &&
        request.method == HttpRequestMethod.options &&
        request.headers.containsKey(HttpHeaders.accessControlRequestMethod)) {
      if (!allowed) {
        throw ApiRequestException.forbidden('Origin not allowed.');
      }

      return EmptyResponse(
        statusCode: 204,
        headers: {
          ...headers,
          if (_allowed(
                allowedMethods.read(),
                request.headers[HttpHeaders.accessControlRequestMethod],
              )
              case final methods?)
            HttpHeaders.accessControlAllowMethods: [methods],
          if (_allowed(
                allowedHeaders.read(),
                request.headers[HttpHeaders.accessControlRequests],
              )
              case final allowHeaders?)
            HttpHeaders.accessControlAllows: [allowHeaders],
          if (maxAge.read() case final maxAge?)
            HttpHeaders.accessControlMaxAge: [maxAge.inSeconds.toString()],
        },
      );
    }

    if (allowed) {
      if (exposedHeaders.read() case final exposed when exposed.isNotEmpty) {
        headers[HttpHeaders.accessControlExposes] = [exposed.join(', ')];
      }
    }

    ApiResponse response;
    try {
      response = await next(request);
    } on ApiRequestException catch (e) {
      // browsers only expose error responses to scripts if they carry the
      // CORS headers, server errors are left to ApiService for logging
      if (e.statusCode >= 500) {
        rethrow;
      }
      response = e.toResponse();
    }

    // browsers do not apply CORS to websockets, and the upgrade response
    // must not be wrapped
    if (response is WebsocketResponse) {
      return response;
    }

    // responses differ by origin unless any origin is allowed
    return _CorsResponse(response, headers, varyOrigin: !anyOrigin);
  }

  /// Whether [origin] is allowed to access [routes].
  ///
  /// Only called if [allowedOrigins] does not contain `*`. Override for
  /// custom matching, such as subdomain wildcards.
  bool isOriginAllowed(String origin, List<String> allowedOrigins) =>
      allowedOrigins.contains(origin);

  /// Reflects the [requested] values if [allowed] contains `*`, since the
  /// literal wildcard is not supported for credentialed requests.
  static String? _allowed(List<String> allowed, List<String>? requested) {
    final values = allowed.contains('*') ? requested ?? [] : allowed;
    return values.isNotEmpty ? values.join(', ') : null;
  }
}

class _CorsResponse extends ApiResponse {
  final ApiResponse _inner;
  final Map<String, List<String>> _headers;
  final bool varyOrigin;

  _CorsResponse(this._inner, this._headers, {required this.varyOrigin})
    : super(_inner.statusCode);

  @override
  Stream<List<int>> getData() => _inner.getData();

  @override
  Map<String, List<String>> getHeaders() {
    final headers = {..._inner.getHeaders(), ..._headers};
    if (varyOrigin) {
      final key = headers.keys.firstWhere(
        (k) => k.toLowerCase() == HttpHeaders.vary,
        orElse: () => HttpHeaders.vary,
      );
      headers[key] = [...?headers[key], 'Origin'];
    }
    return headers;
  }
}
