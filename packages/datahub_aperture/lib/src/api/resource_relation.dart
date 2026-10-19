import 'package:datahub/datahub.dart';

import 'resource_relation_filter.dart';

part 'resource_relation.g.dart';

@Data()
class const ResourceRelation({
  required final String name,
  required final String resourceId,
  required final ResourceRelationFilter filter,
}) extends $ResourceRelation;
