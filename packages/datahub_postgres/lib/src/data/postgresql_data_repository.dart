import 'package:datahub/data.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/services.dart';
import 'package:datahub_postgres/src/sql/sql_filter.dart';
import 'package:postgres/postgres.dart' as pg;

class PostgresqlDataRepository<DataType extends DataObject<DataType>>
    extends PostgresqlRepository implements DataRepository<DataType> {
  final String? relation;
  late final PostgresqlDataRelation _relation;
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
        orElse: () => throw Exception('Relation "$relation" not found.'),
      );

      _relation = switch (named) {
        final PostgresqlDataRelation named => named,
        _ => throw Exception(
            'Relation "$relation" is not a PostgresqlDataRelation.'),
      };
    } else {
      _relation = schema.relations
          .whereType<PostgresqlDataRelation>()
          .firstWhere(
            (e) => e.bean == bean,
            orElse: () =>
                throw Exception('No matching relation found for $DataType.'),
          );
    }
  }

  @override
  Future<DataType> create(DataType object) async {
    return await runTransaction((context) async {
      await context.execute(
        SqlInsert(
          SqlQualifiedRelation(schema.name, _relation.name),
          {
            for (final attribute in _relation.attributes
                .whereType<PostgresqlDataAttribute<DataType>>()
                .where((e) => e.type != PostgresqlDataType.bigSerial))
              SqlTypedAttribute.of(attribute): attribute.field.valueOf(object),
          },
        ),
      );

      // TODO this is not correct
      return object;
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
        ),
      );
    });

    return _mapResult(result);
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
      for (final attribute
          in _relation.attributes.whereType<PostgresqlDataAttribute>())
        attribute.field: row.schema.columns.indexWhere(
          (e) => e.columnName == attribute.name,
        )
    };

    return bean.fromValues(
      mapping.map((field, idx) => MapEntry(field.name, row[idx])),
    );
  }

  @override
  Future<DataType> delete(dynamic id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<DataType?> get(dynamic id) async {
    final idField = bean.fields.firstWhere(
      (e) => e.meta.any((e) => e is Id),
      orElse: () =>
          throw Exception('Data class ${bean.name} does not provide Id field.'),
    );

    final typedId = switch (idField) {
      DataField<DataType, int>() => switch (id) {
          int() => id,
          String() => int.parse(id),
          _ => throw CodecException.typeMismatch(
              int, id.runtimeType, idField.name),
        },
      DataField<DataType, String>() => switch (id) {
          int() => id.toString(),
          String() => id,
          _ => throw CodecException.typeMismatch(
              int, id.runtimeType, idField.name),
        },
      _ => throw Exception('Invalid Id type: ${idField.type}'),
    };

    final result = await runTransaction((context) async {
      return await context.execute(
        SqlSelect(
          SqlQualifiedRelation(schema.name, _relation.name),
          [SqlWildcard()],
          limit: 1,
          where: SqlFilter(Filter.equals(idField, typedId)).toSql(),
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
  Future<DataType> update(dynamic id, DataType element) async {
    // TODO fix
    return element;
  }
}
