import 'package:datahub/data.dart';
import 'package:datahub_postgres/schema.dart';

import 'data_utils.dart';

class PostgresqlDataAttribute extends PostgresqlAttribute {
  final DataField field;

  PostgresqlDataAttribute._({
    required this.field,
    required super.name,
    required super.type,
    super.constraints,
  });

  factory PostgresqlDataAttribute(DataField field) {
    // TODO read postgres meta annotations to override default behavior
    final type = PostgresqlDataType.findForDataField(field);
    return PostgresqlDataAttribute._(
      field: field,
      name: translateName(field.name),
      type: type,
      constraints: [
        if (field.hasMetaOfType<Id>())
          PrimaryKeyConstraint(
            auto: field.hasMetaOfType<Id>((id) => id.auto),
          ),
        if (field is DataField<dynamic, Object>) NotNullConstraint(),
      ],
    );
  }

  bool hasConstraint<T extends PostgresqlAttributeConstraint>(
      [bool Function(T)? test]) {
    return constraints.whereType<T>().where(test ?? (_) => true).isNotEmpty;
  }
}
