import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/src/types/types.dart';

class SqlAttributeConstraint {
  final PostgresqlAttribute attribute;
  final PostgresqlAttributeConstraint constraint;

  SqlAttributeConstraint(this.attribute, this.constraint);

  Sql toSql() {
    return switch (constraint) {
      NotNullConstraint() => Sql('NOT NULL'),
      PrimaryKeyConstraint(:final auto) => Sql.ofSegments([
          SqlTextSegment('PRIMARY KEY'),
          if (auto &&
              (attribute.type is PostgresqlInt ||
                  attribute.type is PostgresqlSerial))
            SqlTextSegment(' GENERATED ALWAYS AS IDENTITY'),
          if (auto && attribute.type is PostgresqlString)
            SqlTextSegment(' DEFAULT gen_random_uuid()'),
        ]),
      UniqueConstraint() => Sql('UNIQUE'),
      DefaultConstraint(:final value, :final type) => Sql.ofSegments([
          SqlTextSegment('DEFAULT '),
          SqlParamSegment(value, type),
        ]),
    };
  }
}
