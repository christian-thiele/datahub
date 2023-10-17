import 'package:boost/boost.dart';
import 'package:datahub/persistence.dart';

import 'package:datahub/src/persistence/postgresql/sql/sql.dart';

import 'param_sql.dart';

abstract class SelectFrom {
  ParamSql buildSql();

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
  ParamSql buildSql() => ParamSql('"$schemaName"."$tableName"');
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

  ParamSql getJoinSql(SelectFromTable main) {
    final joinType = '${innerJoin ? '' : 'LEFT '}JOIN';
    final sql = ParamSql(' $joinType ');
    sql.add(table.buildSql());
    sql.addSql(' ON ');
    sql.add(SqlBuilder.filterSql(filter));
    return sql;
  }
}

class JoinedSelectFrom extends SelectFrom {
  final SelectFromTable main;
  final List<TableJoin> joins;

  JoinedSelectFrom(this.main, this.joins);

  @override
  ParamSql buildSql() {
    return ParamSql.combine([
      main.buildSql(),
      ...joins.map((j) => j.getJoinSql(main)),
    ]);
  }
}

class SelectFromSubQuery extends SelectFrom {
  final String schemaName;
  final SubQuery query;

  SelectFromSubQuery(this.schemaName, this.query);

  ParamSql buildSelect() {
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
  ParamSql buildSql() {
    final select = buildSelect();
    final sql = ParamSql('(');
    sql.add(select);
    sql.addSql(') ${SqlBuilder.escapeName(query.alias)}');
    return sql;
  }
}
