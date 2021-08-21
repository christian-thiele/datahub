import 'package:cl_datahub/cl_datahub.dart';

@DaoType(name: 'user')
class UserDao {
  @PrimaryKeyDaoField()
  final int id;

  final int executionId;

  final String name;

  final Point location;

  UserDao(
      {this.id = 0,
      required this.name,
      required this.location,
      required this.executionId});

  UserDao copyWith(
          {int? id, String? name, Point? location, int? executionId}) =>
      UserDao(
        id: id ?? this.id,
        name: name ?? this.name,
        location: location ?? this.location,
        executionId: executionId ?? this.executionId,
      );

  @override
  bool operator ==(Object other) {
    if (other is UserDao) {
      return id == other.id;
    }

    return super == other;
  }
}
