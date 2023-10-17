import 'package:boost/boost.dart';
import 'package:postgres/postgres.dart';
import 'package:postgres/postgres_v3_experimental.dart';

class ParamSql {
  final List<SqlSegment> segments;

  ParamSql.ofSegments(this.segments);

  static ParamSql param<T extends Object>(T? value, PgDataType<T> type) =>
      ParamSql.ofSegments([SqlParamSegment(value, type)]);

  ParamSql.combine(List<ParamSql> elements)
      : segments = elements.expand((e) => e.segments).toList();

  ParamSql(String sql)
      : this.ofSegments([if (sql.isNotEmpty) SqlTextSegment(sql)]);

  void add(ParamSql sql) {}

  void addSegment(SqlSegment segment) => segments.add(segment);

  void addSql(String sql) => segments.add(SqlTextSegment(sql));

  void wrap() {
    segments.insert(0, SqlTextSegment('('));
    segments.add(SqlTextSegment(')'));
  }

  ParamSql operator +(ParamSql sql) =>
      ParamSql.ofSegments([...segments, ...sql.segments]);

  @override
  String toString() {
    var paramId = 0;
    return segments.map((e) {
      if (e is SqlTextSegment) {
        return e.text;
      } else if (e is SqlParamSegment) {
        final type = PostgreSQLFormat.dataTypeStringForDataType(e.type);
        if (type != null) {
          return '@${++paramId}:$type';
        } else {
          return '@${++paramId}';
        }
      }
      throw Error();
    }).join();
  }

  Map<String, dynamic> getSubstitutionValues() {
    return Map.fromEntries(
      segments
          .whereIs<SqlParamSegment>()
          .mapIndexed((p0, p1) => MapEntry((p1 + 1).toString(), p0)),
    );
  }

  void addParam(dynamic value, PostgreSQLDataType type) {
    addSegment(SqlParamSegment(value, type));
  }
}

abstract class SqlSegment {}

class SqlTextSegment extends SqlSegment {
  final String text;

  SqlTextSegment(this.text);
}

class SqlParamSegment<T extends Object> extends SqlSegment {
  final T? value;
  final PgDataType<T> type;

  SqlParamSegment(this.value, this.type);
}

extension ParamSqlIterableExtension on Iterable<ParamSql> {
  ParamSql joinSql([String? separator]) {
    final it = iterator;
    if (!it.moveNext()) return ParamSql.ofSegments([]);
    final sql = ParamSql.ofSegments([]);
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
