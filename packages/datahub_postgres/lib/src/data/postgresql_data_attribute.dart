import 'package:datahub/data.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/src/types/types.dart';

import 'data_utils.dart';

class PostgresqlDataAttribute<T> extends PostgresqlAttribute {
  final DataField<T, dynamic> field;

  PostgresqlDataAttribute._({
    required this.field,
    required super.name,
    required super.type,
    super.constraints,
  });

  factory PostgresqlDataAttribute(DataField<T, dynamic> field) {
    // TODO read postgres meta annotations to override default behavior
    final isId = field.meta.any((e) => e is Id);
    final type = PostgresqlDataType.findForType(field.type);
    return PostgresqlDataAttribute._(
      field: field,
      name: translateName(field.name),
      type: type,
      constraints: [
        if (isId) PrimaryKeyConstraint(auto: type.type.isExact<int>()),
        if (field is DataField<T, Object>) NotNullConstraint(),
      ],
    );
  }
}
