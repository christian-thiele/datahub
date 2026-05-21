import 'package:datahub/datahub.dart';

import 'resource_filter_type.dart';

part 'resource_relation_filter.g.dart';

@Data()
class ResourceRelationFilter extends $ResourceRelationFilter {
  final List<ResourceRelationFilter>? or;
  final List<ResourceRelationFilter>? and;
  final String? fieldId;
  final ResourceFilterType? type;
  final String? value;
  final String? valueFieldId;

  const ResourceRelationFilter({
    this.or = const [],
    this.and = const [],
    this.fieldId,
    this.type,
    this.value,
    this.valueFieldId,
  });
}
