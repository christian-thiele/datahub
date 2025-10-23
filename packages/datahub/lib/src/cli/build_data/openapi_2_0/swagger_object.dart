import 'package:datahub/datahub.dart';

import 'external_documentation_object.dart';
import 'info_object.dart';
import 'path_item_object.dart';
import 'tag_object.dart';

part 'swagger_object.g.dart';

// TODO complete implementation from https://swagger.io/specification/v2/

@Data()
class SwaggerObject extends $SwaggerObject {
  final String swagger;
  final InfoObject info;
  final String? host;
  final String? basePath;
  final List<String> schemes;
  final List<String> consumes;
  final List<String> produces;

  // TODO PathItemObject || ReferenceObject
  final Map<String, PathItemObject> paths;

  // TODO implement SchemaObject
  final Map<String, dynamic> definitions;

  // TODO implement parameters
  // final ParametersDefinitionsObject? parameters;

  // TODO implement responses
  // final ResponsesDefinitionsObject? responses;

  // TODO implement securityDefinitions
  // final SecurityDefinitionsObject? securityDefinitions;
  final List<dynamic> security;
  final List<TagObject> tags;
  final List<ExternalDocumentationObject> externalDocs;

  const SwaggerObject({
    required this.swagger,
    required this.info,
    this.host,
    this.basePath,
    this.schemes = const [],
    this.consumes = const [],
    this.produces = const [],
    required this.paths,
    this.definitions = const {},
    this.security = const [],
    this.tags = const [],
    this.externalDocs = const [],
  });
}
