import 'package:cl_datahub/src/persistence/dao/data_layout.dart';
import 'package:cl_datahub/src/persistence/database_connection.dart';
import 'package:cl_datahub/src/persistence/persistence_exception.dart';
import 'package:cl_datahub/src/persistence/postgresql/postgresql_database_adapter.dart';
import 'package:cl_datahub/src/persistence/postgresql/sql/sql_builder.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:postgres/postgres.dart' as postgres;

class PostgreSQLDatabaseConnection extends DatabaseConnection {
  final postgres.PostgreSQLConnection _connection;

  PostgreSQLDatabaseConnection(
      PostgreSQLDatabaseAdapter adapter, this._connection)
      : super(adapter);

  @override
  bool get isOpen => !_connection.isClosed;

  @override
  Future<void> close() async => await _connection.close();

  @override
  Future<void> createScheme(List<DataLayout> layouts) async {
    _throwClosed();
    for (final layout in layouts) {
      await execute(CreateTableBuilder(layout.name, ifNotExists: true)
        ..fields.addAll(layout.fields));
    }
  }

  Future<int> execute(SqlBuilder builder) async {
    return await _connection.execute(builder.buildSql());
  }

  void _throwClosed() {
    if (!isOpen) {
      throw PersistenceException.closed(this);
    }
  }
}
