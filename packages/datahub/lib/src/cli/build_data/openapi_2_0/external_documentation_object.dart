import 'package:datahub/datahub.dart';

part 'external_documentation_object.g.dart';

@Data()
class ExternalDocumentationObject extends $ExternalDocumentationObject {
  final String? description;
  final String url;

  const ExternalDocumentationObject({this.description, required this.url});
}
