import 'package:cl_datahub/cl_datahub.dart';

@DaoType(name: 'user')
class UserDao {
  @PrimaryKeyDaoField()
  final int id;

  final String name;

  UserDao({this.id = 0, required this.name});

  UserDao copyWith({int? id, String? name}) =>
      UserDao(id: id ?? this.id, name: name ?? this.name);
}
