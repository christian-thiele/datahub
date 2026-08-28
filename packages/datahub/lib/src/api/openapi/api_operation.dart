import 'package:boost/boost.dart';

import 'package:datahub/data.dart';

/// Describes a single operation (HTTP method on a route) of an [ApiEndpoint]
/// for OpenAPI documentation purposes.
///
/// All properties are optional. Attaching an [ApiOperation] to an endpoint
/// enriches the generated OpenAPI document with request/response schemas,
/// query parameters and descriptive metadata which cannot be derived from
/// the route structure itself.
class ApiOperation {
  final String? operationId;
  final String? summary;
  final String? description;
  final List<String> tags;
  final bool deprecated;

  /// Excludes this operation from the generated OpenAPI document.
  final bool hidden;

  final List<ApiQueryParam> queryParams;
  final ApiContent? requestBody;

  /// Response content by status code.
  final Map<int, ApiContent> responses;

  const ApiOperation({
    this.operationId,
    this.summary,
    this.description,
    this.tags = const [],
    this.deprecated = false,
    this.hidden = false,
    this.queryParams = const [],
    this.requestBody,
    this.responses = const {200: ApiContent.json()},
  });
}

/// Describes a query parameter of an [ApiOperation].
///
/// A nullable [type] (e.g. `TypeCheck<int?>()`) declares the parameter as
/// optional, mirroring the semantics of `ApiRequest.getParam<T>`.
class ApiQueryParam {
  final String name;
  final TypeCheck type;
  final String? description;

  const ApiQueryParam(
    this.name, {
    this.type = const TypeCheck<String?>(),
    this.description,
  });

  bool get isRequired => !type.isNullable;
}

/// Describes the content of a request or response body.
sealed class ApiContent {
  final String? description;

  const ApiContent({this.description});

  /// JSON content described by a [DataBean] schema.
  const factory ApiContent.bean(
    DataBean bean, {
    bool isList,
    String? description,
  }) = BeanApiContent;

  /// JSON content with an optional custom OpenAPI [schema].
  const factory ApiContent.json({
    Map<String, dynamic>? schema,
    String? description,
  }) = JsonApiContent;

  /// Plain text content.
  const factory ApiContent.text({String? description}) = TextApiContent;

  /// Binary content (`application/octet-stream`).
  const factory ApiContent.binary({String? description}) = BinaryApiContent;

  /// No content (e.g. for 204 responses).
  const factory ApiContent.empty({String? description}) = EmptyApiContent;
}

final class BeanApiContent extends ApiContent {
  final DataBean bean;
  final bool isList;

  const BeanApiContent(this.bean, {this.isList = false, super.description});
}

final class JsonApiContent extends ApiContent {
  final Map<String, dynamic>? schema;

  const JsonApiContent({this.schema, super.description});
}

final class TextApiContent extends ApiContent {
  const TextApiContent({super.description});
}

final class BinaryApiContent extends ApiContent {
  const BinaryApiContent({super.description});
}

final class EmptyApiContent extends ApiContent {
  const EmptyApiContent({super.description});
}

/// Allows custom [ApiMiddleware] implementations to describe themselves as
/// an OpenAPI security scheme.
///
/// The built-in authentication middlewares are recognized automatically.
abstract interface class OpenApiSecurityDescriptor {
  /// Key of the scheme in `components/securitySchemes`.
  String get securitySchemeName;

  /// The OpenAPI security scheme object.
  Map<String, dynamic> describeSecurityScheme();
}
