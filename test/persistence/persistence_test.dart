import 'dart:math';
import 'dart:typed_data';
import 'package:boost/boost.dart';

import 'package:cl_datahub/cl_datahub.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import 'dao/blog_daos/article_dao.dart';
import 'dao/blog_daos/blog_dao.dart';
import 'dao/blog_daos/user_dao.dart';

import '../utils/message_matcher.dart';

const String host = '127.0.0.1';
const int port = 5432;
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
    test('basic orm features', _testScheme);
  }, skip: skip);
}

Future _testScheme() async {
  final blogLayout = LayoutMirror.reflect(BlogDao);
  final articleLayout = LayoutMirror.reflect(ArticleDao);
  final userLayout = LayoutMirror.reflect(UserDao);

  final imageData = Uint8List.fromList(
      Iterable.generate(256, (i) => Random().nextInt(255)).toList());

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
  final blogUser = UserDao(
    name: 'testUser',
    location: Point(1.234, 2.345),
    executionId: 0,
    image: imageData,
  );
  final userId = await connection.insert(userLayout, blogUser);
  print('Inserted with pk: $userId');

  // query some data
  final blogUsers = await connection.query<UserDao>(userLayout);
  expect(blogUsers.any((element) => element.id == userId), isTrue);
  expect(blogUsers.firstWhere((element) => element.id == userId).location,
      equals(Point(1.234, 2.345)));
  expect(blogUsers.firstWhere((element) => element.id == userId).image.length,
      imageData.length);
  expect(blogUsers.firstWhere((element) => element.id == userId).image,
      orderedEquals(imageData));

  // delete some data
  await connection.delete(userLayout, blogUser.copyWith(id: userId));

  final blogUsers2 = await connection.query<UserDao>(userLayout);
  expect(blogUsers2.any((element) => element.id == userId), isFalse);

  // insert alotta:
  final executionId = Random().nextInt(5000);
  for (var i = 0; i < 50; i++) {
    final blogUser = UserDao(
        name: 'TestUser$i',
        location: Point(Random().nextDouble(), Random().nextDouble()),
        executionId: executionId,
        image: imageData);
    final userId = await connection.insert(userLayout, blogUser);
    print('Inserted with pk: $userId');
  }

  // query with sort:
  final ascUsers = await connection.query<UserDao>(userLayout,
      filter: Filter.equals('executionId', executionId),
      sort: Sort.asc('name'),
      limit: 50);
  final descUsers = await connection.query<UserDao>(
    userLayout,
    filter: Filter.equals('executionId', executionId),
    sort: Sort.desc('name'),
    limit: 50,
  );

  expect(ascUsers, unorderedEquals(descUsers));
  expect(ascUsers, isNot(orderedEquals(descUsers)));
  expect(
      ascUsers, orderedEquals(ascUsers.toList()..sortBy((u) => u.name, true)));
  expect(descUsers,
      orderedEquals(descUsers.toList()..sortBy((u) => u.name, false)));
}
