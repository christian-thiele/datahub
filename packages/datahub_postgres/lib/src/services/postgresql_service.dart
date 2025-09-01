import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/src/types/types.dart';
import 'package:postgres/postgres.dart' as pg;
import 'abstract/database_connection_service.dart';

import 'postgresql_connection.dart';

class PostgresqlService
    extends DatabaseConnectionService<PostgresqlConnection> {
  late final logStatements = config<bool?>('logStatements') ?? false;
  final PostgresqlSchema schema;

  PostgresqlService({
    String config = 'postgresql',
    required this.schema,
  }) : super(config);

  @override
  Future<void> initialize() async {
    await super.initialize();

    await useConnection((connection) async {
      await connection.runTransaction((context) async {
        final schemaResult = await context.execute(
          SqlSelect(
            SqlQualifiedRelation('information_schema', 'schemata'),
            [SqlAttribute('schema_name')],
          ),
        );

        final schemaNames =
            schemaResult.map((e) => e.first.toString()).toList();

        if (!schemaNames.contains(schema.name)) {
          resolve<LogService?>()?.warn(
              'Schema "${schema.name}" does not exist. Creating schema.');

          await context.execute(SqlCreateSchema(schema));
        }

        final tableResults = await context.execute(
          SqlSelect(
            SqlQualifiedRelation('information_schema', 'tables'),
            [SqlAttribute('table_name')],
            where: Sql.ofSegments([
              SqlTextSegment('table_schema = '),
              SqlParamSegment<String>(schema.name, const PostgresqlString())
            ]),
          ),
        );

        // TODO maybe move this to repos so they are more independent
        final tables = tableResults.map((e) => e.first.toString());

        for (final relation in schema.relations) {
          if (!tables.contains(relation.name)) {
            resolve<LogService?>()?.warn(
                'Relation "${relation.name}" does not exist. Creating relation.');
            await context.execute(SqlCreateRelation(schema, relation));
          }
        }
      });
    });
  }

  @override
  Future<PostgresqlConnection> openConnection() async {
    return PostgresqlConnection(
      this,
      await pg.Connection.open(
        pg.Endpoint(
          host: config<String>('host'),
          port: config<int?>('port') ?? 5432,
          database: config<String>('database'),
          username: config<String?>('username'),
          password: config<String?>('password'),
        ),
        settings: pg.ConnectionSettings(
          applicationName: resolve<ConfigService>().serviceName,
          connectTimeout:
              Duration(seconds: config<int?>('timeoutInSeconds') ?? 30),
          queryTimeout:
              Duration(seconds: config<int?>('queryTimeoutInSeconds') ?? 30),
          timeZone: config<String?>('timeZone') ?? 'UTC',
          sslMode: switch (config<bool?>('useSsl')) {
            true => pg.SslMode.require,
            false => pg.SslMode.disable,
            _ => null,
          },
          queryMode: pg.QueryMode.extended,
        ),
      ),
    );
  }
}
