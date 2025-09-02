import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/data.dart';

import 'data/person.dart';

void main() {
  TestHost(
    [
      () => PostgresqlService(
            schema: PostgresqlSchema(
              name: 'test',
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
    $.test('Data CRUD', () async {
      final postgres = resolve<PostgresqlService>();
      final repo = resolve<PostgresqlDataRepository<Person>>();
      await postgres.useConnection((connection) async {
        await connection.runTransaction((context) async {
          await repo.create(
            Person(
              firstName: 'Something',
              lastName: 'Something',
              birthday: null,
              isSpecial: false,
            ),
          );

          final data = await repo.getAll();
          final id = data.max((e) => e.id).id + 1;
        });
      });
    });
  });
}
