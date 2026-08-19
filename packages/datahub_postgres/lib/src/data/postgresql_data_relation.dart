import 'package:boost/boost.dart';
import 'package:datahub/data.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/services.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/data.dart';

import 'package:postgres/postgres.dart' as pg;

sealed class PostgresqlDataRelation<DataType extends DataObject> {
  PostgresqlRelation get relation;

  DataBean<DataType> get bean;

  Iterable<PostgresqlDataAttribute> get attributes =>
      relation.attributes.whereType<PostgresqlDataAttribute>();

  PostgresqlDataAttribute attributeOf(DataField<DataType, dynamic> field) =>
      attributes.firstWhere((a) => a.field.name == field.name);

  Future<List<Map<String, dynamic>>> select(
    PostgresqlContext context,
    List<Expression> select, {
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    List<Expression> group = const <Expression>[],
    int offset = 0,
    int limit = -1,
  }) async {
    final result = await context.execute(
      SqlSelect(
        SqlQualifiedRelation(relation.schemaName, relation.name),
        [
          for (final expression in select)
            RawSqlAttribute(
              buildExpressionSql(
                expression,
                attributes.map((e) => (e, relation)),
              ),
            ),
        ],
        where: buildFilterSql(filter, attributes.map((e) => (e, relation))),
        group: group.isNotEmpty
            ? Sql.join(
                group
                    .map(
                      (e) => buildExpressionSql(
                        e,
                        attributes.map((e) => (e, relation)),
                      ),
                    )
                    .separatedBy(RawSql(', ')),
              )
            : null,
        order: buildSortSql(sort, attributes.map((e) => (e, relation))),
        offset: offset,
        limit: limit,
      ),
    );

    return [
      for (final row in result)
        {
          for (final (index, column) in row.schema.columns.indexed)
            column.columnName ?? '': row[index],
        },
    ];
  }

  Future<List<DataType>> selectData(
    PostgresqlContext context, {
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
    int limit = -1,
  }) async {
    final result = await context.execute(
      SqlSelect(
        SqlQualifiedRelation(relation.schemaName, relation.name),
        attributes.map(SqlTypedAttribute.of).toList(),
        offset: offset,
        limit: limit,
        where: buildFilterSql(filter, attributes.map((e) => (e, relation))),
        order: buildSortSql(sort, attributes.map((e) => (e, relation))),
      ),
    );

    return result.map(mapResultRow).toList();
  }

  Future<List<(DataType?, TRight?)>>
  selectJoin<TRight extends DataObject<TRight>>(
    PostgresqlContext context,
    PostgresqlDataRelation<TRight> right,
    SqlJoinType type,
    Filter on, {
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
    int limit = -1,
  }) async {
    final allAttributes = attributes
        .map<(PostgresqlDataAttribute, PostgresqlRelation)>(
          (e) => (e, relation),
        )
        .followedBy(right.attributes.map((e) => (e, right.relation)));
    final result = await context.execute(
      SqlSelect(
        SqlJoin(
          left: SqlQualifiedRelation(relation.schemaName, relation.name),
          right: SqlQualifiedRelation(
            right.relation.schemaName,
            right.relation.name,
          ),
          type: SqlJoinType.left,
          on: buildFilterSql(on, allAttributes),
        ),
        allAttributes
            .map((e) => SqlTypedAttribute.of(e.$1, relation: e.$2.name))
            .toList(),
        offset: offset,
        limit: limit,
        where: buildFilterSql(filter, allAttributes),
        order: buildSortSql(sort, allAttributes),
      ),
    );

    return result.map((e) => _mapJoinResultRow<TRight>(right, e)).toList();
  }

  (DataType?, TRight?) _mapJoinResultRow<TRight extends DataObject<TRight>>(
    PostgresqlDataRelation<TRight> right,
    pg.ResultRow row, {
    int columnOffset = 0,
  }) {
    final leftOffset = columnOffset;
    final rightOffset = columnOffset + attributes.length;

    final DataType? leftResult;
    if (Iterable.generate(
      attributes.length,
      (i) => leftOffset + i,
    ).every(row.isSqlNull)) {
      leftResult = null;
    } else {
      leftResult = mapResultRow(row, columnOffset: leftOffset);
    }

    final TRight? rightResult;
    if (Iterable.generate(
      right.attributes.length,
      (i) => rightOffset + i,
    ).every(row.isSqlNull)) {
      rightResult = null;
    } else {
      rightResult = right.mapResultRow(row, columnOffset: rightOffset);
    }

    return (leftResult, rightResult);
  }

  Future<DataType> insert(PostgresqlContext context, DataType candidate) async {
    final insertAttributes = attributes.where(
      (e) => !e.hasConstraint<PrimaryKeyConstraint>((e) => e.auto),
    );

    final result = await context.execute(
      SqlInsert(
        SqlQualifiedRelation(relation.schemaName, relation.name),
        {
          for (final attribute in insertAttributes)
            SqlTypedAttribute.of(attribute): attribute.field.valueOf(candidate),
        },
        returning: attributes.map(SqlTypedAttribute.of).toList(),
      ),
    );

    return mapResultRow(result.first);
  }

  Future<int> update(
    PostgresqlContext context,
    Filter filter,
    Map<DataField<DataType, dynamic>, dynamic> columns,
  ) async {
    final result = await context.execute(
      SqlUpdate(
        SqlQualifiedRelation(relation.schemaName, relation.name),
        buildFilterSql(filter, attributes.map((e) => (e, relation))),
        {
          for (final (field, value) in columns.tuples)
            SqlTypedAttribute.of(
              attributes.firstWhere((a) => a.field.name == field.name),
            ): value,
        },
      ),
    );
    return result.affectedRows;
  }

  Future<int> delete(PostgresqlContext context, Filter filter) async {
    final result = await context.execute(
      SqlDelete(
        SqlQualifiedRelation(relation.schemaName, relation.name),
        buildFilterSql(filter, attributes.map((e) => (e, relation))),
      ),
    );
    return result.affectedRows;
  }

  DataType mapResultRow(pg.ResultRow row, {int columnOffset = 0}) {
    return bean.fromValues({
      for (final (idx, attribute) in attributes.indexed)
        attribute.field.name: attribute.type.decode(row[columnOffset + idx]),
    });
  }
}

class PostgresqlDataTable<DataType extends DataObject>
    extends PostgresqlDataRelation<DataType> {
  @override
  late final PostgresqlTable relation;

  @override
  final DataBean<DataType> bean;

  PostgresqlDataTable({
    String? name,
    required String schemaName,
    required this.bean,
  }) {
    relation = DataSchemaBuilder.buildDataTable(
      bean,
      schemaName: schemaName,
      name: name,
    );
  }
}

class PostgresqlDataView<DataType extends DataObject<DataType>>
    extends PostgresqlDataRelation<DataType> {
  @override
  late final PostgresqlView relation;

  @override
  final DataBean<DataType> bean;

  PostgresqlDataView({
    String? name,
    required String schemaName,
    required this.bean,
    required SqlSelect select,
  }) {
    relation = PostgresqlView(
      schemaName: schemaName,
      name: name ?? DataSchemaBuilder.relationNameOf(bean),
      select: select,
      attributes: [
        for (final field in bean.fields)
          PostgresqlDataAttribute.fromField(field),
      ],
    );
  }
}
