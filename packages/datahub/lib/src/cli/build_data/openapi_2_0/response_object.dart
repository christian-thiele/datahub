import 'package:datahub/datahub.dart';

import 'header_object.dart';

part 'response_object.g.dart';

@Data()
class ResponseObject extends $ResponseObject {
  final String description;
  final Map<String, dynamic> schema;
  final Map<String, HeaderObject> headers;
  final Map<String, dynamic> examples;

  const ResponseObject({
    required this.description,
    this.schema = const {},
    this.headers = const {},
    this.examples = const {},
  });
}
