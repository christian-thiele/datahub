import 'package:datahub/datahub.dart';

part 'placeholder_user.g.dart';

@TransferObject()
class PlaceholderUser extends _TransferObject {
  final String id;
  final String name;

  PlaceholderUser({
    required this.id,
    required this.name,
  });
}
