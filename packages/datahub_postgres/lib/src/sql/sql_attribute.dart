import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/types.dart';

import 'sql.dart';

abstract class SqlAttribute with SqlBuilder {
  const SqlAttribute();

  @override
  Sql toSql();

  Sql toSqlUnqualified();
}

abstract class SqlTypedAttribute extends SqlAttribute {
  final PostgresqlDataType type;

  const SqlTypedAttribute(this.type);

  factory SqlTypedAttribute.of(
    PostgresqlAttribute attribute, {
    String? relation,
  }) = SqlTypedColumnAttribute.of;
}

class SqlColumnAttribute extends SqlAttribute {
  final String? relation;
  final String name;

  const SqlColumnAttribute(this.name, {this.relation});

  @override
  Sql toSql() => Sql.qualifiedName([?relation, name]);

  @override
  Sql toSqlUnqualified() => Sql.name(name);
}

class SqlTypedColumnAttribute extends SqlColumnAttribute
    implements SqlTypedAttribute {
  @override
  final PostgresqlDataType type;

  const SqlTypedColumnAttribute(super.name, this.type, {super.relation});

  factory SqlTypedColumnAttribute.of(
    PostgresqlAttribute attribute, {
    String? relation,
  }) => SqlTypedColumnAttribute(
    attribute.name,
    attribute.type,
    relation: relation,
  );
}

class RawSqlAttribute extends SqlAttribute {
  final Sql sql;

  const RawSqlAttribute(this.sql);

  @override
  Sql toSql() => sql;

  @override
  Sql toSqlUnqualified() => sql;
}

class SqlWildcard extends SqlAttribute {
  const SqlWildcard();

  @override
  Sql toSql() => const RawSql('*');

  @override
  Sql toSqlUnqualified() => const RawSql('*');
}

class SqlAliasedAttribute extends SqlAttribute {
  final String alias;
  final SqlAttribute attribute;

  SqlAliasedAttribute(this.alias, this.attribute);

  @override
  Sql toSql() => Sql.join([attribute.toSql(), RawSql(' AS '), Sql.name(alias)]);

  @override
  Sql toSqlUnqualified() =>
      Sql.join([attribute.toSqlUnqualified(), RawSql(' AS '), Sql.name(alias)]);
}
