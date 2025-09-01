import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/src/services/postgresql_repository.dart';

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
          final data = await repo.getData();
          final id = data.max((e) => e.id).id + 1;

          await repo.createData(
            Person(
              id: id,
              firstName: 'Something',
              lastName: 'Something',
              birthday: null,
            ),
          );


        });
      });
    });
  });
}
