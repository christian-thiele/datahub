import 'package:datahub/datahub.dart';

import 'resource_filter_type.dart';

part 'resource_filter.g.dart';

@Data()
class ResourceFilter extends $ResourceFilter {
  final List<ResourceFilter>? or;
  final List<ResourceFilter>? and;
  final String? fieldId;
  final ResourceFilterType? type;
  final String? value;

  const ResourceFilter({
    this.or = const [],
    this.and = const [],
    this.fieldId,
    this.type,
    this.value,
  });
}
