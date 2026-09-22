import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';

import '../data_utils.dart';
import '../postgresql_data_attribute.dart';
import 'revisable_layout.dart';

/// SQL statements of a revisable repository.
///
/// Locking protocol (all locks are transaction scoped advisory locks):
///
/// * The relation lock is held shared by single element writes and by
///   promotions and exclusively by bulk writes ([bulkUpdate], [bulkDelete]).
/// * The element lock serializes all changes of an element's current row and
///   schedule entries. Writers wait for it, promotions only try to acquire it
///   and skip elements that are locked.
///
/// Reads never lock.
class RevisableStatements<TData extends DataObject<TData>> {
  /// Channel notified when a revision is scheduled. Payload is
  /// [RevisableLayout.key].
  static const notificationChannel = 'datahub_revisable';

  static const _dbNow = RevisableLayout.dbNow;
  static const _sysVersion = RevisableLayout.sysVersion;
  static const _sysCreator = RevisableLayout.sysCreator;
  static const _sysCreated = RevisableLayout.sysCreated;
  static const _sysFrom = RevisableLayout.sysFrom;
  static const _sysIsDeleted = RevisableLayout.sysIsDeleted;

  final RevisableLayout<TData> layout;

  RevisableStatements(this.layout);

  DataBean<TData> get bean => layout.bean;

  SqlQualifiedRelation get _history =>
      SqlQualifiedRelation.of(layout.historyTable);

  SqlQualifiedRelation get _current =>
      SqlQualifiedRelation.of(layout.currentTable);

  SqlQualifiedRelation get _schedule =>
      SqlQualifiedRelation.of(layout.scheduleTable);

  String get _historyName => layout.historyTable.name;

  String get _currentName => layout.currentTable.name;

  String get _scheduleName => layout.scheduleTable.name;

  Sql _idParam(dynamic id) => ParameterSql(id, layout.historyId.type);

  SqlColumnAttribute _column(
    PostgresqlAttribute attribute, [
    String? relation,
  ]) => SqlColumnAttribute(attribute.name, relation: relation);

  Iterable<(PostgresqlDataAttribute, PostgresqlRelation)>
  get _historyFilterAttributes =>
      layout.historyDataAttributes.map((e) => (e, layout.historyTable));

  Iterable<(PostgresqlDataAttribute, PostgresqlRelation)>
  get _currentFilterAttributes =>
      layout.currentDataAttributes.map((e) => (e, layout.currentTable));

  // ---------------------------------------------------------------------------
  // locks

  Sql get _relationLockKey => Sql.function('hashtextextended', [
    Sql.text('datahub.revisable.rel:${layout.key}'),
    RawSql('0'),
  ]);

  Sql _elementLockKey(Sql id) => Sql.join([
    Sql.function('hashtext', [Sql.text(layout.key)]),
    RawSql(', '),
    Sql.function('hashtext', [Sql.cast(id, const PostgresqlText())]),
  ]);

  /// Waits for the shared relation lock and the element lock of [id].
  ///
  /// Must be a statement of its own: under READ COMMITTED, the snapshot of a
  /// statement is taken before it waits, so reads of the same statement
  /// could miss changes committed while waiting.
  Sql lockElement(dynamic id) => Sql.join([
    RawSql('SELECT pg_advisory_xact_lock_shared('),
    _relationLockKey,
    RawSql('), pg_advisory_xact_lock('),
    _elementLockKey(_idParam(id)),
    RawSql(')'),
  ]);

  /// Tries to acquire the element lock of [id] without waiting.
  Sql tryLockElement(dynamic id) => Sql.join([
    RawSql('SELECT pg_try_advisory_xact_lock('),
    _elementLockKey(_idParam(id)),
    RawSql(')'),
  ]);

  /// Waits for the exclusive relation lock (bulk writes).
  Sql lockRelationExclusive() => Sql.join([
    RawSql('SELECT pg_advisory_xact_lock('),
    _relationLockKey,
    RawSql(')'),
  ]);

  /// Tries to acquire the shared relation lock without waiting.
  Sql tryLockRelationShared() => Sql.join([
    RawSql('SELECT pg_try_advisory_xact_lock_shared('),
    _relationLockKey,
    RawSql(')'),
  ]);

  // ---------------------------------------------------------------------------
  // single element writes

