import 'package:datahub/http.dart';

import '../../utils/api_request_exception.dart';
import '../api_request.dart';
import '../api_route.dart';
import '../route_pattern.dart';
import 'api_operation.dart';
import 'openapi_builder.dart';

/// Serves an OpenAPI 3.0.3 document describing the given [ApiNode]s.
///
/// Add this endpoint to an ApiService alongside the routes it describes:
///
/// ```dart
/// final routes = <ApiNode>[ /* ... */ ];
/// ApiService(routes: [...routes, OpenApiEndpoint(describes: routes)]);
/// ```
class OpenApiEndpoint extends ApiEndpoint {
  final List<ApiNode> describes;
  final String title;
  final String version;
  final String? description;
  final List<String> serverUrls;

  Map<String, dynamic>? _document;

  OpenApiEndpoint({
    RoutePattern? matcher,
    required this.describes,
    this.title = 'API',
    this.version = '1.0.0',
    this.description,
    this.serverUrls = const [],
  }) : super(matcher: matcher ?? RoutePattern('/openapi.json'));

  @override
  Map<HttpRequestMethod, ApiOperation> describeApi() => const {
    HttpRequestMethod.get: ApiOperation(hidden: true),
  };

  @override
  Future<dynamic> onRequest(ApiRequest request) async {
    if (request.method != HttpRequestMethod.get) {
      throw ApiRequestException.methodNotAllowed();
    }

    return _document ??= OpenApiBuilder(
      title: title,
      version: version,
      description: description,
      serverUrls: serverUrls,
    ).build(describes);
  }
}
