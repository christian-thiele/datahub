import 'package:datahub/datahub.dart';

import 'resource_revision_type.dart';

part 'resource_revision_info.g.dart';

@Data()
class ResourceRevisionInfo extends $ResourceRevisionInfo {
  final int version;
  final ResourceRevisionType type;
  final DateTime timestamp;
  final DateTime? live;
  final String userId;
  final String userName;

  const ResourceRevisionInfo({
    required this.version,
    required this.type,
    required this.timestamp,
    required this.live,
    required this.userId,
    required this.userName,
  });
}
