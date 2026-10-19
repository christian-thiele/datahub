import 'package:datahub/datahub.dart';

import 'resource_revision_type.dart';

part 'resource_revision_info.g.dart';

@Data()
class const ResourceRevisionInfo({
  required final int version,
  required final ResourceRevisionType type,
  required final DateTime timestamp,
  required final DateTime? live,
  required final String userId,
  required final String userName,
}) extends $ResourceRevisionInfo;
