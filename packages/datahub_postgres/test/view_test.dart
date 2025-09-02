import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/src/types/types.dart';

import 'data/person.dart';

void main() {
  TestHost(
    [
      () => PostgresqlService(
            schema: PostgresqlSchema(
              name: 'view_test',
              relations: [
                PostgresqlDataTable(Person.bean),
                PostgresqlView(
                  name: 'specials',
                  sql: SqlSelect(
                    SqlQualifiedRelation('view_test', 'person'),
                    [
                      SqlAttribute('first_name'),
                      SqlAttribute('last_name'),
                    ],
                    where: Sql('is_special'),
                  ),
                  attributes: [
                    PostgresqlAttribute(
                      name: 'first_name',
                      type: PostgresqlString(),
                    ),
                    PostgresqlAttribute(
                      name: 'last_name',
                      type: PostgresqlString(),
                    ),
                  ],
                ),
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
              firstName: 'Hans',
              lastName: 'Peter',
              birthday: null,
              isSpecial: false,
            ),
          );

          await repo.create(
            Person(
              firstName: 'Peter',
              lastName: 'Lustig',
              birthday: null,
              isSpecial: true,
            ),
          );

          final result = await postgres.useConnection((connection) async {
            return await connection.runTransaction((context) async {
              return await context.execute(SqlSelect(
                SqlQualifiedRelation('view_test', 'specials'),
                [const SqlWildcard()],
              ));
            });
          });

          print('${result.length} results');
          for (final row in result) {
            print(row);
          }
        });
      });
    });
  });
}
