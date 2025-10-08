import 'package:datahub/datahub.dart';

import 'resource_revision_info.dart';

part 'resource_data.g.dart';

@Data()
class ResourceData extends $ResourceData {
  final String id;
  final Map<String, dynamic> fieldData;
  final String? revisionId;
  final List<ResourceRevisionInfo> revisions;

  const ResourceData({
    required this.id,
    required this.fieldData,
    this.revisionId,
    this.revisions = const [],
  });
}
