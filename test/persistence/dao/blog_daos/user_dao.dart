import 'package:cl_datahub/cl_datahub.dart';

@DaoType(name: 'user')
class UserDao {
  @PrimaryKeyDaoField()
  final int id;

  final String name;

  final Point location;

  UserDao({this.id = 0, required this.name, required this.location});

  UserDao copyWith({int? id, String? name, Point? location}) => UserDao(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location);
}
