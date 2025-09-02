import 'package:datahub_postgres/schema.dart';

import 'sql.dart';

class SqlAttribute {
  final String? relation;
  final String name;

  const SqlAttribute(this.name, {this.relation});

  Sql toSql() => Sql.qualifiedName([if (relation != null) relation!, name]);
}

class SqlWildcard extends SqlAttribute {
  const SqlWildcard() : super('*');

  @override
  Sql toSql() => Sql('*');
}

class SqlTypedAttribute extends SqlAttribute {
  final PostgresqlDataType type;

  const SqlTypedAttribute(super.name, this.type, {super.relation});

  SqlTypedAttribute.of(PostgresqlAttribute attribute, {String? relation})
      : this(attribute.name, attribute.type, relation: relation);
}