  /// `SELECT EXISTS(...)`: true if any revision of [id] exists.
  Sql hasRevisions(dynamic id) => Sql.join([
    RawSql('SELECT EXISTS (SELECT 1 FROM '),
    _history,
    RawSql(' WHERE '),
    buildFilterSql(identityFilter(bean, id), _historyFilterAttributes)!,
    RawSql(')'),
  ]);

  /// Allocates a new id: `SELECT <id>, <now>`.
  Sql allocateId() => Sql.join([
    RawSql('SELECT '),
    if (layout.idSequence case final sequence?)
      Sql.function('nextval', [
        Sql.text(layout.qualifiedName(sequence.name).toString()),
      ])
    else
      RawSql('gen_random_uuid()::varchar'),
    RawSql(', '),
    _dbNow,
  ]);

  /// Reads the database time and the latest revision (including scheduled
  /// ones): `SELECT <now>, <version>?, <is deleted>?`.
  Sql head(dynamic id) => Sql.join([
    RawSql('SELECT '),
    _dbNow,
    RawSql(
      ', "h"."sys_version", "h"."sys_is_deleted" FROM (SELECT 1) AS "one" ',
    ),
    RawSql('LEFT JOIN LATERAL (SELECT "sys_version", "sys_is_deleted" FROM '),
    _history,
    RawSql(' WHERE '),
    buildFilterSql(identityFilter(bean, id), _historyFilterAttributes)!,
    RawSql(' ORDER BY "sys_version" DESC LIMIT 1) AS "h" ON true'),
  ]);

  /// Appends a revision to history and applies it.
  ///
  /// Without [scheduledFrom], the revision is effective immediately: the
  /// current state is updated (or deleted for tombstones) and all scheduled
  /// revisions of the element are superseded.
  ///
  /// With [scheduledFrom], the revision is queued. Scheduled revisions that
  /// would become effective at or after [scheduledFrom] are superseded.
  ///
  /// Returns the inserted history row.
  Sql writeRevision(
    TData data, {
    required dynamic id,
    required int version,
    required String creator,
    required bool isDeleted,
    DateTime? scheduledFrom,
  }) {
    final insert = SqlInsert(
      _history,
      {
        SqlTypedAttribute.of(_sysVersion): version,
        SqlTypedAttribute.of(_sysCreator): creator,
        SqlTypedAttribute.of(_sysCreated): _dbNow,
        SqlTypedAttribute.of(_sysFrom): scheduledFrom ?? _dbNow,
        SqlTypedAttribute.of(_sysIsDeleted): isDeleted,
        for (final attribute in layout.historyDataAttributes)
          SqlTypedAttribute.of(
            attribute,
          ): identical(attribute, layout.historyId)
              ? id
              : attribute.field.valueOf(data),
      },
      returning: [SqlWildcard()],
    );

    final scheduleOfElement = Sql.join([
      _column(layout.scheduleId),
      RawSql(' = '),
      _idParam(id),
    ]);

    return SqlWith([
      SqlCte('ins', insert),
      if (scheduledFrom case final from?) ...[
        SqlCte(
          'dq',
          SqlDelete(
            _schedule,
            Sql.join([
              scheduleOfElement,
              RawSql(' AND "sys_from" >= '),
              ParameterSql(from, const PostgresqlDateTime()),
            ]),
          ),
        ),
        SqlCte(
          'enq',
          SqlInsertSelect(
            _schedule,
            [
              SqlColumnAttribute(layout.scheduleId.name),
              SqlColumnAttribute(_sysVersion.name),
              SqlColumnAttribute(_sysFrom.name),
            ],
            SqlSelect(Sql.name('ins'), [
              SqlColumnAttribute(layout.historyId.name),
              SqlColumnAttribute(_sysVersion.name),
              SqlColumnAttribute(_sysFrom.name),
            ]),
          ),
        ),
      ] else ...[
        SqlCte('dq', SqlDelete(_schedule, scheduleOfElement)),
        if (isDeleted)
          SqlCte('dc', _deleteCurrent('ins'))
        else
          SqlCte('up', _upsertCurrent('ins')),
      ],
    ], SqlSelect(Sql.name('ins'), [SqlWildcard()]));
  }

  /// Wakes up promoters of all instances when the transaction commits.
  Sql notify() => Sql.join([
    RawSql('SELECT pg_notify('),
    Sql.text(notificationChannel),
    RawSql(', '),
    Sql.text(layout.key),
    RawSql(')'),
  ]);

