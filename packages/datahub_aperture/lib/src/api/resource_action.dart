import 'package:datahub/datahub.dart';

import 'resource_field.dart';

part 'resource_action.g.dart';

@Data()
class const ResourceAction({
  required final String id,
  required final String displayName,
  required final int icon,
  required final List<ResourceField> parameterFields,
}) extends $ResourceAction;
