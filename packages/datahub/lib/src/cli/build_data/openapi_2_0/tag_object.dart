import 'package:datahub/datahub.dart';
import 'package:datahub/src/cli/build_data/openapi_2_0/external_documentation_object.dart';

part 'tag_object.g.dart';

@Data()
class TagObject extends $TagObject {
  final String name;
  final String? description;
  final ExternalDocumentationObject? externalDocs;

  const TagObject({required this.name, this.description, this.externalDocs});
}
