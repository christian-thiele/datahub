import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';

class SqlAttributeConstraint {
  final PostgresqlAttribute attribute;
  final PostgresqlAttributeConstraint constraint;

  SqlAttributeConstraint(this.attribute, this.constraint);

  Sql toSql() {
    return switch (constraint) {
      NotNullConstraint() => RawSql('NOT NULL'),
      // an explicit DEFAULT replaces the built-in generation of auto keys
      PrimaryKeyConstraint(:final auto) => Sql.join([
        RawSql('PRIMARY KEY'),
        if (auto && !attribute.hasConstraint<DefaultConstraint>()) ...[
          if (attribute.type is PostgresqlInt ||
              attribute.type is PostgresqlSerial)
            RawSql(' GENERATED ALWAYS AS IDENTITY'),
          if (attribute.type is PostgresqlString)
            RawSql(' DEFAULT gen_random_uuid()'),
        ],
      ]),
      UniqueConstraint() => RawSql('UNIQUE'),
      DefaultConstraint(:final value) => Sql.join([RawSql('DEFAULT '), value]),
    };
  }
}
