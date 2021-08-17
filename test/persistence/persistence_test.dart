import 'package:cl_datahub/cl_datahub.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import 'dao/blog_daos/article_dao.dart';
import 'dao/blog_daos/blog_dao.dart';
import 'dao/blog_daos/user_dao.dart';

import '../utils/message_matcher.dart';

const String host = '127.0.0.1';
const int port = 49154;
const String database = 'postgres';
const String user = 'postgres';
const String password = 'mysecretpassword';

void main() async {
  String? skip;
  try {
    final connection = PostgreSQLConnection(host, port, database,
        username: user, password: password);
    await connection.open();
    await connection.close();
  } catch (e) {
    skip = 'No SQL Server running.';
  }

  group('PostgreSQL', () {
    test('connect / initialize', _testScheme);
  }, skip: skip);
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
  final blogUser = UserDao(name: 'testUser', location: Point(1.234, 2.345));
  final userId = await connection.insert(userLayout, blogUser);
  print('Inserted with pk: $userId');

  // query some data
  final blogUsers = await connection.query<UserDao>(userLayout);
  expect(blogUsers.any((element) => element.id == userId), isTrue);
  expect(blogUsers.firstWhere((element) => element.id == userId).location,
      equals(Point(1.234, 2.345)));

  // delete some data
  await connection.delete(userLayout, blogUser.copyWith(id: userId));

  final blogUsers2 = await connection.query<UserDao>(userLayout);
  expect(blogUsers2.any((element) => element.id == userId), isFalse);
}
