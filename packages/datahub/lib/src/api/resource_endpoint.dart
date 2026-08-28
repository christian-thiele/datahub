import 'package:datahub/http.dart';

import '../utils/api_request_exception.dart';
import 'api_request.dart';
import 'api_route.dart';
import 'openapi/api_operation.dart';

class ResourceEndpoint extends ApiEndpoint {
  final RequestHandler? get;
  final RequestHandler? post;
  final RequestHandler? patch;
  final RequestHandler? put;
  final RequestHandler? delete;
  final RequestHandler? options;
  final RequestHandler? head;

  /// Optional OpenAPI metadata by HTTP method.
  final Map<HttpRequestMethod, ApiOperation> operations;

  const ResourceEndpoint({
    super.matcher,
    this.get,
    this.post,
    this.patch,
    this.put,
    this.delete,
    this.options,
    this.head,
    this.operations = const {},
  });

  @override
  Map<HttpRequestMethod, ApiOperation> describeApi() {
    final handlers = {
      HttpRequestMethod.get: get,
      HttpRequestMethod.post: post,
      HttpRequestMethod.put: put,
      HttpRequestMethod.patch: patch,
      HttpRequestMethod.delete: delete,
      HttpRequestMethod.options: options,
      HttpRequestMethod.head: head,
    };
    return {
      for (final entry in handlers.entries)
        if (entry.value != null)
          entry.key: operations[entry.key] ?? const ApiOperation(),
    };
  }

  @override
  Future<dynamic> onRequest(ApiRequest request) async {
    final handler = switch (request.method) {
      HttpRequestMethod.get when get != null => get!,
      HttpRequestMethod.post when post != null => post!,
      HttpRequestMethod.put when put != null => put!,
      HttpRequestMethod.patch when patch != null => patch!,
      HttpRequestMethod.delete when delete != null => delete!,
      HttpRequestMethod.options when options != null => options!,
      HttpRequestMethod.head when head != null => head!,
      _ => throw ApiRequestException.methodNotAllowed(),
    };

    return await handler(request);
  }
}
