import 'package:datahub/datahub.dart';

import 'resource_field_lookup.dart';
import 'resource_field_type.dart';

part 'resource_field.g.dart';

@Data()
class const ResourceField({
  required final String id,
  required final String name,
  required final ResourceFieldType type,
  final bool nullable = false,
  final String? description,
  final bool readOnly = false,
  final bool auto = false,
  final int? length,
  final String? validation,
  final List<ResourceField>? objectDescription,
  final List<String>? enumValues,
  final ResourceFieldLookup? lookup,
  final bool allowFilter = true,
  final bool allowSort = true,
}) extends $ResourceField;
