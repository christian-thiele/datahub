import 'package:datahub/datahub.dart';

import 'resource_field.dart';
import 'resource_relation.dart';

part 'resource_description.g.dart';

@Data()
class ResourceDescription extends _ResourceDescription {
  final String id;
  final String name;
  final String? namePlural;
  final int icon;
  final List<ResourceField> fields;
  final List<ResourceRelation> relations;
  final String idField;
  final String? displayField;
  final bool readOnly;

  const ResourceDescription({
    required this.id,
    required this.name,
    this.namePlural,
    required this.icon,
    required this.fields,
    required this.relations,
    required this.idField,
    this.displayField,
    required this.readOnly,
  });

  static DataBean<ResourceDescription> get bean => _ResourceDescription.bean;
}
