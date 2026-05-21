import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/expect.dart';

void main() {
  declareTest(
    'PostgreSQL Pool Timeout Test',
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
        poolTimeout: Config.value(Duration(seconds: 2)),
      ),

      ApiService(
        port: Config.value(0),
        routes: [
          ResourceEndpoint(
            matcher: RoutePattern('/select'),
            get: (request) async {
              final postgres = Find<Postgresql>().find();
              final result = await postgres.useConnection((connection) async {
                return await connection.runTransaction((context) async {
                  await Future.delayed(const Duration(seconds: 6));
                  return await context.execute(RawSql('SELECT 1337;'));
                });
              });

              return {'result': result.firstOrNull?.firstOrNull};
            },
          ),
        ],
      ),
    ],
    () async {
      final client = Find<Api>().find().connectHttp11();

      final futures = [
        for (final _ in Iterable.generate(10))
          client.get('/select', throwOnError: false),
      ];

      final results = await Future.wait(futures);
      expect(results.where((e) => e.statusCode == 200).length, lessThan(7));
    },
  );
}
