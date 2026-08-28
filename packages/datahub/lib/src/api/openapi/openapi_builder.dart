import 'package:datahub/auth.dart';
import 'package:datahub/http.dart';

import '../api_route.dart';
import '../route_matcher.dart';
import '../route_pattern.dart';
import 'api_operation.dart';
import 'openapi_schema.dart';

final _pathParamExp = RegExp(r'\{([\w-]+)\}');

/// Builds an OpenAPI 3.0.3 document from a list of [ApiNode]s.
///
/// Route construction ([ApiNode.buildRoutes]) may read configuration values,
/// so [build] must be called inside an active service context (e.g. within
/// a request handler or the describe mode of an application host).
class OpenApiBuilder {
  final String title;
  final String version;
  final String? description;
  final List<String> serverUrls;

  /// Non-fatal problems encountered during the last [build] call.
  final List<String> warnings = [];

  OpenApiBuilder({
    required this.title,
    required this.version,
    this.description,
    this.serverUrls = const [],
  });

  Map<String, dynamic> build(List<ApiNode> nodes) {
    warnings.clear();
    final registry = OpenApiSchemaRegistry();
    final securitySchemes = <String, Map<String, dynamic>>{};
    final paths = <String, Map<String, dynamic>>{};

    _walk(nodes, const [], registry, securitySchemes, paths);

    return {
      'openapi': '3.0.3',
      'info': {
        'title': title,
        if (description case final description?) 'description': description,
        'version': version,
      },
      if (serverUrls.isNotEmpty)
        'servers': [
          for (final url in serverUrls) {'url': url},
        ],
      'paths': paths,
      'components': {
        'schemas': {...registry.schemas, 'ErrorResponse': _errorResponseSchema},
        if (securitySchemes.isNotEmpty) 'securitySchemes': securitySchemes,
      },
    };
  }

  void _walk(
    List<ApiNode> nodes,
    List<String> security,
    OpenApiSchemaRegistry registry,
    Map<String, Map<String, dynamic>> securitySchemes,
    Map<String, Map<String, dynamic>> paths,
  ) {
    for (final node in nodes) {
      for (final route in node.buildRoutes()) {
        switch (route) {
          case ApiMiddleware():
            final scheme = _securityScheme(route);
            if (scheme != null) {
              securitySchemes[scheme.$1] = scheme.$2;
            }
            _walk(
              route.routes,
              [...security, if (scheme != null) scheme.$1],
              registry,
              securitySchemes,
              paths,
            );
          case ApiEndpoint():
            _addEndpoint(route, security, registry, paths);
        }
      }
    }
  }

  void _addEndpoint(
    ApiEndpoint endpoint,
    List<String> security,
    OpenApiSchemaRegistry registry,
    Map<String, Map<String, dynamic>> paths,
  ) {
    final patterns = _collect<RoutePattern>(endpoint.matcher).toList();
    if (patterns.isEmpty) {
      warnings.add(
        'Endpoint ${endpoint.runtimeType} has no RoutePattern matcher '
        'and cannot be documented.',
      );
      return;
    }

    final operations = {
      for (final entry
          in (endpoint.describeApi() ?? _fallbackOperations(endpoint)).entries)
        if (!entry.value.hidden) entry.key: entry.value,
    };
    if (operations.isEmpty) {
      return;
    }

    final headerMatchers = _collect<HeaderRouteMatcher>(endpoint.matcher);

    for (final pattern in patterns) {
      for (final path in pattern.openApiPaths) {
        final item = paths.putIfAbsent(path, () => {});
        for (final entry in operations.entries) {
          item[entry.key.name] = _operationObject(
            path,
            pattern,
            entry.value,
            security,
            headerMatchers,
            registry,
          );
        }
      }
    }
  }

  Map<HttpRequestMethod, ApiOperation> _fallbackOperations(
    ApiEndpoint endpoint,
  ) {
    final operation = switch (endpoint) {
      ApiEndpointDelegate(:final operation?) => operation,
      _ => const ApiOperation(),
    };
    final methods = _collect<MethodRouteMatcher>(
      endpoint.matcher,
    ).map((matcher) => matcher.method).toSet();
    if (methods.isEmpty) {
      warnings.add(
        'Endpoint ${endpoint.runtimeType} does not declare its HTTP methods; '
        'assuming GET. Provide ApiOperation metadata to document it.',
      );
      return {HttpRequestMethod.get: operation};
    }
    return {for (final method in methods) method: operation};
  }

