import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/src/data/postgresql_data_attribute.dart';
import 'package:postgres/postgres.dart';

class PostgresqlRepository extends BaseService {
  late final PostgresqlService _service;

  PostgresqlSchema get schema => _service.schema;

  PostgresqlRepository({
    String config = 'postgresql.repository',
  }) : super(config);

  @override
  Future<void> initialize() async {
    await super.initialize();
    _service = resolve<PostgresqlService>();
  }

  Future<T> runTransaction<T>(
      Future<T> Function(PostgresqlContext context) delegate) async {
    return await _service.useConnection((connection) async {
      return await connection.runTransaction(delegate);
    });
  }
}
