import 'package:datahub_postgres/src/sql/sql.dart';

import 'sql_select.dart';

enum SqlJoinType() {
  left,
  right,
  inner,
  cross,
  full,
}

class SqlJoin({
  required final SqlSelectTarget left,
  required final SqlSelectTarget right,
  final Sql? on,
  final SqlJoinType type = SqlJoinType.inner,
}) with SqlBuilder {
  @override
  Sql toSql() => Sql.join([
    left,
    _joinSql(),
    right,
    if (on != null) const RawSql(' ON '),
    ?on,
  ]);

  Sql _joinSql() => switch (type) {
    SqlJoinType.left => const RawSql(' LEFT JOIN '),
    SqlJoinType.right => const RawSql(' RIGHT JOIN '),
    SqlJoinType.inner => const RawSql(' INNER JOIN '),
    SqlJoinType.cross => const RawSql(' CROSS JOIN '),
    SqlJoinType.full => const RawSql(' FULL JOIN '),
  };
}