  /// Inserts or updates current rows from history rows in [source] (live
  /// revisions only), unless the current row is of a later version.
  Sql _upsertCurrent(String source, {bool skipTombstones = false}) {
    final columns = [
      for (final attribute in layout.currentTable.attributes)
        SqlColumnAttribute(attribute.name),
    ];

    return SqlInsertSelect(
      _current,
      columns,
      SqlSelect(
        Sql.name(source),
        columns,
        where: skipTombstones
            ? RawSql('NOT ') + _column(_sysIsDeleted, source)
            : null,
      ),
      onConflict: SqlOnConflict.doUpdate(
        [SqlColumnAttribute(layout.currentId.name)],
        {
          for (final attribute in layout.currentTable.attributes)
            if (!identical(attribute, layout.currentId))
              SqlColumnAttribute(attribute.name): SqlOnConflict.excluded(
                attribute,
              ),
        },
        where: Sql.join([
          _column(_sysVersion, _currentName),
          RawSql(' < '),
          _column(_sysVersion, 'excluded'),
        ]),
      ),
    );
  }

  /// Deletes current rows of elements whose revision in [source] is later.
  Sql _deleteCurrent(String source, {bool onlyTombstones = false}) {
    return SqlDelete(
      _current,
      Sql.join([
        _column(layout.currentId, _currentName),
        RawSql(' = '),
        _column(layout.historyId, source),
        RawSql(' AND '),
        _column(_sysVersion, _currentName),
        RawSql(' < '),
        _column(_sysVersion, source),
        if (onlyTombstones) ...[
          RawSql(' AND '),
          _column(_sysIsDeleted, source),
        ],
      ]),
      using: Sql.name(source),
    );
  }

  // ---------------------------------------------------------------------------
  // promotion of scheduled revisions

  /// Ids of up to [limit] elements with due schedule entries, locked for this
  /// transaction. Elements locked by others are skipped.
  Sql dueIds(int limit) {
    final id = Sql.name(layout.scheduleId.name);
    return Sql.join([
      RawSql('SELECT "d".'),
      id,
      RawSql(' FROM (SELECT DISTINCT '),
      id,
      RawSql(' FROM '),
      _schedule,
      RawSql(' WHERE "sys_from" <= '),
      _dbNow,
      RawSql(' AND "sys_failed_at" IS NULL LIMIT '),
      ParameterSql(limit, const PostgresqlInt()),
      RawSql(') AS "d" WHERE pg_try_advisory_xact_lock('),
      _elementLockKey(RawSql('"d".') + id),
      RawSql(')'),
    ]);
  }

  /// Applies the latest due schedule entry of each element in [ids] and
  /// removes all due entries of those elements.
  ///
  /// The elements must be locked by the transaction. Returns the number of
  /// elements: `SELECT count`.
  Sql promote(List<Object> ids) {
    final id = layout.scheduleId.name;
    final idsParam = switch (layout.scheduleId.type) {
      PostgresqlInt() => ParameterSql<List<int>>(
        ids.cast<int>().toList(),
        const PostgresqlIntArray(),
      ),
      _ => ParameterSql<List<String>>(
        ids.cast<String>().toList(),
        const PostgresqlStringArray(),
      ),
    };

    return SqlWith([
      SqlCte(
        'due',
        SqlDelete(
          _schedule,
          Sql.join([
            Sql.name(id),
            RawSql(' = ANY('),
            idsParam,
            RawSql(') AND "sys_from" <= '),
            _dbNow,
          ]),
          returning: [
            SqlColumnAttribute(id),
            SqlColumnAttribute(_sysVersion.name),
          ],
        ),
      ),
      SqlCte(
        'win',
        SqlSelect(
          Sql.name('due'),
          [SqlColumnAttribute(id), SqlColumnAttribute(_sysVersion.name)],
          distinctOn: SqlColumnAttribute(id),
          order: Sql.name(id) + RawSql(', "sys_version" DESC'),
        ),
      ),
      SqlCte(
        'src',
        SqlSelect(
          Sql.join([
            RawSql('"win" JOIN '),
            _history,
            RawSql(' ON '),
            _column(layout.historyId, _historyName),
            RawSql(' = "win".'),
            Sql.name(id),
            RawSql(' AND '),
            _column(_sysVersion, _historyName),
            RawSql(' = "win"."sys_version"'),
          ]),
          [SqlWildcard(relation: _historyName)],
        ),
      ),
      SqlCte('up', _upsertCurrent('src', skipTombstones: true)),
      SqlCte('dc', _deleteCurrent('src', onlyTombstones: true)),
    ], RawSql('SELECT count(*) FROM "win"'));
  }

