import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/expect.dart';

void main() {
  declareTest(
    'PostgreSQL Connection',
    environment: ComposeEnvironment.fromFile(
      'test/single-postgres.docker-compose.yml',
    ),
    [
      PostgresqlService(
        host: Config('test.services.postgres.host'),
        port: Config('test.services.postgres.5432'),
        database: Config.value('datahub_postgres'),
        username: Config.value('postgres'),
        password: Config.value('postgres'),
        useSsl: Config.value(false),
      ),
    ],
    () async {
      final postgres = Find<Postgresql>().find();
      final result = await postgres.useConnection((connection) async {
        return await connection.runTransaction((context) async {
          return await context.execute(RawSql('SELECT 1337;'));
        });
      });

      expect(result.first.first, equals(1337));
    },
  );
}
