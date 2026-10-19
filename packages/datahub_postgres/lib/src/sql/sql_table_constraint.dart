import 'package:boost/boost.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';

class SqlTableConstraint(final PostgresqlTableConstraint constraint) {
  Sql toSql() {
    return switch (constraint) {
      UniqueTableConstraint(:final nullsNotDistinct, :final attributes) =>
        Sql.join([
          const RawSql('UNIQUE '),
          if (nullsNotDistinct) const RawSql('NULLS NOT DISTINCT '),
          _attributeList(attributes),
        ]),
      PrimaryKeyTableConstraint(:final attributes) => Sql.join([
        const RawSql('PRIMARY KEY '),
        _attributeList(attributes),
      ]),
    };
  }

  Sql _attributeList(List<PostgresqlAttribute> attributes) => Sql.join([
    const RawSql('('),
    ...attributes
        .map((a) => RawSql(Sql.escapeName(a.name)))
        .separatedBy(const RawSql(',')),
    const RawSql(')'),
  ]);
}
