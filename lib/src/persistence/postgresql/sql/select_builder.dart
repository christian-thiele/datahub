import 'package:datahub/persistence.dart';

import 'param_sql.dart';
import 'select_from.dart';
import 'sql_builder.dart';

class SelectBuilder implements SqlBuilder {
  final SelectFrom from;
  Filter _filter = Filter.empty;
  Sort _sort = Sort.empty;
  List<QuerySelect>? _select;
  List<QuerySelect>? _distinct;
  List<Expression>? _group;
  int _limit = -1;
  int _offset = 0;
  bool _forUpdate = false;

  SelectBuilder(this.from);

  void select(List<QuerySelect> selections) {
    _select = selections;
  }

  void distinct(List<QuerySelect>? distinct) {
    _distinct = distinct;
  }

  void offset(int value) {
    _offset = value;
  }

  void limit(int value) {
    _limit = value;
  }

  void where(Filter filter) {
    _filter = filter;
  }

  void orderBy(Sort sort) {
    _sort = sort;
  }

  void groupBy(List<Expression> group) {
    _group = group;
  }

  void forUpdate(bool value) {
    _forUpdate = value;
  }

  @override
  ParamSql buildSql() {
    final sql = ParamSql('SELECT ');

    if (_distinct?.isNotEmpty ?? false) {
      sql.addSql('DISTINCT ON ');
      final selectResults = _distinct!.map((s) => SqlBuilder.selectSql(s));
      sql.add(selectResults.joinSql(', ')..wrap());
      sql.addSql(' ');
    }

    if (_select?.isNotEmpty ?? false) {
      final selectResults = _select!.map((s) => SqlBuilder.selectSql(s));
      sql.add(selectResults.joinSql(', '));
      sql.addSql(' ');
    } else {
      sql.addSql('* ');
    }

    sql.addSql('FROM ');
    sql.add(from.buildSql());

    if (!_filter.isEmpty) {
      sql.addSql(' WHERE ');
      sql.add(SqlBuilder.filterSql(_filter));
    }

    if (_group?.isNotEmpty ?? false) {
      sql.addSql(' GROUP BY ');
      final groupResults = _group!.map((s) => SqlBuilder.expressionSql(s));
      sql.add(groupResults.joinSql(', '));
    }

    if (!_sort.isEmpty) {
      sql.addSql(' ORDER BY ');
      sql.add(SqlBuilder.sortSql(_sort));
    }

    if (_offset > 0) {
      sql.addSql(' OFFSET $_offset');
    }

    if (_limit > -1) {
      sql.addSql(' LIMIT $_limit');
    }

    if (_forUpdate) {
      sql.addSql(' FOR UPDATE');
    }

    return sql;
  }
}
