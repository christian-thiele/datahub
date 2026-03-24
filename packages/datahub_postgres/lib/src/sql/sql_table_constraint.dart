import 'package:boost/boost.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';

class SqlTableConstraint {
  final PostgresqlTableConstraint constraint;

  SqlTableConstraint(this.constraint);

  Sql toSql() {
    return switch (constraint) {
      UniqueTableConstraint(:final nullsNotDistinct, :final attributes) =>
        Sql.join([
          RawSql('UNIQUE '),
          if (nullsNotDistinct) RawSql('NULLS NOT DISTINCT '),
          RawSql('('),
          ...attributes
              .map((a) => RawSql(Sql.escapeName(a.name)))
              .separatedBy(RawSql(',')),
          RawSql(')'),
        ]),
    };
  }
}
