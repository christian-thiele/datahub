import 'package:datahub/datahub.dart';

import 'resource_filter_type.dart';

part 'resource_filter.g.dart';

@Data()
class const ResourceFilter({
  final List<ResourceFilter>? or = const [],
  final List<ResourceFilter>? and = const [],
  final String? fieldId,
  final ResourceFilterType? type,
  final String? value,
  final String? search,
}) extends $ResourceFilter;
