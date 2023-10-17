import 'package:datahub/persistence.dart';
import 'package:datahub/postgresql.dart';

import 'postgresql_database_context.dart';

import 'sql/param_sql.dart';
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
    final builder = AddFieldBuilder(
      _schema.name,
      bean.layoutName,
      field,
      type,
      initialValue,
    );
    await _context.execute(builder.buildSql());
  }

  @override
  Future<void> addLayout(DataBean bean) async {
    final builder = CreateTableBuilder.fromLayout(adapter, _schema, bean);
    await _context.execute(builder.buildSql());
  }

  @override
  Future<void> removeField(DataBean bean, String fieldName) async {
    final builder =
        RemoveFieldBuilder(_schema.name, bean.layoutName, fieldName);
    await _context.execute(builder.buildSql());
  }

  @override
  Future<void> removeLayout(String name) async {
    final builder = RemoveTableBuilder(_schema.name, name);
    await _context.execute(builder.buildSql());
  }

  @override
  Future<void> customSql(String sql) async {
    await _context.execute(ParamSql(sql));
  }
}