  /// Next time a schedule entry becomes due and the current database time:
  /// `SELECT <next>?, <now>`.
  Sql nextDue() => Sql.join([
    RawSql('SELECT min("sys_from"), '),
    _dbNow,
    RawSql(' FROM '),
    _schedule,
    RawSql(' WHERE "sys_failed_at" IS NULL'),
  ]);

  /// Marks the due schedule entries of [id] as failed, so promotion skips
  /// them until a later revision supersedes them.
  Sql markFailed(dynamic id, String error) => SqlUpdate(
    _schedule,
    Sql.join([
      _column(layout.scheduleId),
      RawSql(' = '),
      _idParam(id),
      RawSql(' AND "sys_from" <= '),
      _dbNow,
      RawSql(' AND "sys_failed_at" IS NULL'),
    ]),
    {
      SqlTypedAttribute.of(RevisableLayout.sysFailedAt): _dbNow,
      SqlTypedAttribute.of(RevisableLayout.sysError): error,
    },
  );

  // ---------------------------------------------------------------------------
  // reads

  /// Current state including revision metadata.
  ///
  /// `sys_to` is the time the next scheduled revision becomes effective. It
  /// is only computed for the selected page.
  Sql selectCurrent({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
    int limit = -1,
  }) {
    final page = SqlSelect(
      _current,
      [
        for (final attribute in layout.currentTable.attributes)
          SqlColumnAttribute(attribute.name, relation: _currentName),
      ],
      where: buildFilterSql(filter, _currentFilterAttributes),
      order: buildSortSql(sort, _currentFilterAttributes),
      offset: offset,
      limit: limit,
    );

    final scheduledTo = Sql.join([
      RawSql('(SELECT min('),
      _column(_sysFrom, _scheduleName),
      RawSql(') FROM '),
      _schedule,
      RawSql(' WHERE '),
      _column(layout.scheduleId, _scheduleName),
      RawSql(' = '),
      _column(layout.currentId, _currentName),
      RawSql(' AND '),
      _column(RevisableLayout.sysFailedAt, _scheduleName),
      RawSql(' IS NULL) AS "sys_to"'),
    ]);

    return SqlSelect(page.wrap() + RawSql(' AS ') + Sql.name(_currentName), [
      SqlWildcard(relation: _currentName),
      RawSqlAttribute(scheduledTo),
    ], order: buildSortSql(sort, _currentFilterAttributes));
  }

  /// All revisions of [id], latest first.
  ///
  /// `sys_to` is the earliest `sys_from` of all later revisions, which is
  /// the time the revision stopped being effective (or would have, if it was
  /// superseded before becoming effective: `sys_to <= sys_from`).
  Sql selectRevisions(dynamic id, {int offset = 0, int limit = -1}) =>
      SqlSelect(
        _history,
        [
          ..._historyColumns(),
          RawSqlAttribute(
            RawSql(
              'min("sys_from") OVER (ORDER BY "sys_version" ROWS BETWEEN 1 '
              'FOLLOWING AND UNBOUNDED FOLLOWING) AS "sys_to"',
            ),
          ),
        ],
        where: buildFilterSql(
          identityFilter(bean, id),
          _historyFilterAttributes,
        ),
        order: RawSql('"sys_version" DESC'),
        offset: offset,
        limit: limit,
      );

  /// Revision [version] of [id].
  Sql selectRevision(dynamic id, int version) => SqlSelect(
    _history,
    [
      ..._historyColumns(),
      RawSqlAttribute(
        Sql.join([
          RawSql('(SELECT min("n"."sys_from") FROM '),
          _history,
          RawSql(' AS "n" WHERE "n".'),
          Sql.name(layout.historyId.name),
          RawSql(' = '),
          _column(layout.historyId, _historyName),
          RawSql(' AND "n"."sys_version" > '),
          _column(_sysVersion, _historyName),
          RawSql(') AS "sys_to"'),
        ]),
      ),
    ],
    where: Sql.join([
      buildFilterSql(identityFilter(bean, id), _historyFilterAttributes)!,
      RawSql(' AND '),
      _column(_sysVersion, _historyName),
      RawSql(' = '),
      ParameterSql(version, const PostgresqlInt()),
    ]),
  );

  Iterable<SqlAttribute> _historyColumns() => [
    for (final attribute in layout.historyTable.attributes)
      SqlColumnAttribute(attribute.name, relation: _historyName),
  ];

