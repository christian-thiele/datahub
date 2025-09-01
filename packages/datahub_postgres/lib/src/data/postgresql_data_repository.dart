import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/services.dart';
import 'package:postgres/postgres.dart' as pg;

class PostgresqlDataRepository<DataType extends DataObject<DataType>>
    extends PostgresqlRepository implements DataRepository<DataType> {
  final String? relation;
  late final PostgresqlDataRelation _relation;
  @override
  final DataBean<DataType> bean;

  PostgresqlDataRepository({
    super.config,
    required this.bean,
    this.relation,
  });

  @override
  Future<void> initialize() async {
    await super.initialize();
    if (relation != null) {
      final named = schema.relations.firstWhere(
        (e) => e.name == relation,
        orElse: () => throw ApiError('Relation "$relation" not found.'),
      );

      _relation = switch (named) {
        final PostgresqlDataRelation named => named,
        _ => throw ApiError(
            'Relation "$relation" is not a PostgresqlDataRelation.'),
      };
    } else {
      _relation =
          schema.relations.whereType<PostgresqlDataRelation>().firstWhere(
                (e) => e.bean == bean,
                orElse: () =>
                    throw ApiError('No matching relation found for $DataType.'),
              );
    }
  }

  @override
  Future<DataType> create(DataType object) async {
    return await runTransaction((context) async {
      final primaryKey = _dataAttributes
          .where((e) => e.hasConstraint<PrimaryKeyConstraint>())
          .firstOrNull;
      final result = await context.execute(
        SqlInsert(
          SqlQualifiedRelation(schema.name, _relation.name),
          {
            for (final attribute in _dataAttributes.where(
                (e) => !e.hasConstraint<PrimaryKeyConstraint>((e) => e.auto)))
              SqlTypedAttribute.of(attribute): attribute.field.valueOf(object),
          },
          returning:
              primaryKey != null ? SqlTypedAttribute.of(primaryKey) : null,
        ),
      );

      if (result.firstOrNull?.firstOrNull case final id?) {
        return await get(id) ??
            (throw Exception(
                'Could not retrieve created object from database.'));
      } else {
        return object;
      }
    });
  }

  @override
  Future<List<DataType>> getAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
  }) async {
    final result = await runTransaction((context) async {
      return await context.execute(
        SqlSelect(
          SqlQualifiedRelation(schema.name, _relation.name),
          [SqlWildcard()],
          offset: offset ?? 0,
          limit: limit ?? -1,
          where: _buildFilterSql(filter),
        ),
      );
    });

    return _mapResult(result);
  }

  @override
  Future<void> delete(dynamic id) async {
    return await runTransaction((context) async {
      await context.execute(
        SqlDelete(
          SqlQualifiedRelation(schema.name, _relation.name),
          _buildFilterSql(_identityFilter(id)),
        ),
      );
    });
  }

  @override
  Future<DataType?> get(dynamic id) async {
    return await first(filter: _identityFilter(id));
  }

  Future<DataType?> first({Filter filter = Filter.empty}) async {
    final result = await runTransaction((context) async {
      return await context.execute(
        SqlSelect(
          SqlQualifiedRelation(schema.name, _relation.name),
          [SqlWildcard()],
          limit: 1,
          where: _buildFilterSql(filter),
        ),
      );
    });

    if (result.isNotEmpty) {
      return _mapResultRow(result.first);
    } else {
      return null;
    }
  }

  @override
  Future<DataType> update(dynamic id, DataType object) async {
    return await runTransaction((context) async {
      await context.execute(
        SqlUpdate(
          SqlQualifiedRelation(schema.name, _relation.name),
          _buildFilterSql(_identityFilter(id)),
          {
            for (final attribute in _dataAttributes.where(
                (e) => !e.hasConstraint<PrimaryKeyConstraint>((e) => e.auto)))
              SqlTypedAttribute.of(attribute): attribute.field.valueOf(object),
          },
        ),
      );

      return await get(id) ??
          (throw Exception('Could not retrieve updated object from database.'));
    });
  }

  List<DataType> _mapResult(pg.Result result) {
    final mapping = {
      for (final attribute
          in _relation.attributes.whereType<PostgresqlDataAttribute>())
        attribute.field: result.schema.columns.indexWhere(
          (e) => e.columnName == attribute.name,
        )
    };

    return result
        .map(
          (row) => bean.fromValues(
              mapping.map((field, idx) => MapEntry(field.name, row[idx]))),
        )
        .toList();
  }

  DataType _mapResultRow(pg.ResultRow row) {
    final mapping = {
      for (final attribute in _dataAttributes)
        attribute.field: row.schema.columns.indexWhere(
          (e) => e.columnName == attribute.name,
        )
    };

    return bean.fromValues(
      mapping.map((field, idx) => MapEntry(field.name, row[idx])),
    );
  }

  Filter _identityFilter(dynamic id) {
    return Filter.equals(
      bean.idField ?? (throw MissingIdFieldError(bean)),
      _typedId(id),
    );
  }

  dynamic _typedId(dynamic id) {
    final idField = bean.idField ?? (throw MissingIdFieldError(bean));
    return switch (idField.type) {
      final t when t.isExact<int>() => switch (id) {
          int() => id,
          String() => int.parse(id),
          _ => throw CodecException.typeMismatch(
              int, id.runtimeType, idField.name),
        },
      final t when t.isExact<String>() => id.toString(),
      _ => throw ApiError('Invalid Id type: ${idField.type.name}'),
    };
  }

  Sql? _buildFilterSql(Filter filter) {
    return switch (filter) {
      EmptyFilter() => null,
      FilterGroup() => filter.filters
          .map(_buildFilterSql)
          .nonNulls
          .joinSql(filter.isConjunction ? ' AND ' : ' OR ')
        ..wrap(),
      CompareFilter(:final left, :final type, :final right) =>
        _compareSql(left, type, right),
    };
  }

  Sql _compareSql(Expression left, CompareType type, Expression right) {
    final effectiveLeft = switch (left) {
      FieldExpression(:final field) => _fieldAttribute(field),
      ValueExpression(:final value) => value,
    };

    final effectiveRight = switch (right) {
      FieldExpression(:final field) => _fieldAttribute(field),
      ValueExpression(:final value) => value,
    };

    // TODO some rules and sanity checks maybe?

    final leftSql = switch (effectiveLeft) {
      PostgresqlAttribute(:final name) =>
        Sql.qualifiedName([_relation.name, name]),
      final value => PostgresqlDataType.findForDynamic(value).sqlParam(value),
    };

    final rightSql = switch (effectiveRight) {
      PostgresqlAttribute(:final name) =>
        Sql.qualifiedName([_relation.name, name]),
      final value => PostgresqlDataType.findForDynamic(value).sqlParam(value),
    };

    return Sql.combine([
      leftSql,
      switch (type) {
        CompareType.equals ||
        CompareType.contains ||
        CompareType.isIn =>
          Sql(' = '),
        CompareType.notEquals => Sql(' <> '),
        CompareType.greaterThan => Sql(' > '),
        CompareType.lessThan => Sql(' < '),
        CompareType.greaterOrEqual => Sql(' >= '),
        CompareType.lessOrEqual => Sql(' <= '),
      },
      rightSql,
    ]);
  }

  PostgresqlAttribute _fieldAttribute(DataField field) =>
      _dataAttributes.firstWhere((a) => a.field == field);

  Iterable<PostgresqlDataAttribute> get _dataAttributes =>
      _relation.attributes.whereType<PostgresqlDataAttribute<DataType>>();
}

// UTILS
extension on PostgresqlDataAttribute {
  bool hasConstraint<T extends PostgresqlAttributeConstraint>(
      [bool Function(T)? test]) {
    return constraints.whereType<T>().where(test ?? (_) => true).isNotEmpty;
  }
}
