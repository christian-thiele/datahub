import 'package:boost/boost.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/src/sql/sql_attribute_constraint.dart';

import 'sql.dart';

class SqlAttributeDeclaration(final PostgresqlAttribute attribute) {
  Sql toSql() {
    return Sql.join([
      RawSql('${Sql.escapeName(attribute.name)} ${attribute.type.name}'),
      if (attribute.constraints.isNotEmpty) const RawSql(' '),
      ...attribute.constraints
          .map((e) => SqlAttributeConstraint(attribute, e).toSql())
          .separatedBy(const RawSql(' ')),
    ]);
  }
}
