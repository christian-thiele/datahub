import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';

import 'package:datahub/src/persistence/postgresql/sql/sql.dart';

abstract class SelectFrom {
  Tuple<String, Map<String, dynamic>> buildSql();

  static SelectFrom fromQuerySource(String schemaName, QuerySource source) {
    if (source is DataBean) {
      return SelectFromTable(schemaName, source.layoutName);
    } else if (source is JoinedQuerySource) {
      return JoinedSelectFrom(
        SelectFromTable(
            schemaName, (source as JoinedQuerySource).main.layoutName),
        (source as JoinedQuerySource)
            .joins
            .map(
              (e) => TableJoin(
                SelectFromTable(schemaName, e.bean.layoutName),
                e.filter,
                (source as JoinedQuerySource).innerJoin,
              ),
            )
            .toList(),
      );
    } else if (source is SubQuery) {
      return SelectFromSubQuery(schemaName, source);
    } else {
      throw Exception(
          'PostgreSQL implementation does not support QuerySource of type ${source.runtimeType}.');
    }
  }
}

class SelectFromTable extends SelectFrom {
  final String schemaName;
  final String tableName;

  SelectFromTable(this.schemaName, this.tableName);

  @override
  Tuple<String, Map<String, dynamic>> buildSql() =>
      Tuple('"$schemaName"."$tableName"', const {});
}

class TableJoin {
  final SelectFromTable table;
  final Filter filter;
  final bool innerJoin;

  TableJoin(
    this.table,
    this.filter,
    this.innerJoin,
  );

  Tuple<String, Map<String, dynamic>> getJoinSql(SelectFromTable main) {
    final filterSql = SqlBuilder.filterSql(filter);
    return Tuple(
      ' ${innerJoin ? '' : 'LEFT '}JOIN ${table.buildSql().a} ON '
      '(${filterSql.a})',
      filterSql.b,
    );
  }
}

class JoinedSelectFrom extends SelectFrom {
  final SelectFromTable main;
  final List<TableJoin> joins;

  JoinedSelectFrom(this.main, this.joins);

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    return Tuple(
        main.buildSql().a + joins.map((j) => j.getJoinSql(main).a).join(), {});
  }
}

class SelectFromSubQuery extends SelectFrom {
  final String schemaName;
  final SubQuery query;

  SelectFromSubQuery(this.schemaName, this.query);

  Tuple<String, Map<String, dynamic>> buildSelect() {
    final from = SelectFrom.fromQuerySource(schemaName, query.source);
    return (SelectBuilder(from)
          ..where(query.filter)
          ..orderBy(query.sort)
          ..offset(query.offset)
          ..limit(query.limit)
          ..select(query.select))
        .buildSql();
  }

  @override
  Tuple<String, Map<String, dynamic>> buildSql() {
    final select = buildSelect();
    return Tuple(
      '(${select.a}) ${SqlBuilder.escapeName(query.alias)}',
      select.b,
    );
  }
}
