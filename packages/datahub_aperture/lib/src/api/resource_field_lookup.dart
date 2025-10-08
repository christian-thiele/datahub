import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';

part 'resource_field_lookup.g.dart';

@Data()
class ResourceFieldLookup extends $ResourceFieldLookup {
  final String resourceId;
  final String resourceFieldId;
  final ResourceRelationFilter filter;

  const ResourceFieldLookup({
    required this.resourceId,
    required this.resourceFieldId,
    required this.filter,
  });
}
