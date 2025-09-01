import 'package:datahub_postgres/datahub_postgres.dart';

class SqlAttributeConstraint {
  final PostgresqlAttributeConstraint constraint;

  SqlAttributeConstraint(this.constraint);

  Sql toSql() {
    return switch (constraint) {
      NotNullConstraint() => Sql('NOT NULL'),
      PrimaryKeyConstraint(:final auto) => Sql.ofSegments([
          SqlTextSegment('PRIMARY KEY'),
          if (auto) SqlTextSegment(' GENERATED ALWAYS AS IDENTITY'),
        ]),
      UniqueConstraint() => Sql('UNIQUE'),
      DefaultConstraint(:final value, :final type) => Sql.ofSegments([
          SqlTextSegment('DEFAULT '),
          SqlParamSegment(value, type),
        ]),
    };
  }
}
