import 'package:datahub_postgres/datahub_postgres.dart';

sealed class PostgresqlAttributeConstraint {
  const PostgresqlAttributeConstraint();
}

final class NotNullConstraint extends PostgresqlAttributeConstraint {
  const NotNullConstraint();
}

final class PrimaryKeyConstraint extends PostgresqlAttributeConstraint {
  final bool auto;

  const PrimaryKeyConstraint({this.auto = true});
}

final class UniqueConstraint extends PostgresqlAttributeConstraint {
  const UniqueConstraint();
}

final class DefaultConstraint extends PostgresqlAttributeConstraint {
  final dynamic value;
  final PostgresqlDataType type;

  const DefaultConstraint(this.value, this.type);
}
