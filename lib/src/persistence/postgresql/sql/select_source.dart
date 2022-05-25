import 'package:cl_datahub/cl_datahub.dart';

abstract class SelectSource {
  String get sql;
}

class TableSelectSource extends SelectSource {
  final String schemaName;
  final String tableName;

  TableSelectSource(this.schemaName, this.tableName);

  @override
  String get sql => '$schemaName.$tableName';
}

class TableJoin {
  final TableSelectSource table;
  final String onMainField;
  final PropertyCompareType onCompare;
  final String onJoinField;

  TableJoin(this.table, this.onMainField, this.onCompare, this.onJoinField);

  String getJoinSql(TableSelectSource main) => ' JOIN ${table.sql} ON '
      '${main.sql}.$onMainField $_compareSql ${table.sql}.$onJoinField';

  //TODO use filterSql here instead to allow more complex joins
  String get _compareSql {
    switch (onCompare) {
      case PropertyCompareType.Equals:
        return '=';
      case PropertyCompareType.NotEquals:
        return '<>';
      default:
        throw Exception('Invalid join compare type: $onCompare');
    }
  }
}

class JoinedSelectSource extends SelectSource {
  final TableSelectSource main;
  final List<TableJoin> joins;

  JoinedSelectSource(this.main, this.joins);

  @override
  String get sql {
    return main.sql + joins.map((j) => j.getJoinSql(main)).join();
  }
}