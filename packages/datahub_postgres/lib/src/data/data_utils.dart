import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';
import 'package:postgres/postgres.dart' as pg;

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

Sql buildExpressionSql(Expression expression) {
  // TODO implement
  throw UnimplementedError();
}

Sql? buildFilterSql(PostgresqlRelation relation, Filter filter) {
  return switch (filter) {
    EmptyFilter() => null,
    FilterGroup() => Sql.joinWrap(
      filter.filters
          .map((e) => buildFilterSql(relation, e))
          .nonNulls
          .separatedBy(filter.isConjunction ? Sql.and : Sql.or),
    ),
    CompareFilter(:final left, :final type, :final right) => _compareSql(
      relation,
      left,
      type,
      right,
    ),
  };
}

Sql _compareSql(
  PostgresqlRelation relation,
  Expression left,
  CompareType type,
  Expression right,
) {
  final effectiveLeft = switch (left) {
    FieldExpression(:final field) =>
      relation.attributes.whereType<PostgresqlDataAttribute>().firstWhere(
        (e) => e.field == field,
      ),
    ValueExpression(:final value) => value,
  };

  final effectiveRight = switch (right) {
    FieldExpression(:final field) =>
      relation.attributes.whereType<PostgresqlDataAttribute>().firstWhere(
        (e) => e.field == field,
      ),
    ValueExpression(:final value) => value,
  };

  // TODO some rules and sanity checks maybe?

  final leftType = switch (effectiveLeft) {
    PostgresqlAttribute(:final type) => type,
    final value => PostgresqlDataType.findForDynamic(value),
  };

  final leftSql = switch (effectiveLeft) {
    PostgresqlAttribute(:final name) => Sql.qualifiedName([
      relation.name,
      name,
    ]),
    final value => PostgresqlDataType.findForDynamic(value).sqlParam(value),
  };

  final rightSql = switch (effectiveRight) {
    PostgresqlAttribute(:final name) => Sql.qualifiedName([
      relation.name,
      name,
    ]),
    final value => PostgresqlDataType.findForDynamic(value).sqlParam(value),
  };

  return switch ((leftType, type)) {
    (PostgresqlString(), CompareType.contains) => Sql.join([
      leftSql,
      RawSql(' ~* '),
      rightSql,
    ]),
    (
      PostgresqlStringArray() ||
          PostgresqlIntArray() ||
          PostgresqlDoubleArray() ||
          PostgresqlBoolArray(),
      CompareType.contains,
    ) =>
      rightSql + RawSql(' = ') + Sql.function('ANY', [leftSql]),
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
