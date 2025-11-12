import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';
import 'package:postgres/postgres.dart' as pg;

import 'postgresql_function_expression.dart';
import 'postgresql_data_attribute.dart';

List<DataType> mapResultRowToData<DataType extends DataObject<DataType>>(
  DataBean<DataType> bean,
  pg.ResultRow row,
) {
  final decoderMapping = _buildDecoderMapping(
    bean.fields.map(PostgresqlDataAttribute.fromField),
    row.schema,
  );
  return [
    bean.fromValues({
      for (final (fieldName, decode) in decoderMapping.tuples)
        fieldName: decode(row),
    }),
  ];
}

List<DataType> mapResultToData<DataType extends DataObject<DataType>>(
  DataBean<DataType> bean,
  pg.Result result,
) {
  final decoderMapping = _buildDecoderMapping(
    bean.fields.map(PostgresqlDataAttribute.fromField),
    result.schema,
  );
  return [
    for (final row in result)
      bean.fromValues({
        for (final (fieldName, decode) in decoderMapping.tuples)
          fieldName: decode(row),
      }),
  ];
}

List<DataType> mapResultToRelation<DataType extends DataObject<DataType>>(
  PostgresqlRelation relation,
  DataBean<DataType> bean,
  pg.Result result,
) {
  final decoderMapping = _buildDecoderMapping(
    relation.attributes.whereType<PostgresqlDataAttribute>(),
    result.schema,
  );
  return [
    for (final row in result)
      bean.fromValues({
        for (final (fieldName, decode) in decoderMapping.tuples)
          fieldName: decode(row),
      }),
  ];
}

DataType mapResultRowToRelation<DataType extends DataObject<DataType>>(
  PostgresqlRelation relation,
  DataBean<DataType> bean,
  pg.ResultRow row,
) {
  final decoderMapping = _buildDecoderMapping(
    relation.attributes.whereType<PostgresqlDataAttribute>(),
    row.schema,
  );
  return bean.fromValues({
    for (final (fieldName, decode) in decoderMapping.tuples)
      fieldName: decode(row),
  });
}

Map<String, dynamic Function(dynamic)> _buildDecoderMapping(
  Iterable<PostgresqlDataAttribute> attributes,
  pg.ResultSchema schema,
) {
  return {
    for (final attribute in attributes.whereType<PostgresqlDataAttribute>())
      attribute.field.name: (row) => attribute.type.decode(
        row[schema.columns.indexWhere((e) => e.columnName == attribute.name)],
      ),
  };
}

Filter identityFilter(DataBean bean, dynamic id) {
  return Filter.equals(bean.requireIdField, _typedId(bean, id));
}

dynamic _typedId(DataBean bean, dynamic id) {
  final idField = bean.requireIdField;
  return switch (idField.type) {
    final t when t.isExact<int>() => switch (id) {
      int() => id,
      String() => int.parse(id),
      _ => throw CodecException.typeMismatch(int, id.runtimeType, idField.name),
    },
    final t when t.isExact<String>() => id.toString(),
    _ => throw ApiError('Invalid Id type: ${idField.type.name}'),
  };
}

Sql? buildFilterSql(
  Filter filter,
  Iterable<(PostgresqlDataAttribute, PostgresqlRelation)> attributes,
) {
  return switch (filter) {
    EmptyFilter() => null,
    FilterGroup() => Sql.joinWrap(
      filter.filters
          .map((e) => buildFilterSql(e, attributes))
          .nonNulls
          .separatedBy(filter.isConjunction ? Sql.and : Sql.or),
    ),
    CompareFilter(:final left, :final type, :final right) => _compareSql(
      attributes,
      left,
      type,
      right,
    ),
  };
}

Sql? buildSortSql(
  Sort sort,
  Iterable<(PostgresqlDataAttribute, PostgresqlRelation)> attributes,
) {
  final flat = sort.expand();
  if (flat.isEmpty) {
    return null;
  }

  return Sql.join(
    flat
        .map((e) {
          return buildExpressionSql(e.expression, attributes) +
              (e.ascending ? RawSql(' ASC') : RawSql(' DESC'));
        })
        .separatedBy(RawSql(', ')),
  );
}

