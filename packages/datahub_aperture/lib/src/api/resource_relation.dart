import 'package:datahub/datahub.dart';

import 'resource_relation_filter.dart';

part 'resource_relation.g.dart';

@Data()
class ResourceRelation extends $ResourceRelation {
  final String name;
  final String resourceId;
  final ResourceRelationFilter filter;

  const ResourceRelation({
    required this.name,
    required this.resourceId,
    required this.filter,
  });
}
