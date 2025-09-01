import 'package:datahub/datahub.dart';

import 'resource_revision_type.dart';

part 'resource_revision_info.g.dart';

@Data()
class ResourceRevisionInfo extends _ResourceRevisionInfo {
  final String id;
  final ResourceRevisionType type;
  final DateTime timestamp;
  final DateTime? live;
  final String userId;
  final String userName;

  const ResourceRevisionInfo({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.live,
    required this.userId,
    required this.userName,
  });

  static DataBean<ResourceRevisionInfo> get bean => _ResourceRevisionInfo.bean;
}
