import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
        'host': 'localhost',
        'database': 'test_db',
        'username': 'testuser',
        'password': 'secretpassword',
      },
    },
  );

  group('Persistence', () {
    test('Blocking transactions (PostgreSQL)', host.test(() async {
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

      while (true) {
        try {
          await repo.transaction((context) async {
            print('Blocking transaction.');
            print('Pool ${adapter.poolAvailable} / ${adapter.poolSize}');
            await countdown(3);
            print('Releasing transaction.');
          });
        } catch (e) {
          resolve<LogService>().error('Error', error: e);
        }
        print('Pool ${adapter.poolAvailable} / ${adapter.poolSize}');
      }
    }), timeout: Timeout.none);
  });
}

Future<void> countdown(int seconds) async {
  for (var i = 0; i < seconds; i++) {
    print(seconds - i);
    await Future.delayed(const Duration(seconds: 1));
  }
}
