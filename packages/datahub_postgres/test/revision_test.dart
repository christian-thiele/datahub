import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/src/revision/revisioned_schema.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'data/person.dart';

void main() {
  TestHost(
    [
      () => PostgresqlService(
            schema: RevisionedSchema(
              name: 'revision_test',
              relations: [
                PostgresqlDataTable(Person.bean),
              ],
            ),
          ),
      () => PostgresqlDataRepository(bean: Person.bean),
    ],
    config: {
      'postgresql': {
        'host': '192.168.178.85',
        'database': 'datahub_postgres',
        'username': 'postgres',
        'password': 'postgres',
        'useSsl': false,
      },
    },
  ).declare(($) {
    $.test('Data Revision', () async {
      final postgres = resolve<PostgresqlService>();
      final repo = resolve<PostgresqlDataRepository<Person>>();
      expect(
        () async {
          await postgres.useConnection((connection) async {
            await connection.runTransaction((context) async {
              final data = await repo.getAll();
              print('${data.length} entries:');
              for (final entry in data) {
                print(jsonEncode(entry.toJson()));
              }

              throw Exception('done');
            });
          });
        },
        throwsA(isA<Exception>()),
      );
    }, timeout: Timeout.none);
  });
}
