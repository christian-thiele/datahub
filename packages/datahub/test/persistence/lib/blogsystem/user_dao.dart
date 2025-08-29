import 'dart:typed_data';

import 'package:datahub/datahub.dart';

part 'user_dao.g.dart';

@DaoType(name: 'user')
class UserDao extends _Dao {
  @PrimaryKeyDaoField()
  final int id;

  final int executionId;

  @DaoField(name: 'username', length: 128)
  final String name;

  final Uint8List image;

  UserDao({
    this.id = 0,
    required this.name,
    required this.executionId,
    required this.image,
  });

  @override
  bool operator ==(Object other) {
    if (other is UserDao) {
      return id == other.id;
    }

    return super == other;
  }

  @override
  int get hashCode => Object.hashAll([id, name, executionId, image]);
}
