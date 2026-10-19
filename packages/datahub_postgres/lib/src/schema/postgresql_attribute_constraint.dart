import 'package:datahub/data.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';
import 'package:meta/meta_meta.dart';

/// Column constraint of a [PostgresqlAttribute].
///
/// Constraints can be used as annotations on fields of a [DataObject]
/// class.
@Target({TargetKind.field})
sealed class const PostgresqlAttributeConstraint() extends MetaData;

final class const NotNullConstraint() extends PostgresqlAttributeConstraint;

final class const PrimaryKeyConstraint({final bool auto = true})
    extends PostgresqlAttributeConstraint;

final class const UniqueConstraint() extends PostgresqlAttributeConstraint;

/// A default attribute constraint.
///
/// A [DefaultConstraint] on a field annotated with `Id(auto: true)` replaces
/// the built-in id generation (identity column, sequence or random uuid),
/// e.g. to derive ids from a custom sequence or function.
final class const DefaultConstraint(final Sql value)
    extends PostgresqlAttributeConstraint {
  new value(dynamic value, PostgresqlDataType type)
    : this(ParameterSql(value, type));
}
