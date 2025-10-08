import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/src/types/types.dart';

class SqlAttributeConstraint {
  final PostgresqlAttribute attribute;
  final PostgresqlAttributeConstraint constraint;

  SqlAttributeConstraint(this.attribute, this.constraint);

  Sql toSql() {
    return switch (constraint) {
      NotNullConstraint() => RawSql('NOT NULL'),
      PrimaryKeyConstraint(:final auto) => Sql.join([
        RawSql('PRIMARY KEY'),
        if (auto &&
            (attribute.type is PostgresqlInt ||
                attribute.type is PostgresqlSerial))
          RawSql(' GENERATED ALWAYS AS IDENTITY'),
        if (auto && attribute.type is PostgresqlString)
          RawSql(' DEFAULT gen_random_uuid()'),
      ]),
      UniqueConstraint() => RawSql('UNIQUE'),
      DefaultConstraint(:final value) => Sql.join([RawSql('DEFAULT '), value]),
    };
  }
}