(PostgresqlDataAttribute, PostgresqlRelation?) _findDataAttribute(
  Iterable<(PostgresqlDataAttribute, PostgresqlRelation?)> attributes,
  DataField field,
) {
  return attributes.firstWhere(
    (e) => e.$1.field == field,
    orElse: () => throw ApiException(
      'Could not find attribute for field "${field.name}"',
    ),
  );
}

Sql buildExpressionSql(
  Expression expression,
  Iterable<(PostgresqlDataAttribute, PostgresqlRelation?)> attributes,
) {
  return switch (expression) {
    ValueExpression(:final value) => PostgresqlDataType.findForDynamic(
      value,
    ).sqlParam(value),
    final DataField field => _findDataAttribute(
      attributes,
      field,
    ).apply((e) => SqlTypedColumnAttribute.of(e.$1, relation: e.$2?.name)),
    PostgresqlFunctionExpression(:final name, :final arguments) => Sql.function(
      name,
      arguments.map((e) => buildExpressionSql(e, attributes)).toList(),
    ),
    PostgresqlRawExpression(:final sql) => sql,
    _ => throw UnsupportedExpressionError(
      expression,
      library: 'datahub_postgres',
    ),
  };
}

PostgresqlDataType? typeOf(
  Expression expression,
  Iterable<(PostgresqlDataAttribute, PostgresqlRelation?)> attributes,
) => switch (expression) {
  ValueExpression(:final value) => PostgresqlDataType.findForDynamic(value),
  final DataField field => _findDataAttribute(attributes, field).$1.type,
  PostgresqlFunctionExpression(:final returnType) => returnType,
  _ => null,
};

Sql _compareSql(
  Iterable<(PostgresqlDataAttribute, PostgresqlRelation?)> attributes,
  Expression left,
  CompareType type,
  Expression right,
) {
  final leftType = typeOf(left, attributes);
  final rightType = typeOf(right, attributes);

  final leftSql = buildExpressionSql(left, attributes);
  final rightSql = buildExpressionSql(right, attributes);

  return switch ((leftType, type, rightType)) {
    (_, CompareType.equals, PostgresqlNull()) => leftSql + RawSql(' IS NULL'),
    (_, CompareType.notEquals, PostgresqlNull()) =>
      leftSql + RawSql(' IS NOT NULL'),
    (PostgresqlString(), CompareType.contains, PostgresqlString()) => Sql.join([
      leftSql,
      RawSql(' ~* '),
      rightSql,
    ]),
    (PostgresqlString(), CompareType.isIn, PostgresqlString()) => Sql.join([
      rightSql,
      RawSql(' ~* '),
      leftSql,
    ]),
    (
      PostgresqlStringArray() ||
          PostgresqlIntArray() ||
          PostgresqlDoubleArray() ||
          PostgresqlBoolArray(),
      CompareType.contains,
      _,
    ) =>
      rightSql + RawSql(' = ') + Sql.function('ANY', [leftSql]),
    (
      _,
      CompareType.isIn,
      PostgresqlStringArray() ||
          PostgresqlIntArray() ||
          PostgresqlDoubleArray() ||
          PostgresqlBoolArray(),
    ) =>
      leftSql + RawSql(' = ') + Sql.function('ANY', [rightSql]),
    _ => Sql.join([
      leftSql,
      switch (type) {
        CompareType.equals ||
        CompareType.contains ||
        CompareType.isIn => Sql.equals,
        CompareType.notEquals => Sql.notEquals,
        CompareType.greaterThan => Sql.greaterThan,
        CompareType.lessThan => Sql.lessThan,
        CompareType.greaterOrEqual => Sql.greaterOrEqual,
        CompareType.lessOrEqual => Sql.lessOrEqual,
      },
      rightSql,
    ]),
  };
}
