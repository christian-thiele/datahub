import 'package:datahub/datahub.dart';
import 'package:datahub/src/persistence/postgresql/postgresql_database_context.dart';

import 'sql/sql.dart';

class PostgreSQLDatabaseMigrator extends Migrator {
  final DataSchema _schema;
  final PostgreSQLDatabaseContext _context;

  PostgreSQLDatabaseMigrator(this._schema, this._context);

  @override
  Future<void> addField(
      BaseDataBean bean, DataField field, dynamic initialValue) async {
    await _context.execute(AddFieldBuilder(_schema.name, bean.layoutName, field,
        initialValue: initialValue));
  }

  @override
  Future<void> addLayout(BaseDataBean bean) async {
    await _context.execute(CreateTableBuilder.fromLayout(_schema, bean));
  }

  @override
  Future<void> removeField(BaseDataBean bean, String fieldName) async {
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
