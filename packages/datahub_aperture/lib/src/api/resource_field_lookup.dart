import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/api.dart';

part 'resource_field_lookup.g.dart';

@Data()
class const ResourceFieldLookup({
  required final String resourceId,
  required final String resourceFieldId,
  required final ResourceRelationFilter filter,
}) extends $ResourceFieldLookup;
