import 'package:datahub/datahub.dart';

import 'resource_action.dart';
import 'resource_field.dart';
import 'resource_relation.dart';
import 'resource_workflow.dart';

part 'resource_description.g.dart';

@Data()
class const ResourceDescription({
  required final String id,
  required final String name,
  final String? namePlural,
  required final int icon,
  required final List<ResourceField> fields,
  required final List<ResourceRelation> relations,
  required final String idField,
  final List<String> displayFields = const [],
  final String? titleTemplate,
  final bool allowCreate = true,
  final bool allowUpdate = true,
  final bool allowDelete = true,
  required final bool revisable,
  required final List<ResourceAction> actions,

  /// The workflow the elements move through, if the application has one for
  /// the element type.
  final ResourceWorkflow? workflow,
}) extends $ResourceDescription;
