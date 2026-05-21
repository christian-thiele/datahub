import 'package:datahub/datahub.dart';

import 'resource_field.dart';

part 'resource_action.g.dart';

@Data()
class ResourceAction extends $ResourceAction {
  final String id;
  final String displayName;
  final int icon;
  final List<ResourceField> parameterFields;

  const ResourceAction({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.parameterFields,
  });
}
