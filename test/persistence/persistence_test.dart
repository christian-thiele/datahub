import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/src/persistence/postgresql/postgresql_database_adapter.dart';
import 'package:test/test.dart';

import '../utils/message_matcher.dart';
import 'dao/blog_daos/article_dao.dart';
import 'dao/blog_daos/blog_dao.dart';
import 'dao/blog_daos/user_dao.dart';

const String host = '127.0.0.1';
const int port = 5432;
const String database = 'postgres';
const String user = 'postgres';
const String password = 'mysecretpassword';

void main() {
  group('PostgreSQL', () {
    test('connect / initialize', _testScheme);
  });
}

Future _testScheme() async {
  final blogLayout = LayoutMirror.reflect(BlogDao);
  final articleLayout = LayoutMirror.reflect(ArticleDao);
  final userLayout = LayoutMirror.reflect(UserDao);

  final schema =
      DataSchema('blogsystem', 1, [blogLayout, articleLayout, userLayout]);

  final adapter = PostgreSQLDatabaseAdapter(schema, host, port, database,
      username: user, password: password);

  expect(() async => await adapter.openConnection(),
      throwsWithType<PersistenceException>('Schema not initialized.'));

  await adapter.initializeSchema();

  final connection = await adapter.openConnection();
  expect(connection.isOpen, isTrue);

  // insert some data
  final blogUser = UserDao(name: 'testUser');
  final userId = await connection.insert(userLayout, blogUser);
  print('Inserted with pk: $userId');

  // query some data
  final blogUsers = await connection.query<UserDao>(userLayout);
  expect(blogUsers.any((element) => element.id == userId), isTrue);

  // delete some data
  await connection.delete(userLayout, blogUser);

  final blogUsers2 = await connection.query<UserDao>(userLayout);
  expect(blogUsers2.any((element) => element.id == userId), isFalse);
}
