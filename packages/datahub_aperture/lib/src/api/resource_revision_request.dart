import 'package:datahub/datahub.dart';

part 'resource_revision_request.g.dart';

@Data()
class ResourceRevisionRequest extends _ResourceRevisionRequest {
  final Map<String, dynamic> fieldData;
  final DateTime? revisionLive;

  const ResourceRevisionRequest({required this.fieldData, this.revisionLive});

  static DataBean<ResourceRevisionRequest> get bean =>
      _ResourceRevisionRequest.bean;
}
