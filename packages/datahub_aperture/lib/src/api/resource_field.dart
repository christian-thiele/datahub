import 'package:datahub/datahub.dart';

import 'resource_field_lookup.dart';
import 'resource_field_type.dart';

part 'resource_field.g.dart';

@Data()
class ResourceField extends $ResourceField {
  final String id;
  final String name;
  final ResourceFieldType type;
  final bool nullable;
  final String? description;
  final bool readOnly;
  final int? length;
  final String? validation;
  final List<ResourceField>? objectDescription;
  final List<String>? enumValues;
  final ResourceFieldLookup? lookup;
  final bool allowFilter;
  final bool allowSort;

  const ResourceField({
    required this.id,
    required this.name,
    required this.type,
    this.nullable = false,
    this.description,
    this.readOnly = false,
    this.length,
    this.validation,
    this.objectDescription,
    this.enumValues,
    this.lookup,
    this.allowFilter = true,
    this.allowSort = true,
  });
}
