import 'package:datahub/datahub.dart';

import 'module_type.dart';

part 'module_description.g.dart';

@Data()
class ModuleDescription extends $ModuleDescription {
  final String id;
  final String displayName;
  final int icon;
  final ModuleType type;
  final Map<String, dynamic> configuration;

  const ModuleDescription({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.type,
    required this.configuration,
  });
}
