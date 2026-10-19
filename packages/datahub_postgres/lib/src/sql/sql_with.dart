import 'package:boost/boost.dart';

import 'sql.dart';

/// A named common table expression inside a [SqlWith] statement.
class const SqlCte(final String name, final Sql statement);

class const SqlWith(final List<SqlCte> ctes, final Sql body) with SqlBuilder {
  @override
  Sql toSql() => Sql.join([
    const RawSql('WITH '),
    ...ctes
        .map(
          (e) => Sql.name(e.name) + const RawSql(' AS ') + e.statement.wrap(),
        )
        .separatedBy(const RawSql(', ')),
    const RawSql(' '),
    body,
  ]);
}
