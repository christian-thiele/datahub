import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/src/sql/sql_attribute_constraint.dart';

import 'sql.dart';

class SqlAttributeDeclaration {
  final PostgresqlAttribute attribute;

  SqlAttributeDeclaration(this.attribute);

  Sql toSql() {
    return Sql.combine([
      Sql('${Sql.escapeName(attribute.name)} ${attribute.type.name}'),
      if (attribute.constraints.isNotEmpty) Sql(' '),
      attribute.constraints
          .map((e) => SqlAttributeConstraint(attribute, e).toSql())
          .joinSql(' '),
    ]);
  }
}
