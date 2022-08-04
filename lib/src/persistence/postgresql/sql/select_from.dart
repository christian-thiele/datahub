import 'package:datahub/datahub.dart';
import 'package:datahub/src/persistence/postgresql/sql/sql.dart';

abstract class SelectFrom {
  String get sql;

  static SelectFrom fromQuerySource(String schemaName, QuerySource source) {
    if (source is BaseDataBean) {
      return SelectFromTable(schemaName, source.layoutName);
    } else if (source is JoinedQuerySource) {
      return JoinedSelectFrom(
        SelectFromTable(schemaName, source.main.layoutName),
        source.joins
            .map((e) => TableJoin(
                  SelectFromTable(schemaName, e.bean.layoutName),
                  e.mainField.name,
                  e.type,
                  e.beanField.name,
                ))
            .toList(),
      );
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
  String get sql => '"$schemaName"."$tableName"';
}

class TableJoin {
  final SelectFromTable table;
  final String onMainField;
  final CompareType onCompare;
  final String onJoinField;

  TableJoin(this.table, this.onMainField, this.onCompare, this.onJoinField);

  String getJoinSql(SelectFromTable main) => ' JOIN ${table.sql} ON '
      '${main.sql}.${SqlBuilder.escapeName(onMainField)} $_compareSql '
      '${table.sql}.${SqlBuilder.escapeName(onJoinField)}';

  //TODO use filterSql here instead to allow more complex joins
  String get _compareSql {
    switch (onCompare) {
      case CompareType.equals:
        return '=';
      case CompareType.notEquals:
        return '<>';
      case CompareType.lessThan:
        return '<';
      case CompareType.lessOrEqual:
        return '<=';
      case CompareType.greaterThan:
        return '>';
      case CompareType.greaterOrEqual:
        return '>=';
      case CompareType.isIn:
        return 'in';
      default:
        throw Exception('Invalid join compare type: $onCompare');
    }
  }
}

class JoinedSelectFrom extends SelectFrom {
  final SelectFromTable main;
  final List<TableJoin> joins;

  JoinedSelectFrom(this.main, this.joins);

  @override
  String get sql {
    return main.sql + joins.map((j) => j.getJoinSql(main)).join();
  }
}
