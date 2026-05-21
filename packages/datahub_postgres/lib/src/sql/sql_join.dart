import 'package:datahub_postgres/src/sql/sql.dart';

import 'sql_select.dart';

enum SqlJoinType { left, right, inner, cross, full }

class SqlJoin with SqlBuilder {
  final SqlSelectTarget left;
  final SqlSelectTarget right;
  final SqlJoinType type;
  final Sql? on;

  SqlJoin({
    required this.left,
    required this.right,
    this.on,
    this.type = SqlJoinType.inner,
  });

  @override
  Sql toSql() =>
      Sql.join([left, _joinSql(), right, if (on != null) RawSql(' ON '), ?on]);

  Sql _joinSql() => switch (type) {
    SqlJoinType.left => RawSql(' LEFT JOIN '),
    SqlJoinType.right => RawSql(' RIGHT JOIN '),
    SqlJoinType.inner => RawSql(' INNER JOIN '),
    SqlJoinType.cross => RawSql(' CROSS JOIN '),
    SqlJoinType.full => RawSql(' FULL JOIN '),
  };
}
