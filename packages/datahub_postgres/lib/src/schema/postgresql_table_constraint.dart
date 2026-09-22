import 'postgresql_attribute.dart';

sealed class PostgresqlTableConstraint {
  const PostgresqlTableConstraint();
}

final class UniqueTableConstraint extends PostgresqlTableConstraint {
  final List<PostgresqlAttribute> attributes;
  final bool nullsNotDistinct;

  const UniqueTableConstraint({
    required this.attributes,
    this.nullsNotDistinct = false,
  });
}

final class PrimaryKeyTableConstraint extends PostgresqlTableConstraint {
  final List<PostgresqlAttribute> attributes;

  const PrimaryKeyTableConstraint({required this.attributes});
}
