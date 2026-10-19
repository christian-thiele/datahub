import 'package:datahub/datahub.dart';

import 'resource_revision_info.dart';

part 'resource_data.g.dart';

@Data()
class const ResourceData({
  required final String id,
  required final Map<String, dynamic> fieldData,
  final int? version,
  final List<ResourceRevisionInfo> revisions = const [],
}) extends $ResourceData;
