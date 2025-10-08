import 'package:datahub/datahub.dart';

part 'resource_revision_request.g.dart';

@Data()
class ResourceRevisionRequest extends $ResourceRevisionRequest {
  final Map<String, dynamic> fieldData;
  final DateTime? revisionLive;

  const ResourceRevisionRequest({required this.fieldData, this.revisionLive});
}
