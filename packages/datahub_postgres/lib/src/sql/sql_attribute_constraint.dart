import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';

class SqlAttributeConstraint(
  final PostgresqlAttribute attribute,
  final PostgresqlAttributeConstraint constraint,
) {
  Sql toSql() {
    return switch (constraint) {
      NotNullConstraint() => const RawSql('NOT NULL'),
      // an explicit DEFAULT replaces the built-in generation of auto keys
      PrimaryKeyConstraint(:final auto) => Sql.join([
        const RawSql('PRIMARY KEY'),
        if (auto && !attribute.hasConstraint<DefaultConstraint>()) ...[
          if (attribute.type is PostgresqlInt ||
              attribute.type is PostgresqlSerial)
            const RawSql(' GENERATED ALWAYS AS IDENTITY'),
          if (attribute.type is PostgresqlString)
            const RawSql(' DEFAULT gen_random_uuid()'),
        ],
      ]),
      UniqueConstraint() => const RawSql('UNIQUE'),
      DefaultConstraint(:final value) => Sql.join([
        const RawSql('DEFAULT '),
        value,
      ]),
    };
  }
}
