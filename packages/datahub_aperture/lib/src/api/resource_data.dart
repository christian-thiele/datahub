import 'package:datahub/datahub.dart';

import 'resource_revision_info.dart';

part 'resource_data.g.dart';

@Data()
class ResourceData extends $ResourceData {
  final String id;
  final Map<String, dynamic> fieldData;
  final int? version;
  final List<ResourceRevisionInfo> revisions;

  const ResourceData({
    required this.id,
    required this.fieldData,
    this.version,
    this.revisions = const [],
  });
}
