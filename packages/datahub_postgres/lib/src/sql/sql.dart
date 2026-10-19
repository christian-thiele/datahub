import 'package:boost/boost.dart';
import 'package:datahub_postgres/types.dart';

import 'sql_exception.dart';

class _Sequence() {
  var _value = 0;

  int get value => ++_value;
}

sealed class const Sql() {
  static const and = RawSql(' AND ');
  static const or = RawSql(' OR ');

  static const equals = RawSql(' = ');
  static const notEquals = RawSql(' <> ');
  static const greaterThan = RawSql(' > ');
  static const lessThan = RawSql(' < ');
  static const greaterOrEqual = RawSql(' >= ');
  static const lessOrEqual = RawSql(' <= ');

  factory join(Iterable<Sql> segments) {
    if (segments.isEmpty) {
      return RawSql.empty;
    }

    if (segments.length == 1) {
      return segments.single;
    }

    Sql result = segments.first;
    for (final segment in segments.skip(1)) {
      result += segment;
    }
    return result;
  }

  factory joinWrap(Iterable<Sql> segments) => Sql.join(segments).wrap();

  factory name(String name) => RawSql(escapeName(name));

  factory qualifiedName(Iterable<String> name) =>
      RawSql(name.map(escapeName).join('.'));

  factory text(String text) => RawSql(escapeText(text));

  factory function(String name, Iterable<Sql> args) =>
      RawSql(name) + Sql.joinWrap(args.separatedBy(const RawSql(', ')));

  factory cast(Sql expression, PostgresqlDataType? type) =>
      type != null ? expression.wrap() + RawSql('::${type.name}') : expression;

  factory alias(Sql expression, String name) =>
      expression.wrap() + const RawSql(' AS ') + Sql.name(name);

  Sql operator +(Sql other) => CombinedSql(this, other);

  Iterable<dynamic> getParameters();

  Iterable<PostgresqlDataType> getParameterTypes();

  Iterable<dynamic> getEncodedParameters();

  String toLiteralString();

  Sql wrap() => Sql.join([const RawSql('('), this, const RawSql(')')]);

  @override
  String toString() => _toSqlString(_Sequence());

  String _toSqlString(_Sequence paramSeq);

  static String escapeText(String text) {
    return "'${text.replaceAll(r'\', r'\\').replaceAll("'", "''")}'";
  }

  static String escapeTextForArrayLiteral(String text) {
    return '"${text.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
  }

  static String escapeName(String name) {
    if (name.isEmpty || name.length > 128) {
      throw SqlException(
        'Name "$name" has invalid length. '
        '(Must be in range 1 - 128)',
      );
    }

    if (name.contains('"')) {
      //TODO check for more invalid characters
      throw SqlException('Name "$name" contains invalid characters.');
    }

    //TODO check for forbidden names like ANALYZE, BETWEEN, ...

    //TODO check for first letter restriction

    return '"$name"';
  }
}

abstract mixin class SqlBuilder() implements Sql {
  Sql toSql();

  @override
  String _toSqlString(_Sequence paramSeq) => toSql()._toSqlString(paramSeq);

  @override
  Iterable getEncodedParameters() => toSql().getEncodedParameters();

  @override
  Iterable<PostgresqlDataType> getParameterTypes() =>
      toSql().getParameterTypes();

  @override
  Iterable getParameters() => toSql().getParameters();

  @override
  String toLiteralString() => toSql().toLiteralString();

  @override
  Sql operator +(Sql other) => toSql() + other;

  @override
  Sql wrap() => toSql().wrap();

  @override
  String toString() => _toSqlString(_Sequence());
}

class const CombinedSql(final Sql left, final Sql right) extends Sql {
  @override
  String toLiteralString() => left.toLiteralString() + right.toLiteralString();

  @override
  Iterable<PostgresqlDataType> getParameterTypes() =>
      left.getParameterTypes().followedBy(right.getParameterTypes());

  @override
  Iterable<dynamic> getParameters() =>
      left.getParameters().followedBy(right.getParameters());

  @override
  Iterable<dynamic> getEncodedParameters() =>
      left.getEncodedParameters().followedBy(right.getEncodedParameters());

  @override
  String _toSqlString(_Sequence paramSeq) =>
      left._toSqlString(paramSeq) + right._toSqlString(paramSeq);
}

class const RawSql(final String raw) extends Sql {
  static const empty = RawSql('');

  @override
  String toLiteralString() => raw;

  @override
  Iterable<PostgresqlDataType> getParameterTypes() => const Iterable.empty();

  @override
  Iterable<dynamic> getParameters() => const Iterable.empty();

  @override
  Iterable<dynamic> getEncodedParameters() => const Iterable.empty();

  @override
  String _toSqlString(_Sequence paramSeq) => raw;
}

class const ParameterSql<T>(final T? value, final PostgresqlDataType<T> type)
    extends Sql {
  @override
  String toLiteralString() => type.sqlLiteral(value).toLiteralString();

  @override
  Iterable<PostgresqlDataType> getParameterTypes() => [type];

  @override
  Iterable<dynamic> getParameters() => [value];

  @override
  Iterable<dynamic> getEncodedParameters() => [type.encode(value)];

  @override
  String _toSqlString(_Sequence paramSeq) =>
      '\$${paramSeq.value}::${type.name}';
}
