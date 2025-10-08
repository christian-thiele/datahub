import 'package:datahub/data.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/schema.dart';

import 'data_utils.dart';

class PostgresqlDataAttribute extends PostgresqlAttribute {
  final DataField field;

  PostgresqlDataAttribute({
    required this.field,
    required super.name,
    required super.type,
    super.constraints,
  });

  factory PostgresqlDataAttribute.fromField(DataField field) {
    // TODO read postgres meta annotations to override default behavior
    final type = PostgresqlDataType.findForDataField(field);
    return PostgresqlDataAttribute(
      field: field,
      name: toNamingConvention(field.name, NamingConvention.lowerSnakeCase),
      type: type,
      constraints: [
        if (field.hasMetaOfType<Id>())
          PrimaryKeyConstraint(auto: field.hasMetaOfType<Id>((id) => id.auto)),
        if (field is DataField<dynamic, Object>) NotNullConstraint(),
      ],
    );
  }

  bool hasConstraint<T extends PostgresqlAttributeConstraint>([
    bool Function(T)? test,
  ]) {
    return constraints.whereType<T>().where(test ?? (_) => true).isNotEmpty;
  }
}
