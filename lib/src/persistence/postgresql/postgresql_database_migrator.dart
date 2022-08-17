import 'package:datahub/datahub.dart';
import 'package:datahub/src/persistence/postgresql/postgresql_database_context.dart';

import 'sql/sql.dart';

class PostgreSQLDatabaseMigrator extends Migrator {
  final DataSchema _schema;
  final PostgreSQLDatabaseContext _context;

  PostgreSQLDatabaseMigrator(this._schema, this._context);

  @override
  Future<void> addField(
      DataBean bean, DataField field, dynamic initialValue) async {
    await _context.execute(AddFieldBuilder(_schema.name, bean.layoutName, field,
        initialValue: initialValue));
  }

  @override
  Future<void> addLayout(DataBean bean) async {
    await _context.execute(CreateTableBuilder.fromLayout(_schema, bean));
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
