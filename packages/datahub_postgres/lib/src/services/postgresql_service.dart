import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:postgres/postgres.dart';
import 'abstract/database_connection_service.dart';

import 'postgresql_connection.dart';

class PostgresqlService
    extends DatabaseConnectionService<PostgresqlConnection> {
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
        final result = await context.execute(
          SqlSelect(
            SqlQualifiedRelation('information_schema', 'schemata'),
            [SqlAttribute('schema_name')],
          ),
        );

        final schemaNames = result.map((e) => e.first.toString()).toList();

        if (!schemaNames.contains(schema.name)) {
          resolve<LogService?>()?.warn(
            'Schema "${schema.name}" does not exist. Creating schema and relations.',
          );

          await context.execute(SqlCreateSchema(schema));

          for (final relation in schema.relations) {
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
      await Connection.open(
        Endpoint(
          host: config<String>('host'),
          port: config<int?>('port') ?? 5432,
          database: config<String>('database'),
          username: config<String?>('username'),
          password: config<String?>('password'),
        ),
        settings: ConnectionSettings(
          applicationName: resolve<ConfigService>().serviceName,
          connectTimeout:
              Duration(seconds: config<int?>('timeoutInSeconds') ?? 30),
          queryTimeout:
              Duration(seconds: config<int?>('queryTimeoutInSeconds') ?? 30),
          timeZone: config<String?>('timeZone') ?? 'UTC',
          sslMode: switch (config<bool?>('useSsl')) {
            true => SslMode.require,
            false => SslMode.disable,
            _ => null,
          },
          queryMode: QueryMode.extended,
        ),
      ),
    );
  }
}
