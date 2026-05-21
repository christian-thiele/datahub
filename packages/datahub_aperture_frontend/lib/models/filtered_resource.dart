import 'package:datahub_aperture/datahub_aperture.dart';

class FilteredResource {
  final String resourceId;
  final ResourceFilter filter;
  final String name;

  FilteredResource({
    required this.resourceId,
    required this.filter,
    required this.name,
  });
}
