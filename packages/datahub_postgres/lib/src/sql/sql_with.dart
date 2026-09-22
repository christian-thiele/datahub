import 'package:boost/boost.dart';

import 'sql.dart';

/// A named common table expression inside a [SqlWith] statement.
class SqlCte {
  final String name;
  final Sql statement;

  const SqlCte(this.name, this.statement);
}

class SqlWith with SqlBuilder {
  final List<SqlCte> ctes;
  final Sql body;

  const SqlWith(this.ctes, this.body);

  @override
  Sql toSql() => Sql.join([
    RawSql('WITH '),
    ...ctes
        .map((e) => Sql.name(e.name) + RawSql(' AS ') + e.statement.wrap())
        .separatedBy(RawSql(', ')),
    RawSql(' '),
    body,
  ]);
}
