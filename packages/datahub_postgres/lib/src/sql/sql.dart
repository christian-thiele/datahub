import 'sql_exception.dart';

import 'package:datahub_postgres/schema.dart';

abstract interface class SqlBuilder {
  Sql toSql();
}

class Sql implements SqlBuilder {
  final List<SqlSegment> segments;

  Sql.ofSegments(this.segments);

  static Sql param<T>(T? value, PostgresqlDataType<T> type) =>
      Sql.ofSegments([SqlParamSegment(value, type)]);

  Sql.combine(Iterable<Sql> elements)
      : segments = elements.expand((e) => e.segments).toList();

  Sql(String sql) : this.ofSegments([if (sql.isNotEmpty) SqlTextSegment(sql)]);

  Sql.name(String name) : this(escapeName(name));
  Sql.qualifiedName(Iterable<String> parts) : this(parts.map(escapeName).join('.'));

  void add(Sql sql) => segments.addAll(sql.segments);

  void addSegment(SqlSegment segment) => segments.add(segment);

  void addSql(String sql) => segments.add(SqlTextSegment(sql));

  void wrap() {
    segments.insert(0, SqlTextSegment('('));
    segments.add(SqlTextSegment(')'));
  }

  Sql operator +(Sql sql) => Sql.ofSegments([...segments, ...sql.segments]);

  @override
  String toString() {
    var paramId = 0;
    return [
      for (final segment in segments)
        switch (segment) {
          SqlTextSegment(:final text) => text,
          SqlParamSegment() => '\$${++paramId}',
        }
    ].join();
  }

  List<PostgresqlDataType> getParameterTypes() {
    return segments.whereType<SqlParamSegment>().map((e) => e.type).toList();
  }

  List<dynamic> getParameters() {
    return segments.whereType<SqlParamSegment>().map((e) => e.value).toList();
  }

  void addParam<T>(T value, PostgresqlDataType<T> type) {
    addSegment(SqlParamSegment<T>(value, type));
  }

  Sql clone() => Sql.ofSegments(segments.toList());

  static String escapeName(String name) {
    if (name.isEmpty || name.length > 128) {
      throw SqlException('Name "$name" has invalid length. '
          '(Must be in range 1 - 128)');
    }

    if (name.contains('"')) {
      //TODO check for more invalid characters
      throw SqlException('Name "$name" contains invalid characters.');
    }

    //TODO check for forbidden names like ANALYZE, BETWEEN, ...

    //TODO check for first letter restriction

    return '"$name"';
  }

  @override
  Sql toSql() => this;
}

sealed class SqlSegment {}

final class SqlTextSegment extends SqlSegment {
  final String text;

  SqlTextSegment(this.text);
}

final class SqlParamSegment<T> extends SqlSegment {
  final T? value;
  final PostgresqlDataType<T> type;

  SqlParamSegment(this.value, this.type);
}

extension ParamSqlIterableExtension on Iterable<Sql> {
  Sql joinSql([String? separator]) {
    final it = iterator;
    final sql = Sql.ofSegments([]);
    if (!it.moveNext()) return sql;
    sql.add(it.current);
    while (it.moveNext()) {
      if (separator?.isNotEmpty == true) {
        sql.addSql(separator!);
      }
      sql.add(it.current);
    }
    return sql;
  }
}
