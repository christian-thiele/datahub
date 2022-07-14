import 'package:datahub/datahub.dart';

import 'sql/sql.dart';

class PostgreSQLDatabaseMigrator extends Migrator {
  final DataSchema _schema;
  final PostgreSQLDatabaseConnection _connection;

  PostgreSQLDatabaseMigrator(this._schema, this._connection);

  @override
  Future<void> addField(
      BaseDataBean bean, DataField field, dynamic initialValue) async {
    await _connection.execute(AddFieldBuilder(
        _schema.name, bean.layoutName, field,
        initialValue: initialValue));
  }

  @override
  Future<void> addLayout(BaseDataBean bean) async {
    await _connection.execute(CreateTableBuilder.fromLayout(_schema, bean));
  }

  @override
  Future<void> removeField(BaseDataBean bean, String fieldName) async {
    await _connection
        .execute(RemoveFieldBuilder(_schema.name, bean.layoutName, fieldName));
  }

  @override
  Future<void> removeLayout(String name) async {
    await _connection.execute(RemoveTableBuilder(_schema.name, name));
  }

  @override
  Future<void> customSql(String sql) async {
    await _connection.execute(RawSql(sql));
  }
}
