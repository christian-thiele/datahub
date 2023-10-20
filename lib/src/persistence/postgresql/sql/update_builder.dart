import 'package:datahub/persistence.dart';
import '../type_registry.dart';

import 'param_sql.dart';
import 'select_from.dart';
import 'sql_builder.dart';

class UpdateBuilder extends SqlBuilder {
  final TypeRegistry typeRegistry;

  final SelectFrom from;
  final Map<DataField, dynamic> _values = {};
  Filter _filter = Filter.empty;

  UpdateBuilder(this.typeRegistry, this.from);

  void values(Map<DataField, dynamic> entryValues) {
    _values.addAll(entryValues);
  }

  void where(Filter filter) {
    _filter = filter;
  }

  @override
  ParamSql buildSql() {
    final sql = ParamSql('UPDATE ');
    final values = _values.entries.map((e) {
      final fieldName = SqlBuilder.escapeName(e.key.name);
      final type = typeRegistry.findType(e.key);
      final value = type.toPostgresValue(e.key, e.value);
      final sql = ParamSql('$fieldName = ');
      sql.add(value);
      return sql;
    }).toList();

    sql.add(from.buildSql());
    sql.addSql(' SET ');
    sql.add(values.joinSql(', '));

    if (!_filter.isEmpty) {
      sql.addSql(' WHERE ');
      sql.add(SqlBuilder.filterSql(_filter));
    }

    return sql;
  }
}
