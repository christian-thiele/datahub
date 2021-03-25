import 'package:cl_datahub/cl_datahub.dart';
import 'package:cl_datahub/src/persistence/postgresql/postgresql_database_adapter.dart';
import 'package:test/test.dart';

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
    test('connect', _testConnect);
    test('create scheme', _testScheme);
  });
}

Future _testConnect() async {
  final adapter = PostgreSQLDatabaseAdapter(host, port, database,
      username: user, password: password);

  final connection = await adapter.openConnection();
  expect(connection.isOpen, isTrue);
}

Future _testScheme() async {
  final adapter = PostgreSQLDatabaseAdapter(host, port, database,
      username: user, password: password);

  final connection = await adapter.openConnection();
  expect(connection.isOpen, isTrue);

  final blogLayout = LayoutMirror.reflect(BlogDao);
  final articleLayout = LayoutMirror.reflect(ArticleDao);
  final userLayout = LayoutMirror.reflect(UserDao);

  final scheme =
      DataScheme('blogsystem', 1, [blogLayout, articleLayout, userLayout]);

  await connection.initialize(scheme);
}
