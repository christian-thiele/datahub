import 'package:datahub/datahub.dart';

import 'resource_filter_type.dart';

part 'resource_relation_filter.g.dart';

@Data()
class const ResourceRelationFilter({
  final List<ResourceRelationFilter>? or = const [],
  final List<ResourceRelationFilter>? and = const [],
  final String? fieldId,
  final ResourceFilterType? type,
  final String? value,
  final String? valueFieldId,
}) extends $ResourceRelationFilter;
