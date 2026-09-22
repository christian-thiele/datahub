import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/services.dart';
import 'package:meta/meta.dart';
import 'package:postgres/postgres.dart' as pg;

import 'data_utils.dart';
import 'postgresql_data_attribute.dart';
import 'postgresql_data_relation.dart';
import 'revisable/revisable_layout.dart';
import 'revisable/revisable_promoter.dart';
import 'revisable/revisable_statements.dart';

/// [RevisableDataRepository] implementation for PostgreSQL.
///
/// The current state of all elements is stored in a regular table named
/// after the bean (or the `relationName` config). It contains exactly one
/// row per existing element plus the metadata columns `sys_version`,
/// `sys_creator`, `sys_created` and `sys_from`. Reads, filters, joins and
/// indices perform like on a non-revisioned table. Indices and constraints
/// on that table can be created with plain SQL.
///
/// All revisions (including scheduled ones and deletions) are appended to
/// `<name>_history`. Revisions scheduled for the future (`from`) are queued
/// in `<name>_schedule` and applied to the current state when they become
/// effective, by every instance running this repository. Instances are
/// notified about new schedules via `pg_notify`; [schedulePollInterval] is
/// a fallback only.
///
/// Requirements and caveats:
///  * Transactions must use READ COMMITTED (the default).
///  * Foreign keys referencing the current state table must use
///    `NO ACTION` or `RESTRICT`, since cascading actions would change other
///    tables without revisions.
///  * A scheduled revision violating a constraint of the current state
///    table is skipped (and logged) until a later revision supersedes it.
///  * Writes hold one advisory lock per element until the transaction ends.
///    Transactions writing many thousands of elements one by one may exceed
///    `max_locks_per_transaction`; use [updateAll] / [deleteAll] instead.
///
/// Databases using the view based layout of earlier versions (`<name>` view
/// on `<name>_revision`) are migrated on initialization. Instances running
/// an earlier version must be stopped before.
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

  /// Maximum time between checks for due scheduled revisions.
  Config<Duration> get schedulePollInterval => const Config<Duration>(
    'schedulePollInterval',
    defaultValue: Duration(seconds: 30),
  );

  /// Maximum number of elements promoted per transaction.
  Config<int> get promotionBatchSize =>
      const Config<int>('promotionBatchSize', defaultValue: 500);

  Find<Postgresql> get postgresql => const Find<Postgresql>();

  @override
  DataBean<TData> get bean;

  late final RevisableLayout<TData> _layout;
  late final RevisableStatements<TData> _statements;
  RevisablePromoter? _promoter;

  /// Relation containing the current state, one row per element.
  late final PostgresqlDataTable<TData> dataRelation;

  /// Table containing the current state, one row per element.
  PostgresqlTable get currentTable => _layout.currentTable;

  /// Append-only table containing all revisions.
  PostgresqlTable get historyTable => _layout.historyTable;

  /// Table queueing revisions that become effective in the future.
  PostgresqlTable get scheduleTable => _layout.scheduleTable;

  @visibleForTesting
  RevisableStatements<TData> get statements => _statements;

  @override
  Future<void> initialize() async {
    await super.initialize();

    _layout = RevisableLayout(
      bean: bean,
      schemaName: read(schemaName),
      baseName:
          read(relationName) ??
          toNamingConvention(bean.name, NamingConvention.lowerSnakeCase),
    );
    _statements = RevisableStatements(_layout);
    dataRelation = PostgresqlDataTable.fromTable(
      bean: bean,
      table: _layout.currentTable,
    );

    await find(postgresql).runTransaction(_layout.setup);

    final promoter = _promoter = RevisablePromoter(
      postgresql: find(postgresql),
      statements: _statements,
      pollInterval: read(schedulePollInterval),
      batchSize: read(promotionBatchSize),
      runInContext: context.run,
    );
    await promoter.start();
  }

  @override
  Future<void> dispose() async {
    await _promoter?.dispose();
    await super.dispose();
  }

  /// Applies all scheduled revisions that are due to the current state.
  Future<int> promoteDue() async {
    return await (_promoter ?? (throw StateError('Not initialized.')))
        .promoteDue();
  }

  @override
  Future<RevisionData<TData>> createRevision(
    TData data, {
    DateTime? from,
    required int type,
  }) async {
    if (from?.isBefore(DateTime.timestamp()) ?? false) {
      throw ApiRequestException(400, 'Cannot create revision in the past.');
    }

    final creator = _requireIdentity();
    final givenId = bean.requireIdField.valueOf(data);

    return await find(postgresql).runTransaction((db) async {
      final Object id;
      final DateTime now;
      final ({int version, bool isDeleted})? head;

      if (_layout.idIsAuto &&
          type > 0 &&
          (givenId == null ||
              !((await db.execute(
                    _statements.hasRevisions(givenId),
                  )).first.first
                  as bool))) {
        // new element: nobody else can know the new id, no lock required
        final row = (await db.execute(_statements.allocateId())).first;
        id = row[0] as Object;
        now = row[1] as DateTime;
        head = null;
      } else {
        id = typedId(bean, givenId) as Object;
        await db.execute(_statements.lockElement(id));
        final row = (await db.execute(_statements.head(id))).first;
        now = row[0] as DateTime;
        head = switch (row[1]) {
          final int version => (version: version, isDeleted: row[2] as bool),
          _ => null,
        };
      }

      if (type < 1 && (head?.isDeleted ?? true)) {
        throw RevisableInconsistencyException('Element does not exist.');
      }

      if (type > 0 && !(head?.isDeleted ?? true)) {
        throw RevisableInconsistencyException('Element already exists.');
      }

      final scheduledFrom = from != null && from.isAfter(now) ? from : null;
      final result = await db.execute(
        _statements.writeRevision(
          data,
          id: id,
          version: (head?.version ?? -1) + 1,
          creator: creator,
          isDeleted: type < 0,
          scheduledFrom: scheduledFrom,
        ),
      );

      if (scheduledFrom != null) {
        await db.execute(_statements.notify());
      }

      return _mapRevisions(result, _layout.historyTable).single;
    });
  }

  @override
  Future<List<RevisionData<TData>>> revisableReadAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
  }) async {
    if (filter.isNothing) {
      return [];
    }

    return await find(postgresql).runTransaction((db) async {
      final result = await db.execute(
        _statements.selectCurrent(
          filter: filter,
          sort: sort,
          offset: offset ?? 0,
          limit: limit ?? -1,
        ),
      );
      return _mapRevisions(result, _layout.currentTable);
    });
  }

  @override
  Future<RevisionData<TData>?> revisableReadById(id, {int? version}) async {
    return await find(postgresql).runTransaction((db) async {
      final result = await db.execute(
        version != null
            ? _statements.selectRevision(id, version)
            : _statements.selectCurrent(
                filter: identityFilter(bean, id),
                limit: 1,
              ),
      );
      return _mapRevisions(
        result,
        version != null ? _layout.historyTable : _layout.currentTable,
      ).firstOrNull;
    });
  }

  @override
  Future<List<RevisionData<TData>>> readRevisionsById(
    id, {
    int? offset,
    int? limit,
  }) async {
    return await find(postgresql).runTransaction((db) async {
      final result = await db.execute(
        _statements.selectRevisions(
          id,
          offset: offset ?? 0,
          limit: limit ?? -1,
        ),
      );
      return _mapRevisions(result, _layout.historyTable);
    });
  }

  @override
  Future<int> count({Filter filter = Filter.empty}) async {
    if (filter.isNothing) {
      return 0;
    }

    return await find(postgresql).runTransaction((db) async {
      final result = await dataRelation.select(db, [
        AggregateExpression.count(),
      ], filter: filter);
      return result.firstOrNull?.values.firstOrNull ?? 0;
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
    if (filter.isNothing) {
      return false;
    }

    return await find(postgresql).runTransaction((db) async {
      final result = await dataRelation.select(
        db,
        [ValueExpression(1)],
        filter: filter,
        limit: 1,
      );
      return result.isNotEmpty;
    });
  }

  /// Creates a revision with [values] applied for every element matching
  /// [filter], effective immediately. Behaves like calling [updateById] for
  /// each element (elements with a scheduled deletion are skipped), but
  /// atomic and set based.
  ///
  /// Blocks all other writes to this repository until the transaction ends.
  @override
  Future<int> updateAll({
    required Filter filter,
    required Map<DataField<TData, dynamic>, dynamic> values,
  }) async {
    if (values.keys.any((e) => e.name == bean.requireIdField.name)) {
      throw ArgumentError.value(
        values,
        'values',
        'The id field of revisable elements cannot be updated.',
      );
    }

    if (filter.isNothing || values.isEmpty) {
      return 0;
    }

    final creator = _requireIdentity();
    return await find(postgresql).runTransaction((db) async {
      await db.execute(_statements.lockRelationExclusive());
      final result = await db.execute(
        _statements.bulkUpdate(filter, values, creator: creator),
      );
      return result.first.first as int;
    });
  }

  /// Creates a deletion revision for every element matching [filter],
  /// effective immediately. Behaves like calling [deleteById] for each
  /// element (elements with a scheduled deletion are skipped), but atomic
  /// and set based.
  ///
  /// Blocks all other writes to this repository until the transaction ends.
  @override
  Future<int> deleteAll({required Filter filter}) async {
    if (filter.isNothing) {
      return 0;
    }

    final creator = _requireIdentity();
    return await find(postgresql).runTransaction((db) async {
      await db.execute(_statements.lockRelationExclusive());
      final result = await db.execute(
        _statements.bulkDelete(filter, creator: creator),
      );
      return result.first.first as int;
    });
  }

  @override
  Future<R> atomic<R>(Future<R> Function() delegate) async {
    return await find(
      postgresql,
    ).runTransaction((context) async => await delegate());
  }

  String _requireIdentity() {
    return Context.zoneSession()?.identity ??
        (throw ApiRequestException.unauthorized('Identity session required.'));
  }

  List<RevisionData<TData>> _mapRevisions(
    pg.Result result,
    PostgresqlTable table,
  ) {
    final columns = result.schema.columns;
    int indexOf(String name) =>
        columns.indexWhere((column) => column.columnName == name);

    final fields = [
      for (final attribute
          in table.attributes.whereType<PostgresqlDataAttribute>())
        (attribute, indexOf(attribute.name)),
    ];
    final version = indexOf(RevisableLayout.sysVersion.name);
    final creator = indexOf(RevisableLayout.sysCreator.name);
    final created = indexOf(RevisableLayout.sysCreated.name);
    final from = indexOf(RevisableLayout.sysFrom.name);
    final to = indexOf(RevisableLayout.sysTo.name);
    final isDeleted = indexOf(RevisableLayout.sysIsDeleted.name);

    return [
      for (final row in result)
        RevisionData(
          data: bean.fromValues({
            for (final (attribute, index) in fields)
              attribute.field.name: attribute.type.decode(row[index]),
          }),
          version: row[version] as int,
          creator: row[creator] as String? ?? '',
          created: row[created] as DateTime,
          from: row[from] as DateTime,
          to: to < 0 ? null : row[to] as DateTime?,
          isDeleted: isDeleted >= 0 && row[isDeleted] as bool,
        ),
    ];
  }
}
