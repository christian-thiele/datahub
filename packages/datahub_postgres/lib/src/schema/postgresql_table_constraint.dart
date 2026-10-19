import 'postgresql_attribute.dart';

sealed class const PostgresqlTableConstraint();

final class const UniqueTableConstraint({
  required final List<PostgresqlAttribute> attributes,
  final bool nullsNotDistinct = false,
}) extends PostgresqlTableConstraint;

final class const PrimaryKeyTableConstraint({
  required final List<PostgresqlAttribute> attributes,
}) extends PostgresqlTableConstraint;
