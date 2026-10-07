import 'package:datahub/datahub.dart';

import 'resource_action.dart';
import 'resource_field.dart';
import 'resource_relation.dart';
import 'resource_workflow.dart';

part 'resource_description.g.dart';

@Data()
class ResourceDescription extends $ResourceDescription {
  final String id;
  final String name;
  final String? namePlural;
  final int icon;
  final List<ResourceField> fields;
  final List<ResourceRelation> relations;
  final String idField;
  final List<String> displayFields;
  final String? titleTemplate;
  final bool readOnly;
  final bool revisable;
  final List<ResourceAction> actions;

  /// The workflow the elements move through, if the application has one for
  /// the element type.
  final ResourceWorkflow? workflow;

  const ResourceDescription({
    required this.id,
    required this.name,
    this.namePlural,
    required this.icon,
    required this.fields,
    required this.relations,
    required this.idField,
    this.displayFields = const [],
    this.titleTemplate,
    required this.readOnly,
    required this.revisable,
    required this.actions,
    this.workflow,
  });
}
