import 'package:datahub_postgres/schema.dart';

import 'sql.dart';

class SqlAttribute {
  final String name;

  const SqlAttribute(this.name);

  @override
  String toString() => Sql.escapeName(name);
}

class SqlWildcard extends SqlAttribute {
  const SqlWildcard() : super('*');

  @override
  String toString() => '*';
}

class SqlTypedAttribute extends SqlAttribute {
  final PostgresqlDataType type;

  const SqlTypedAttribute(super.name, this.type);

  SqlTypedAttribute.of(PostgresqlAttribute attribute)
      : this(attribute.name, attribute.type);
}
