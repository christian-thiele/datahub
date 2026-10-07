import 'package:datahub/data.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';
import 'package:meta/meta_meta.dart';

/// Column constraint of a [PostgresqlAttribute].
///
/// Constraints can be used as annotations on fields of a [DataObject]
/// class.
@Target({TargetKind.field})
sealed class PostgresqlAttributeConstraint extends MetaData {
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

/// A default attribute constraint.
///
/// A [DefaultConstraint] on a field annotated with `Id(auto: true)` replaces
/// the built-in id generation (identity column, sequence or random uuid),
/// e.g. to derive ids from a custom sequence or function.
final class DefaultConstraint extends PostgresqlAttributeConstraint {
  final Sql value;

  const DefaultConstraint(this.value);
  DefaultConstraint.value(dynamic value, PostgresqlDataType type)
    : this(ParameterSql(value, type));
}
