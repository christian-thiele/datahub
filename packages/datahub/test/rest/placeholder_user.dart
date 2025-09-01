import 'package:datahub/datahub.dart';

part 'placeholder_user.g.dart';

@Data()
class PlaceholderUser extends _PlaceholderUser {
  final String id;
  final String name;

  const PlaceholderUser({
    required this.id,
    required this.name,
  });

  static DataBean<PlaceholderUser> get bean => _PlaceholderUser.bean;
}
