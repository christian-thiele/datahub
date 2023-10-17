import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/src/persistence/postgresql/type_registry.dart';

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
  Tuple<String, Map<String, dynamic>> buildSql() {
    final buffer = StringBuffer();
    final values = _values.entries.map((e) {
      final fieldName = SqlBuilder.escapeName(e.key.name);
      final type = typeRegistry.findType(e.key.type);
      final value = type.toPostgresValue(e.value);
      return Tuple(fieldName, value);
    }).toList();

    buffer.write('UPDATE ');
    final fromSql = from.buildSql();
    buffer.write(fromSql.a);
    buffer.write(' SET ');
    buffer.write(values.map((e) => '${e.a} = ${e.b}').join(', '));

    final substitutionValues = <String, dynamic>{};

    if (!_filter.isEmpty) {
      buffer.write(' WHERE ');

      final filterResult = SqlBuilder.filterSql(_filter);
      buffer.write(filterResult.a);
      substitutionValues.addAll(filterResult.b);
    }

    return Tuple(buffer.toString(),
        substitutionValues.map((k, v) => MapEntry(k, SqlBuilder.toSqlData(v))));
  }
}