  Map<String, dynamic> _operationObject(
    String path,
    RoutePattern pattern,
    ApiOperation operation,
    List<String> security,
    Iterable<HeaderRouteMatcher> headerMatchers,
    OpenApiSchemaRegistry registry,
  ) {
    final parameters = [
      for (final match in _pathParamExp.allMatches(path))
        {
          'name': match.group(1),
          'in': 'path',
          'required': true,
          'schema': {'type': 'string'},
        },
      for (final param in operation.queryParams)
        {
          'name': param.name,
          'in': 'query',
          if (param.isRequired) 'required': true,
          if (param.description case final description?)
            'description': description,
          'schema': registry.schemaForType(param.type),
        },
      for (final matcher in headerMatchers)
        {
          'name': matcher.header,
          'in': 'header',
          'required': true,
          if (matcher.value case final value?)
            'description': 'Must contain "$value".',
          'schema': {'type': 'string'},
        },
    ];

    final descriptionParts = [
      if (operation.description case final description?) description,
      if (pattern.isWildcardPattern) 'This endpoint matches all sub-paths.',
    ];

    final requestContent = operation.requestBody != null
        ? _contentObject(operation.requestBody!, registry)
        : null;

    return {
      if (operation.operationId case final operationId?)
        'operationId': operationId,
      if (operation.summary case final summary?) 'summary': summary,
      if (descriptionParts.isNotEmpty)
        'description': descriptionParts.join('\n\n'),
      if (operation.tags.isNotEmpty) 'tags': operation.tags,
      if (operation.deprecated) 'deprecated': true,
      if (parameters.isNotEmpty) 'parameters': parameters,
      if (requestContent != null)
        'requestBody': {
          if (operation.requestBody?.description case final description?)
            'description': description,
          'required': true,
          'content': requestContent,
        },
      'responses': _responsesObject(operation, security, registry),
      if (security.isNotEmpty)
        'security': [
          {for (final scheme in security) scheme: <String>[]},
        ],
    };
  }

  Map<String, dynamic> _responsesObject(
    ApiOperation operation,
    List<String> security,
    OpenApiSchemaRegistry registry,
  ) {
    const errorResponse = {
      'description': 'Error',
      'content': {
        'application/json': {
          'schema': {'\$ref': '#/components/schemas/ErrorResponse'},
        },
      },
    };

    final responses = <String, dynamic>{
      for (final entry in operation.responses.entries)
        '${entry.key}': {
          'description': entry.value.description ?? _reasonPhrase(entry.key),
          if (_contentObject(entry.value, registry) case final content?)
            'content': content,
        },
    };

    for (final statusCode in [
      '400',
      '404',
      '500',
      if (security.isNotEmpty) ...['401', '403'],
    ]) {
      responses.putIfAbsent(statusCode, () => errorResponse);
    }

    return responses;
  }

  Map<String, dynamic>? _contentObject(
    ApiContent content,
    OpenApiSchemaRegistry registry,
  ) {
    return switch (content) {
      BeanApiContent(:final bean, :final isList) => {
        'application/json': {
          'schema': isList
              ? {'type': 'array', 'items': registry.referenceBean(bean)}
              : registry.referenceBean(bean),
        },
      },
      JsonApiContent(:final schema) => {
        'application/json': {if (schema != null) 'schema': schema},
      },
      TextApiContent() => {
        'text/plain': {
          'schema': {'type': 'string'},
        },
      },
      BinaryApiContent() => {
        'application/octet-stream': {
          'schema': {'type': 'string', 'format': 'binary'},
        },
      },
      EmptyApiContent() => null,
    };
  }

  (String, Map<String, dynamic>)? _securityScheme(ApiMiddleware middleware) {
    switch (middleware) {
      case final OpenApiSecurityDescriptor descriptor:
        return (
          descriptor.securitySchemeName,
          descriptor.describeSecurityScheme(),
        );
      case JwtAuthMiddleware():
        return (
          'bearerAuth',
          {'type': 'http', 'scheme': 'bearer', 'bearerFormat': 'JWT'},
        );
      case OidcAuthMiddleware():
        String? identityProvider;
        try {
          identityProvider = middleware.identityProvider.read();
        } catch (_) {
          warnings.add(
            'Could not read identity provider config of OidcAuthMiddleware.',
          );
        }
        return (
          'oidcAuth',
          {
            'type': 'openIdConnect',
            'openIdConnectUrl': identityProvider != null
                ? '$identityProvider/.well-known/openid-configuration'
                : '',
          },
        );
      case BasicAuthMiddleware():
        return ('basicAuth', {'type': 'http', 'scheme': 'basic'});
      case TokenAuthMiddleware():
        return (
          'tokenAuth',
          {'type': 'apiKey', 'in': 'header', 'name': 'Authorization'},
        );
      case AuthenticationMiddleware():
        warnings.add(
          '${middleware.runtimeType} is not a known authentication '
          'middleware; documented as API key authorization. Implement '
          'OpenApiSecurityDescriptor to describe it.',
        );
        return (
          'sessionAuth',
          {'type': 'apiKey', 'in': 'header', 'name': 'Authorization'},
        );
      default:
        return null;
    }
  }

  Iterable<T> _collect<T extends RouteMatcher>(RouteMatcher matcher) sync* {
    if (matcher is T) {
      yield matcher;
    }
    switch (matcher) {
      case AllOfRouteMatcher(:final matchers) ||
          AnyOfRouteMatcher(:final matchers):
        for (final child in matchers) {
          yield* _collect<T>(child);
        }
      default:
    }
  }

  static const _errorResponseSchema = {
    'type': 'object',
    'properties': {
      'statusCode': {'type': 'integer'},
      'errorMessage': {'type': 'string', 'nullable': true},
      'requestId': {'type': 'string', 'nullable': true},
    },
    'required': ['statusCode'],
  };

  static String _reasonPhrase(int statusCode) {
    return switch (statusCode) {
      200 => 'OK',
      201 => 'Created',
      202 => 'Accepted',
      204 => 'No Content',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      405 => 'Method Not Allowed',
      409 => 'Conflict',
      500 => 'Internal Server Error',
      _ => 'Status $statusCode',
    };
  }
}
