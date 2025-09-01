import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/expect.dart';

void main() {
  TestHost(
    [
      () => PostgresqlService(
          schema: PostgresqlSchema(name: 'postgres', relations: [])),
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
    $.test('PostgreSQL Connection', () async {
      final postgres = resolve<PostgresqlService>();
      final result = await postgres.useConnection((connection) async {
        return await connection.runTransaction((context) async {
          return await context.execute(Sql('SELECT 1337;'));
        });
      });

      expect(result.first.first, equals(1337));
    });
  });
}
