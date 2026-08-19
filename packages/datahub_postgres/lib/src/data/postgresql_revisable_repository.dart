import 'package:datahub/datahub.dart';

import 'dart:async';
import 'package:datahub_postgres/migration.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/services.dart';
import 'package:datahub_postgres/types.dart';
import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart' as pg;

import 'data_utils.dart';
import 'postgresql_data_attribute.dart';
import 'postgresql_data_relation.dart';
import 'postgresql_function_expression.dart';

@optionalTypeArgs
mixin PostgresqlRevisableRepository<
  TService extends Service,
  TData extends DataObject<TData>
>
    on ServiceInstance<TService>
    implements RevisableDataRepository<TData> {
  Config<String> get schemaName =>
      const Config<String>('schemaName', defaultValue: 'public');

  Config<String?> get relationName => const Config<String?>('relationName');

  Find<Postgresql> get postgresql => const Find<Postgresql>();

  @override
  DataBean<TData> get bean;

  late final PostgresqlDataAttribute _primaryAttribute;
  late final PostgresqlTable revisionTable;
  late final PostgresqlView revisionView;
  late final PostgresqlDataView<TData> dataView;

  @override
  FutureOr<void> initialize() async {
    await super.initialize();
    final effectiveSchemaName = read(schemaName);

    final relations = DataSchemaBuilder.buildRevisableRelations(
      bean,
      schemaName: effectiveSchemaName,
      name: read(relationName),
    );

    _primaryAttribute = relations.primaryAttribute;
    revisionTable = relations.table;
    revisionView = relations.view;

    dataView = PostgresqlDataView(
      bean: bean,
      schemaName: revisionView.schemaName,
      name: revisionView.name,
      select: revisionView.select,
    );

    final migrations = find(const Find<PostgresqlMigrations?>());
    final unmanaged = [
      for (final relation in relations.all)
        if (!(migrations?.manages(relation.qualifiedName) ?? false)) relation,
    ];

    if (unmanaged.isNotEmpty) {
      await find(postgresql).runTransaction((context) async {
        for (final relation in unmanaged) {
          await relation.ensureRelation(context);
        }
      });
    }
  }

  @override
  Future<RevisionData<TData>> createRevision(
    TData data, {
    DateTime? from,
    required int type,
  }) async {
    return await find(postgresql).runTransaction((context) async {
      final now = DateTime.timestamp();
      if (from?.isBefore(now) ?? false) {
        throw ApiRequestException(400, 'Cannot create revision in the past.');
      }

      final idField = bean.idField ?? (throw MissingIdFieldError(bean));
      final primaryKey = idField.valueOf(data);

      final currentRevision = primaryKey != null
          ? (await readRevisionsById(primaryKey, limit: 1)).firstOrNull
          : null;

      final currentVersion = currentRevision?.version ?? -1;

      if (type < 1 && (currentRevision?.isDeleted ?? true)) {
        throw RevisableInconsistencyException('Element does not exist.');
      }

      if (type > 0 && !(currentRevision?.isDeleted ?? true)) {
        throw RevisableInconsistencyException('Element already exists.');
      }

      final primaryIsAuto = _primaryAttribute.field.hasMetaOfType<Id>(
        (id) => id.auto,
      );

      final sessionIdentity =
          Context.zoneSession()?.identity ??
          (throw ApiRequestException.unauthorized(
            'Identity session required.',
          ));

      // TODO check if other defaults should be respected here
      final nonAutoAttributes = revisionTable.attributes
          .whereType<PostgresqlDataAttribute>()
          .where((e) => !(primaryIsAuto && e == _primaryAttribute));

      final result = await context.execute(
        SqlInsert(
          SqlQualifiedRelation(read(schemaName), revisionTable.name),
          {
            SqlTypedAttribute.of(DataSchemaBuilder.sysVersion):
                currentVersion + 1,
            SqlTypedAttribute.of(DataSchemaBuilder.sysCreator): sessionIdentity,
            SqlTypedAttribute.of(DataSchemaBuilder.sysFrom):
                from ?? RawSql('now()'),
            SqlTypedAttribute.of(DataSchemaBuilder.sysIsDeleted): type < 0,

            if (currentRevision case RevisionData(
              data: final currentData,
            ) when primaryIsAuto)
              SqlTypedAttribute.of(_primaryAttribute): bean.requireIdField
                  .valueOf(currentData),

            for (final attribute in nonAutoAttributes)
              SqlTypedAttribute.of(attribute): attribute.field.valueOf(data),
          },
          returning: [
            SqlTypedAttribute.of(
              _primaryAttribute,
              relation: revisionTable.name,
            ),
            SqlTypedAttribute.of(
              DataSchemaBuilder.sysFrom,
              relation: revisionTable.name,
            ),
          ],
        ),
      );

      final resultId = result.first[0] as Object;
      final resultSysFrom = result.first[1] as DateTime;

      if (currentRevision != null) {
        await context.execute(
          SqlUpdate(
            SqlQualifiedRelation(read(schemaName), revisionTable.name),
            Sql.join([
              ?buildFilterSql(
                identityFilter(bean, primaryKey),
                dataView.attributes.map((e) => (e, revisionTable)),
              ),
              RawSql(' AND '),
              SqlTypedColumnAttribute.of(DataSchemaBuilder.sysVersion),
              RawSql(' = '),
              ParameterSql(currentVersion, const PostgresqlInt()),
            ]),
            {SqlTypedAttribute.of(DataSchemaBuilder.sysTo): resultSysFrom},
          ),
        );
      }

      return await revisableReadById(resultId, version: currentVersion + 1) ??
          (throw ApiException('Could not retrieve object from database.'));
    });
  }

  @override
  Future<List<RevisionData<TData>>> revisableReadAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
  }) async {
    return await find(postgresql).runTransaction((context) async {
      final result = await context.execute(
        SqlSelect(
          SqlQualifiedRelation(read(schemaName), revisionView.name),
          [SqlWildcard()],
          where: buildFilterSql(
            filter,
            dataView.attributes.map((e) => (e, revisionView)),
          ),
          order: buildSortSql(
            sort,
            dataView.attributes.map((e) => (e, revisionView)),
          ),
          offset: offset ?? 0,
          limit: limit ?? -1,
        ),
      );

      return result.map((row) {
        final data = mapResultRowToRelation<TData>(
          revisionView as PostgresqlRelation,
          bean,
          row,
        );
        return _mapRevision(result.first, data);
      }).toList();
    });
  }

  @override
  Future<int> count({Filter filter = Filter.empty}) async {
    return await find(postgresql).runTransaction((context) async {
      // TODO aggregates should be abstract
      final result = await dataView.select(context, [
        PostgresqlRawExpression(RawSql('COUNT(*) as "count"')),
      ], filter: filter);
      return result.firstOrNull?['count'] ?? 0;
    });
  }

  @override
  Future<TData?> first({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
  }) async {
    final results = await readAll(
      filter: filter,
      sort: sort,
      offset: offset,
      limit: 1,
    );
    return results.firstOrNull;
  }

  @override
  Future<bool> any({Filter filter = Filter.empty}) async {
    return await find(postgresql).runTransaction((context) async {
      final result = await dataView.select(
        context,
        [ValueExpression(1)],
        filter: filter,
        limit: 1,
      );
      return result.isNotEmpty;
    });
  }

  @override
  Future<List<RevisionData<TData>>> readRevisionsById(
    id, {
    int? offset,
    int? limit,
  }) async {
    return await find(postgresql).runTransaction((context) async {
      final result = await context.execute(
        SqlSelect(
          SqlQualifiedRelation(read(schemaName), revisionTable.name),
          [SqlWildcard()],
          where: buildFilterSql(
            identityFilter(bean, id),
            dataView.attributes.map((e) => (e, revisionTable)),
          ),
          order: Sql.join([
            SqlTypedColumnAttribute.of(DataSchemaBuilder.sysVersion),
            RawSql(' DESC'),
          ]),
          offset: offset ?? 0,
          limit: limit ?? -1,
        ),
      );

      return result.map((row) {
        final data = mapResultRowToRelation<TData>(
          revisionView as PostgresqlRelation,
          bean,
          row,
        );
        return _mapRevision(row, data);
      }).toList();
    });
  }

  @override
  Future<RevisionData<TData>?> revisableReadById(id, {int? version}) async {
    return await find(postgresql).runTransaction((context) async {
      final pg.Result result;
      if (version != null) {
        result = await context.execute(
          SqlSelect(
            SqlQualifiedRelation(read(schemaName), revisionTable.name),
            [SqlWildcard()],
            where: Sql.join([
              buildFilterSql(
                identityFilter(bean, id),
                dataView.attributes.map((e) => (e, revisionTable)),
              )!..wrap(),
              RawSql(' AND '),
              SqlTypedColumnAttribute.of(DataSchemaBuilder.sysVersion),
              RawSql(' = '),
              ParameterSql(version, const PostgresqlInt()),
            ]),
            limit: 1,
          ),
        );
      } else {
        result = await context.execute(
          SqlSelect(
            SqlQualifiedRelation(read(schemaName), revisionView.name),
            [SqlWildcard()],
            where: buildFilterSql(
              identityFilter(bean, id),
              dataView.attributes.map((e) => (e, revisionView)),
            ),
            limit: 1,
          ),
        );
      }

      if (result.isNotEmpty) {
        final data = mapResultRowToRelation<TData>(
          revisionView as PostgresqlRelation,
          bean,
          result.first,
        );
        return _mapRevision(result.first, data);
      } else {
        return null;
      }
    });
  }

  @override
  Future<R> atomic<R>(Future<R> Function() delegate) async {
    return await find(
      postgresql,
    ).runTransaction((context) async => await delegate());
  }

  RevisionData<TData> _mapRevision(pg.ResultRow result, TData data) {
    dynamic getValue(PostgresqlAttribute attribute) =>
        result[result.schema.columns.indexWhere(
          (e) => e.columnName == attribute.name,
        )];

    return RevisionData(
      data: data,
      version: getValue(DataSchemaBuilder.sysVersion),
      created: getValue(DataSchemaBuilder.sysCreated),
      creator: getValue(DataSchemaBuilder.sysCreator),
      from: getValue(DataSchemaBuilder.sysFrom),
      to: getValue(DataSchemaBuilder.sysTo),
      isDeleted: getValue(DataSchemaBuilder.sysIsDeleted),
    );
  }
}