  // ---------------------------------------------------------------------------
  // bulk writes (require the exclusive relation lock)

  /// Creates an immediate revision with [values] applied for every current
  /// element matching [filter], unless its latest revision is a scheduled
  /// deletion. Returns the number of revisions: `SELECT count`.
  Sql bulkUpdate(
    Filter filter,
    Map<DataField, dynamic> values, {
    required String creator,
  }) {
    final updated = <PostgresqlDataAttribute, dynamic>{
      for (final (field, value) in values.tuples)
        layout.historyDataAttributes.firstWhere(
          (e) => e.field.name == field.name,
          orElse: () => throw ArgumentError.value(
            field.name,
            'values',
            'Field is not part of ${bean.name}.',
          ),
        ): value,
    };

    return _bulkWrite(
      filter,
      creator: creator,
      isDeleted: false,
      valueOf: (attribute) => updated.containsKey(attribute)
          ? ParameterSql(updated[attribute], attribute.type)
          : null,
      apply: SqlCte(
        'up',
        SqlUpdate(
          _current,
          Sql.join([
            _column(layout.currentId, _currentName),
            RawSql(' = '),
            _column(layout.historyId, 'ins'),
          ]),
          {
            for (final attribute in [
              _sysVersion,
              _sysCreator,
              _sysCreated,
              _sysFrom,
              ...layout.currentDataAttributes.where(
                (a) => updated.keys.any((u) => u.name == a.name),
              ),
            ])
              SqlTypedAttribute.of(attribute): _column(attribute, 'ins'),
          },
          from: Sql.name('ins'),
        ),
      ),
    );
  }

  /// Creates an immediate deletion revision for every current element
  /// matching [filter], unless its latest revision is a scheduled deletion.
  /// Returns the number of revisions: `SELECT count`.
  Sql bulkDelete(Filter filter, {required String creator}) => _bulkWrite(
    filter,
    creator: creator,
    isDeleted: true,
    valueOf: (_) => null,
    apply: SqlCte('dc', _deleteCurrent('ins')),
  );

  Sql _bulkWrite(
    Filter filter, {
    required String creator,
    required bool isDeleted,
    required Sql? Function(PostgresqlDataAttribute attribute) valueOf,
    required SqlCte apply,
  }) {
    final head = Sql.join([
      RawSql('(SELECT "sys_version", "sys_is_deleted" FROM '),
      _history,
      RawSql(' WHERE '),
      _column(layout.historyId, _historyName),
      RawSql(' = '),
      _column(layout.currentId, _currentName),
      RawSql(' ORDER BY "sys_version" DESC LIMIT 1) AS "h"'),
    ]);

    final source = SqlSelect(
      _current + RawSql(' CROSS JOIN LATERAL ') + head,
      [
        SqlWildcard(relation: _currentName),
        RawSqlAttribute(RawSql('"h"."sys_version" AS "sys_head_version"')),
      ],
      where: Sql.join([
        if (buildFilterSql(filter, _currentFilterAttributes) case final f?) ...[
          f.wrap(),
          RawSql(' AND '),
        ],
        RawSql('NOT "h"."sys_is_deleted"'),
      ]),
    );

    final historyColumns = [
      _sysVersion,
      _sysCreator,
      _sysCreated,
      _sysFrom,
      _sysIsDeleted,
      ...layout.historyDataAttributes,
    ];

    final insert = SqlInsertSelect(
      _history,
      [for (final attribute in historyColumns) _column(attribute)],
      SqlSelect(Sql.name('src'), [
        RawSqlAttribute(RawSql('"sys_head_version" + 1')),
        RawSqlAttribute(ParameterSql(creator, const PostgresqlString())),
        RawSqlAttribute(_dbNow),
        RawSqlAttribute(_dbNow),
        RawSqlAttribute(ParameterSql(isDeleted, const PostgresqlBool())),
        for (final attribute in layout.historyDataAttributes)
          RawSqlAttribute(valueOf(attribute) ?? _column(attribute)),
      ]),
      returning: [SqlWildcard()],
    );

    return SqlWith([
      SqlCte('src', source),
      SqlCte('ins', insert),
      SqlCte(
        'dq',
        SqlDelete(
          _schedule,
          Sql.join([
            _column(layout.scheduleId, _scheduleName),
            RawSql(' = '),
            _column(layout.historyId, 'ins'),
          ]),
          using: Sql.name('ins'),
        ),
      ),
      apply,
    ], RawSql('SELECT count(*) FROM "ins"'));
  }
}
