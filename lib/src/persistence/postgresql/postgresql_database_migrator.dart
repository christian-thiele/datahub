import 'package:cl_datahub/cl_datahub.dart';
import 'sql/add_field_builder.dart';
import 'sql/create_table_builder.dart';
import 'sql/remove_field_builder.dart';
import 'sql/remove_table_builder.dart';

//TODO test all of this!!!!!
class PostgreSQLDatabaseMigrator extends Migrator {
  final DataSchema _schema;
  final PostgreSQLDatabaseConnection _connection;

  PostgreSQLDatabaseMigrator(this._schema, this._connection);

  @override
  Future<void> addField(
      DataLayout layout, DataField field, dynamic initialValue) async {
    await _connection.execute(AddFieldBuilder(_schema.name, layout.name, field,
        initialValue: initialValue));
  }

  @override
  Future<void> addLayout(DataLayout layout) async {
    await _connection.execute(CreateTableBuilder.fromLayout(_schema, layout));
  }

  @override
  Future<void> removeField(DataLayout layout, String fieldName) async {
    await _connection
        .execute(RemoveFieldBuilder(_schema.name, layout.name, fieldName));
  }

  @override
  Future<void> removeLayout(String name) async {
    await _connection.execute(RemoveTableBuilder(_schema.name, name));
  }
}
