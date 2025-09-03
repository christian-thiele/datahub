import 'package:datahub/datahub.dart';

import 'resource_field_type.dart';

part 'resource_field.g.dart';

@Data()
class ResourceField extends _ResourceField {
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
  });

  static DataBean<ResourceField> get bean => _ResourceField.bean;
}
