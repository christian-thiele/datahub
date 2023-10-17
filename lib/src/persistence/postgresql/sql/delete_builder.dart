import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';

import 'param_sql.dart';
import 'select_from.dart';
import 'sql_builder.dart';

class DeleteBuilder implements SqlBuilder {
  final SelectFrom from;
  Filter _filter = Filter.empty;

  DeleteBuilder(this.from);

  void where(Filter filter) {
    _filter = filter;
  }

  @override
  ParamSql buildSql() {
    final sql = ParamSql('DELETE FROM ');
    sql.add(from.buildSql());

    if (!_filter.isEmpty) {
      sql.addSql(' WHERE ');
      sql.add(SqlBuilder.filterSql(_filter));
    }

    return sql;
  }
}
