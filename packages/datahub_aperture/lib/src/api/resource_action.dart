import 'package:datahub/datahub.dart';

part 'resource_action.g.dart';

@Data()
class ResourceAction extends $ResourceAction {
  final String id;
  final String displayName;
  final int icon;

  const ResourceAction({
    required this.id,
    required this.displayName,
    required this.icon,
  });
}
