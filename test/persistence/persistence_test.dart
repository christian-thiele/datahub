import 'dart:typed_data';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:test/test.dart';

import 'lib/dao/blog_daos/article_dao.dart';
import 'lib/dao/blog_schema.dart';

void main() {
  final host = TestHost(
    [
      () => PostgreSQLDatabaseAdapter('postgres', BlogSchema()),
      () => CRUDRepository('postgres', ArticleDaoDataBean),
    ],
    config: {
      'postgres': {
        'host': 'postgres',
        'database': 'test_db',
        'username': 'testuser',
        'password': 'secretpassword',
      },
    },
  );

  group('Persistence', () {
    test('CRUD Repository (PostgreSQL)', host.test(() async {
      final article = ArticleDao(
        userId: 1,
        blogKey: 'abc',
        content: 'abc123',
        createdTimestamp: DateTime.now(),
        image: Uint8List(0),
        lastEditTimestamp: DateTime.now(),
        title: 'Test',
      );

      final repo = resolve<CRUDRepository<ArticleDao, int>>();
      final adapter = resolve<DatabaseAdapter>();
      print('Pool ${adapter.poolAvailable} / ${adapter.poolSize}');

      Future<void> somethingStupid() async {
        await repo.transaction((context) async {
          print('Blocking transaction.');
          print('Pool ${adapter.poolAvailable} / ${adapter.poolSize}');
          await Future.delayed(const Duration(seconds: 5));
          print('Released transaction.');
        });
        print('Pool ${adapter.poolAvailable} / ${adapter.poolSize}');
      }

      final future = somethingStupid();

      final id = await repo.create(article);
      print('Created with id $id');
      final results = await repo.getAll();
      expect(results.length, greaterThan(0));

      print('Pool ${adapter.poolAvailable} / ${adapter.poolSize}');
      await future;

      expect(adapter.poolAvailable, 3);
      await repo.transaction((context) async {
        print((await repo.first())!.id);
        expect(adapter.poolAvailable, 2);
        await repo.transaction((context) async {
          print((await repo.first())!.id);
          expect(adapter.poolAvailable, 2);
        });
      });

      expect(adapter.poolAvailable, 3);
    }));
  });
}
