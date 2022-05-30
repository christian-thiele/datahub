import 'package:cl_datahub/cl_datahub.dart';

abstract class SelectFrom {
  String get sql;
}

class SelectFromTable extends SelectFrom {
  final String schemaName;
  final String tableName;

  SelectFromTable(this.schemaName, this.tableName);

  @override
  String get sql => '$schemaName.$tableName';
}

class TableJoin {
  final SelectFromTable table;
  final String onMainField;
  final PropertyCompareType onCompare;
  final String onJoinField;

  TableJoin(this.table, this.onMainField, this.onCompare, this.onJoinField);

  String getJoinSql(SelectFromTable main) => ' JOIN ${table.sql} ON '
      '${main.sql}.$onMainField $_compareSql ${table.sql}.$onJoinField';

  //TODO use filterSql here instead to allow more complex joins
  String get _compareSql {
    switch (onCompare) {
      case PropertyCompareType.Equals:
        return '=';
      case PropertyCompareType.NotEquals:
        return '<>';
      case PropertyCompareType.LessThan:
        return '<';
      case PropertyCompareType.LessOrEqual:
        return '<=';
      case PropertyCompareType.GreaterThan:
        return '>';
      case PropertyCompareType.GreaterOrEqual:
        return '>=';
      case PropertyCompareType.In:
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