import 'dart:typed_data';

import 'package:cl_datahub/cl_datahub.dart';

part 'user_dao.g.dart';

@DaoType(name: 'user')
class UserDao extends _Dao {
  @PrimaryKeyDaoField()
  final int id;

  final int executionId;

  @DaoField(name: 'username', length: 128)
  final String name;

  final Point? location;

  final Uint8List image;

  UserDao({
    this.id = 0,
    required this.name,
    required this.location,
    required this.executionId,
    required this.image,
  });

  UserDao copyWith({
    int? id,
    String? name,
    Point? location,
    int? executionId,
    Uint8List? image,
  }) =>
      UserDao(
        id: id ?? this.id,
        name: name ?? this.name,
        location: location ?? this.location,
        executionId: executionId ?? this.executionId,
        image: image ?? this.image,
      );

  @override
  bool operator ==(Object other) {
    if (other is UserDao) {
      return id == other.id;
    }

    return super == other;
  }
}
