import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/services.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:meta/meta.dart';

@optionalTypeArgs
mixin PostgresqlDataRepository<
  TService extends Service,
  DataType extends DataObject<DataType>
>
    on ServiceInstance<TService>
    implements DataRepository<DataType> {
  Find<Postgresql> get postgresql => const Find<Postgresql>();

  Config<String> get schemaName =>
      const Config<String>('schemaName', defaultValue: 'public');

  Config<String?> get relationName => const Config<String?>('relationName');

  late final PostgresqlDataRelation<DataType> dataRelation;

  @override
  @mustCallSuper
  FutureOr<void> initialize() async {
    super.initialize();

    dataRelation = PostgresqlDataTable(
      bean: bean,
      schemaName: read(schemaName),
      name:
          read(relationName) ??
          toNamingConvention(bean.name, NamingConvention.lowerSnakeCase),
    );

    await find(postgresql).runTransaction((context) async {
      await dataRelation.relation.ensureRelation(context);
    });
  }

  @override
  Future<DataType> create(DataType object) async {
    return await find(postgresql).runTransaction((context) async {
      return await dataRelation.insert(context, object);
    });
  }

  @override
  Future<DataType?> readById(dynamic id) async {
    return await first(filter: identityFilter(bean, id));
  }

  @override
  Future<List<DataType>> readAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
  }) async {
    return await find(postgresql).runTransaction((context) async {
      return await dataRelation.selectData(
        context,
        filter: filter,
        sort: sort,
        offset: offset ?? 0,
        limit: limit ?? -1,
      );
    });
  }

  @override
  Future<int> count({Filter filter = Filter.empty}) async {
    return await find(postgresql).runTransaction((context) async {
      // TODO aggregates should be abstract
      final result = await dataRelation.select(context, [
        PostgresqlRawExpression(RawSql('COUNT(*) as "count"')),
      ], filter: filter);
      return result.firstOrNull?['count'] ?? 0;
    });
  }

  @override
  Future<bool> updateById(DataType element) async {
    final affected = await updateAll(
      filter: identityFilter(bean, bean.requireIdField.valueOf(element)),
      values: {
        for (final field in bean.fields.where((e) => !e.hasMetaOfType<Id>()))
          field: field.valueOf(element),
      },
    );
    return affected > 0;
  }

  @override
  Future<int> updateAll({
    required Filter filter,
    required Map<DataField<DataType, dynamic>, dynamic> values,
  }) async {
    return await find(postgresql).runTransaction((context) async {
      return await dataRelation.update(context, filter, values);
    });
  }

  @override
  Future<bool> deleteById(dynamic id) async {
    final affected = await deleteAll(filter: identityFilter(bean, id));
    return affected > 0;
  }

  @override
  Future<int> deleteAll({required Filter filter}) async {
    return await find(postgresql).runTransaction((context) async {
      return await dataRelation.delete(context, filter);
    });
  }

  Future<DataType?> first({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
  }) async {
    final result = await readAll(
      filter: filter,
      sort: sort,
      offset: offset,
      limit: 1,
    );
    return result.firstOrNull;
  }

  @override
  Future<R> atomic<R>(Future<R> Function() delegate) async {
    return await find(
      postgresql,
    ).runTransaction((context) async => await delegate());
  }
}
