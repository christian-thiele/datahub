import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/types.dart';

import 'sql_qualified_relation.dart';
import 'sql_attribute.dart';
import 'sql.dart';

class SqlSelect implements SqlBuilder {
  final SqlQualifiedRelation from;
  final List<SqlAttribute> attributes;
  final int offset;
  final int limit;
  final Sql? where;

  SqlSelect(
    this.from,
    this.attributes, {
    this.offset = 0,
    this.limit = -1,
    this.where,
  });

  @override
  Sql toSql() {
    return Sql.combine([
      Sql('SELECT ${attributes.join(', ')} FROM $from'),
      if (where case final where?) ...[
        Sql(' WHERE '),
        where,
      ],
      if (offset != 0) ...[
        Sql(' OFFSET '),
        Sql.param(offset, PostgresqlInt()),
      ],
      if (limit != -1) ...[
        Sql(' LIMIT '),
        Sql.param(limit, PostgresqlInt()),
      ],
    ]);
  }
}
