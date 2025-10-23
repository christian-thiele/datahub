import 'package:datahub/datahub.dart';

import 'external_documentation_object.dart';
import 'response_object.dart';

part 'operation_object.g.dart';

@Data()
class OperationObject extends $OperationObject {
  final List<String> tags;
  final String? summary;
  final String? description;
  final ExternalDocumentationObject? externalDocs;
  final String? operationId;
  final List<String> consumes;
  final List<String> produces;

  // TODO implement "parameters"
  //final List<ParameterObject | ReferenceObject> parameters;
  // TODO ResponseObject || ReferenceObject
  final Map<String, ResponseObject> responses;
  final List<String> schemes;
  final bool deprecated;
  final List<dynamic> security;

  const OperationObject({
    this.tags = const [],
    this.summary,
    this.description,
    this.externalDocs,
    this.operationId,
    this.consumes = const [],
    this.produces = const [],
    required this.responses,
    this.schemes = const [],
    this.deprecated = false,
    this.security = const [],
  });
}
