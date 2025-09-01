import 'package:datahub/data.dart';
import 'package:datahub_postgres/schema.dart';

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
    final isId = field.meta.any((e) => e is Id);
    return PostgresqlDataAttribute._(
      field: field,
      name: translateName(field.name),
      type: switch (field) {
        DataField<dynamic, int?>() =>
          isId ? PostgresqlDataType.bigSerial : PostgresqlDataType.bigInt,
        DataField<dynamic, String?>() => PostgresqlDataType.varChar,
        DataField<dynamic, double?>() => PostgresqlDataType.doublePrecision,
        DataField<dynamic, bool?>() => PostgresqlDataType.boolean,
        DataField<dynamic, DateTime?>() => PostgresqlDataType.timestamp,
        DataField<dynamic, dynamic>() => PostgresqlDataType.jsonb,
      },
      constraints: [
        if (isId) PrimaryKeyConstraint(),
        if (field is DataField<T, Object>) NotNullConstraint(),
      ],
    );
  }
}
