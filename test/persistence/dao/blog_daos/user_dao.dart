import 'package:cl_datahub/cl_datahub.dart';

@DaoType(name: 'user')
class UserDao {
  @PrimaryKeyDaoField()
  final int id;

  final String name;

  UserDao(this.id, this.name);
}
