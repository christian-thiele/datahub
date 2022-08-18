import 'dart:math';
import 'dart:typed_data';
import 'package:boost/boost.dart';

import 'package:datahub/datahub.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../loremipsum.dart';
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
  final imageData = Uint8List.fromList(
      Iterable.generate(256, (i) => Random().nextInt(255)).toList());

  final schema = DataSchema(
      'blogsystem', 1, [BlogDaoDataBean, ArticleDaoDataBean, UserDaoDataBean]);

  final adapter = PostgreSQLDatabaseAdapter(schema, host, port, database,
      username: user, password: password);

  expect(() async => await adapter.openConnection(),
      throwsWithType<PersistenceException>('Schema not initialized.'));

  await adapter.initializeSchema();

  final connection = await adapter.openConnection();
  expect(connection.isOpen, isTrue);
  await connection.runTransaction((context) async {
    // insert some data
    final blogUser = UserDao(
      name: 'testUser',
      location: Point(1.234, 2.345),
      executionId: 0,
      image: imageData,
    );
    final userId = await context.insert(blogUser);

    // query some data
    final blogUsers = await context.query(UserDaoDataBean);
    expect(blogUsers.any((element) => element.id == userId), isTrue);
    expect(blogUsers.firstWhere((element) => element.id == userId).location,
        equals(Point(1.234, 2.345)));
    expect(blogUsers.firstWhere((element) => element.id == userId).image.length,
        imageData.length);
    expect(blogUsers.firstWhere((element) => element.id == userId).image,
        orderedEquals(imageData));

    // delete some data
    await context.delete(blogUser.copyWith(id: userId));

    final blogUsers2 = await context.query<UserDao>(UserDaoDataBean);
    expect(blogUsers2.any((element) => element.id == userId), isFalse);

    // insert alotta:
    final executionId = Random().nextInt(5000);
    final articleCount = 10;
    for (var i = 0; i < 50; i++) {
      final blogUser = UserDao(
        name: 'TestUser$i',
        location: Point(Random().nextDouble(), Random().nextDouble()),
        executionId: executionId,
        image: imageData,
      );
      final userId = await context.insert(blogUser);

      final blog = BlogDao('${executionId}_bloggo_$i', userId,
          displayName: 'Blog of User $i');
      await context.insert(blog);

      if (i < 40) {
        for (var x = 0; x < articleCount; x++) {
          final article = ArticleDao(
            title: 'I am $i and this is $x',
            content: loremIpsum.substring(0, 150),
            blogKey: blog.key,
            createdTimestamp: DateTime.now(),
            lastEditTimestamp: DateTime.now(),
            image: imageData,
            userId: userId,
          );
          await context.insert(article);
        }
      }
    }

    // query with sort:
    final ascUsers = await context.query<UserDao>(
      UserDaoDataBean,
      filter: UserDaoDataBean.executionIdField.equals(executionId),
      sort: UserDaoDataBean.nameField.asc(),
    );

    final descUsers = await context.query<UserDao>(
      UserDaoDataBean,
      filter: UserDaoDataBean.executionIdField.equals(executionId),
      sort: UserDaoDataBean.nameField.desc(),
    );

    expect(ascUsers, unorderedEquals(descUsers));
    expect(ascUsers, orderedEquals(descUsers.reversed));

    expect(ascUsers,
        orderedEquals(ascUsers.toList()..sortBy((u) => u.name, true)));
    expect(descUsers,
        orderedEquals(descUsers.toList()..sortBy((u) => u.name, false)));

    // idExists
    final exists = await context.idExists(UserDaoDataBean, descUsers.first.id);
    expect(exists, isTrue);

    // select with join
    final joinedData = await context.select(
      ArticleDaoDataBean.join(UserDaoDataBean),
      [
        WildcardSelect(bean: ArticleDaoDataBean),
        FieldSelect(UserDaoDataBean.nameField, alias: 'user_name'),
        UserDaoDataBean.executionIdField,
      ],
      filter: UserDaoDataBean.executionIdField.equals(executionId),
    );

    expect(joinedData.length, equals(articleCount * 40));

    final sample = joinedData.random;
    expect(sample.keys.length, equals(ArticleDaoDataBean.fields.length + 2));
    expect(sample['user_name'], isA<String>());
    expect(sample['user_name'] as String, isNotEmpty);

    // query distinct
    final distinct = await context.query(
      UserDaoDataBean.leftJoin(
        ArticleDaoDataBean,
        mainField: UserDaoDataBean.idField,
        otherField: ArticleDaoDataBean.userIdField,
      ),
      distinct: [UserDaoDataBean.idField],
      filter: UserDaoDataBean.executionIdField.equals(executionId),
    );

    expect(distinct.length, equals(ascUsers.length));
    expect(
        distinct, anyElement((Tuple<UserDao, ArticleDao?> e) => e.b == null));
    expect(
        distinct, anyElement((Tuple<UserDao, ArticleDao?> e) => e.b != null));
    expect(
        distinct,
        everyElement((Tuple<UserDao, ArticleDao?> e) =>
            e.b == null || e.a.id == e.b!.userId));
  });
}
