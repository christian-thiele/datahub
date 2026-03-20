import 'package:datahub/datahub.dart';

import 'dart:async';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/services.dart';
import 'package:datahub_postgres/types.dart';
import 'package:postgres/postgres.dart' as pg;

import 'abstract/revision_data.dart';

mixin PostgresqlRevisableRepository<
  TService extends Service,
  TData extends DataObject<TData>
>
    on ServiceInstance<TService> {
  Config<String> get schemaName =>
      const Config<String>('schemaName', defaultValue: 'public');

  Find<Postgresql> get postgresql => const Find<Postgresql>();

  DataBean<TData> get bean;

  late final PostgresqlDataAttribute _primaryAttribute;
  late final PostgresqlTable revisionTable;
  late final PostgresqlView revisionView;
  late final PostgresqlDataView<TData> dataView;

  static const _sysVersion = PostgresqlAttribute(
    name: 'sys_version',
    type: PostgresqlInt(),
    constraints: [NotNullConstraint()],
  );

  static const _sysCreator = PostgresqlAttribute(
    name: 'sys_creator',
    type: PostgresqlString(),
  );

  static final _sysCreated = PostgresqlAttribute(
    name: 'sys_created',
    type: const PostgresqlDateTime(),
    constraints: [
      const NotNullConstraint(),
      DefaultConstraint(RawSql('now()')),
    ],
  );

  static final _sysFrom = PostgresqlAttribute(
    name: 'sys_from',
    type: const PostgresqlDateTime(),
    constraints: [
      const NotNullConstraint(),
      DefaultConstraint(RawSql('now()')),
    ],
  );

  static final _sysTo = PostgresqlAttribute(
    name: 'sys_to',
    type: const PostgresqlDateTime(),
  );

  static final _sysIsDeleted = PostgresqlAttribute(
    name: 'sys_is_deleted',
    type: const PostgresqlBool(),
    constraints: [
      const NotNullConstraint(),
      DefaultConstraint(ParameterSql(false, const PostgresqlBool())),
    ],
  );

  @override
  FutureOr<void> initialize() async {
    await super.initialize();
    final effectiveSchemaName = read(schemaName);

    await find(postgresql).runTransaction((context) async {
      final relationName = toNamingConvention(
        bean.name,
        NamingConvention.lowerSnakeCase,
      );
      final sequenceFields = bean.fields.where(
        (e) => e.type.isExact<int>() && e.hasMetaOfType<Id>((id) => id.auto),
      );
      final uuidFields = bean.fields.where(
        (e) => e.type.isExact<String>() && e.hasMetaOfType<Id>((id) => id.auto),
      );

      for (final sequence in sequenceFields) {
        await PostgresqlSequence(
          schemaName: effectiveSchemaName,
          name: '${relationName}_${sequence.name}_seq',
        ).ensureRelation(context);
      }

      final beanFieldAttributes = {
        for (final field in bean.fields)
          field: PostgresqlDataAttribute(
            field: field,
            name: toNamingConvention(
              field.name,
              NamingConvention.lowerSnakeCase,
            ),
            type: PostgresqlDataType.findForDataField(field),
            constraints: [
              if (sequenceFields.contains(field))
                DefaultConstraint(
                  Sql.function('nextval', [
                    Sql.text(
                      '$effectiveSchemaName.${relationName}_${field.name}_seq',
                    ),
                  ]),
                ),
              if (uuidFields.contains(field))
                DefaultConstraint(RawSql('gen_random_uuid()')),
              if (field is DataField<dynamic, Object>) NotNullConstraint(),
            ],
          ),
      };

      revisionTable = PostgresqlTable(
        schemaName: effectiveSchemaName,
        name: '${relationName}_revision',
        attributes: [
          _sysVersion,
          _sysCreator,
          _sysCreated,
          _sysFrom,
          _sysTo,
          _sysIsDeleted,

          for (final field in bean.fields)
            PostgresqlDataAttribute(
              field: field,
              name: toNamingConvention(
                field.name,
                NamingConvention.lowerSnakeCase,
              ),
              type: PostgresqlDataType.findForDataField(field),
              constraints: [
                if (sequenceFields.contains(field))
                  DefaultConstraint(
                    Sql.function('nextval', [
                      Sql.text(
                        '$effectiveSchemaName.${relationName}_${field.name}_seq',
                      ),
                    ]),
                  ),
                if (uuidFields.contains(field))
                  DefaultConstraint(RawSql('gen_random_uuid()')),
                if (field is DataField<dynamic, Object>) NotNullConstraint(),
              ],
            ),
        ],
        constraints: [
          if (bean.idField case final idField?)
            UniqueTableConstraint(
              attributes: [beanFieldAttributes[idField]!, _sysVersion],
            ),
        ],
      );

      _primaryAttribute = revisionTable.attributes
          .whereType<PostgresqlDataAttribute>()
          .firstWhere((e) => e.field == bean.requireIdField);

      revisionView = PostgresqlView(
        schemaName: effectiveSchemaName,
        name: relationName,
        select: SqlSelect(
          SqlQualifiedRelation(effectiveSchemaName, revisionTable.name),
          [SqlWildcard()],
          where: RawSql('"sys_to" IS NULL AND NOT "sys_is_deleted"'),
        ),
        attributes: revisionTable.attributes,
      );

      await revisionTable.ensureRelation(context);
      await revisionView.ensureRelation(context);

      dataView = PostgresqlDataView(
        bean: bean,
        schemaName: revisionView.schemaName,
        name: revisionView.name,
        select: revisionView.select,
      );
    });
  }

  Future<RevisionData<TData>> createRevisionDeletedId(
    dynamic id, {
    required String creator,
    DateTime? from,
  }) async {
    return await find(postgresql).runTransaction((context) async {
      final data = await getRevisable(id);
      if (data != null) {
        return await createRevision(
          data.data,
          creator: creator,
          from: from,
          isDeleted: true,
        );
      } else {
        throw ApiRequestException.notFound();
      }
    });
  }

  Future<RevisionData<TData>> createRevision(
    TData data, {
    required String creator,
    DateTime? from,
    bool isDeleted = false,
  }) async {
    return await find(postgresql).runTransaction((context) async {
      final now = DateTime.timestamp();
      if (from?.isBefore(now) ?? false) {
        throw ApiRequestException(400, 'Cannot create revision in the past.');
      }
      final effectiveFrom = from ?? now;

      final idField = bean.idField ?? (throw MissingIdFieldError(bean));
      final primaryKey = idField.valueOf(data);

      final currentRevision = primaryKey != null
          ? await getRevisable(primaryKey)
          : null;

      final currentVersion = currentRevision?.sysVersion ?? -1;

      final primaryIsAuto = _primaryAttribute.field.hasMetaOfType<Id>(
        (id) => id.auto,
      );

      // TODO check if other defaults should be respected here
      final nonAutoAttributes = revisionTable.attributes
          .whereType<PostgresqlDataAttribute>()
          .where((e) => !(primaryIsAuto && e == _primaryAttribute));

      final result = await context.execute(
        SqlInsert(
          SqlQualifiedRelation(read(schemaName), revisionTable.name),
          {
            SqlTypedAttribute.of(_sysVersion): currentVersion + 1,
            SqlTypedAttribute.of(_sysCreator): creator,
            SqlTypedAttribute.of(_sysFrom): effectiveFrom,
            SqlTypedAttribute.of(_sysIsDeleted): isDeleted,

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
          ],
        ),
      );

      if (currentRevision != null) {
        await context.execute(
          SqlUpdate(
            SqlQualifiedRelation(read(schemaName), revisionTable.name),
            Sql.join([
              ?buildFilterSql(
                identityFilter(bean, primaryKey),
                dataView.attributes.map((e) => (e, revisionTable)),
              ),
              RawSql(' AND sys_version = $currentVersion'),
            ]),
            {SqlTypedAttribute.of(_sysTo): effectiveFrom},
          ),
        );
      }

      return await getRevisable(
            result.first.first,
            version: currentVersion + 1,
          ) ??
          (throw ApiException('Could not retrieve object from database.'));
    });
  }

  Future<List<RevisionData<TData>>> getAllRevisable({
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

  Future<int> count({Filter filter = Filter.empty}) async {
    return await find(postgresql).runTransaction((context) async {
      // TODO aggregates should be abstract
      final result = await dataView.select(context, [
        PostgresqlRawExpression(RawSql('COUNT(*) as "count"')),
      ], filter: filter);
      return result.firstOrNull?['count'] ?? 0;
    });
  }

  Future<List<RevisionData<TData>>> getRevisions(
    dynamic id, {
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
            SqlColumnAttribute('revision_timestamp').toSql(),
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

  Future<RevisionData<TData>?> getRevisable(dynamic id, {int? version}) async {
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
              RawSql(' AND sys_version = '),
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
      sysVersion: getValue(_sysVersion),
      sysCreated: getValue(_sysCreated),
      sysCreator: getValue(_sysCreator),
      sysFrom: getValue(_sysFrom),
      sysTo: getValue(_sysTo),
      sysIsDeleted: getValue(_sysIsDeleted),
    );
  }
}
