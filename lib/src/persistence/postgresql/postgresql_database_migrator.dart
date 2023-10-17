import 'package:datahub/persistence.dart';
import 'package:datahub/postgresql.dart';
import 'package:datahub/src/persistence/postgresql/postgresql_database_context.dart';

import 'sql/sql.dart';

class PostgreSQLDatabaseMigrator extends Migrator {
  final PostgreSQLDatabaseAdapter adapter;
  final DataSchema _schema;
  final PostgreSQLDatabaseContext _context;

  PostgreSQLDatabaseMigrator(this.adapter, this._schema, this._context);

  @override
  Future<void> addField(
      DataBean bean, DataField field, Expression initialValue) async {
    final type = adapter.findType(field.type);

    await _context.execute(AddFieldBuilder(
      _schema.name,
      bean.layoutName,
      field,
      type,
      initialValue,
    ));
  }

  @override
  Future<void> addLayout(DataBean bean) async {
    await _context.execute(CreateTableBuilder.fromLayout(adapter, _schema, bean));
  }

  @override
  Future<void> removeField(DataBean bean, String fieldName) async {
    await _context
        .execute(RemoveFieldBuilder(_schema.name, bean.layoutName, fieldName));
  }

  @override
  Future<void> removeLayout(String name) async {
    await _context.execute(RemoveTableBuilder(_schema.name, name));
  }

  @override
  Future<void> customSql(String sql) async {
    await _context.execute(RawSql(sql));
  }
}
