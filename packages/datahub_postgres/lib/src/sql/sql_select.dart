import 'package:datahub_postgres/types.dart';

import 'sql_attribute.dart';
import 'sql.dart';

abstract class SqlSelectTarget {
  String get name;
  Sql toSql();
}

class SqlNestedSelect implements SqlSelectTarget {
  @override
  final String name;
  final SqlSelect select;

  SqlNestedSelect({
    required this.name,
    required this.select,
  });

  @override
  Sql toSql() => Sql.combine(
        [
          select.toSql()..wrap(),
          Sql(' '),
          Sql.name(name),
        ],
      );
}

class SqlSelect implements SqlBuilder {
  final SqlSelectTarget from;
  final List<SqlAttribute> attributes;
  final SqlAttribute? distinctOn;
  final int offset;
  final int limit;
  final Sql? where;
  final Sql? order;

  SqlSelect(
    this.from,
    this.attributes, {
    this.distinctOn,
    this.offset = 0,
    this.limit = -1,
    this.where,
    this.order,
  });

  @override
  Sql toSql() {
    return Sql.combine([
      Sql('SELECT'),
      if (distinctOn != null) ...[
        Sql(' DISTINCT ON ('),
        distinctOn!.toSql(),
        Sql(')')
      ],
      Sql(' ${attributes.map((e) => e.toSql()).joinSql(', ')} FROM '),
      from.toSql(),
      if (where case final where?) ...[
        Sql(' WHERE '),
        where,
      ],
      if (order case final order?) ...[
        Sql(' ORDER BY '),
        order,
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
