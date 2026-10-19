import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/types.dart';

import 'sql.dart';

abstract class const SqlAttribute() with SqlBuilder {
  @override
  Sql toSql();

  Sql toSqlUnqualified();
}

abstract class const SqlTypedAttribute(final PostgresqlDataType type)
    extends SqlAttribute {
  factory of(PostgresqlAttribute attribute, {String? relation}) =
      SqlTypedColumnAttribute.of;
}

class const SqlColumnAttribute(final String name, {final String? relation})
    extends SqlAttribute {
  @override
  Sql toSql() => Sql.qualifiedName([?relation, name]);

  @override
  Sql toSqlUnqualified() => Sql.name(name);
}

class const SqlTypedColumnAttribute(
  super.name,
  @override final PostgresqlDataType type, {
  super.relation,
}) extends SqlColumnAttribute implements SqlTypedAttribute {
  factory of(PostgresqlAttribute attribute, {String? relation}) =>
      SqlTypedColumnAttribute(
        attribute.name,
        attribute.type,
        relation: relation,
      );
}

class const RawSqlAttribute(final Sql sql) extends SqlAttribute {
  @override
  Sql toSql() => sql;

  @override
  Sql toSqlUnqualified() => sql;
}

class const SqlWildcard({final String? relation}) extends SqlAttribute {
  @override
  Sql toSql() {
    if (relation case final relation?) {
      return Sql.name(relation) + const RawSql('.*');
    } else {
      return const RawSql('*');
    }
  }

  @override
  Sql toSqlUnqualified() => const RawSql('*');
}

class SqlAliasedAttribute(final String alias, final SqlAttribute attribute)
    extends SqlAttribute {
  @override
  Sql toSql() =>
      Sql.join([attribute.toSql(), const RawSql(' AS '), Sql.name(alias)]);

  @override
  Sql toSqlUnqualified() => Sql.join([
    attribute.toSqlUnqualified(),
    const RawSql(' AS '),
    Sql.name(alias),
  ]);
}
