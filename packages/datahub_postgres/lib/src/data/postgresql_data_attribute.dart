import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/types.dart';

class PostgresqlDataAttribute({
  required final DataField field,
  required super.name,
  required super.type,
  super.constraints,
}) extends PostgresqlAttribute {
  /// Builds a column definition for [field].
  ///
  /// [PostgresqlAttributeConstraint] annotations on the field are applied
  /// as given. Additionally a [PrimaryKeyConstraint] is derived from an [Id]
  /// annotation and a [NotNullConstraint] from a non-nullable field type,
  /// unless a constraint of the same kind is already annotated explicitly.
  factory fromField(DataField field) {
    final type = PostgresqlDataType.findForDataField(field);
    final annotated = field
        .allMetaOfType<PostgresqlAttributeConstraint>()
        .toList(growable: false);
    final hasPrimaryKey = annotated.any((e) => e is PrimaryKeyConstraint);
    final hasNotNull = annotated.any((e) => e is NotNullConstraint);
    return PostgresqlDataAttribute(
      field: field,
      name: toNamingConvention(field.name, NamingConvention.lowerSnakeCase),
      type: type,
      constraints: [
        ...annotated,
        if (!hasPrimaryKey && field.hasMetaOfType<Id>())
          PrimaryKeyConstraint(auto: field.hasMetaOfType<Id>((id) => id.auto)),
        if (!hasNotNull && field is DataField<dynamic, Object>)
          const NotNullConstraint(),
      ],
    );
  }
}
