import 'dart:convert';

import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/services.dart';
import 'package:datahub_postgres/sql.dart';
import 'package:datahub_postgres/types.dart';

import '../postgresql_data_attribute.dart';

/// Physical layout of a revisable repository.
///
/// * `<base>` holds the current state: exactly one row per live element,
///   behaving like any non-revisioned table (indices, constraints, joins).
/// * `<base>_history` is the append-only log of all revisions, including
///   scheduled (future) revisions and deletions (tombstones).
/// * `<base>_schedule` queues scheduled revisions that are not effective yet
///   and are not superseded by a later revision.
///
/// The element state at time `t` is the revision with the highest version
/// whose `sys_from <= t`, or none if that revision is a tombstone.
class RevisableLayout<TData extends DataObject<TData>> {
  /// Current database time as UTC `timestamp`.
  // TODO rename to nowSql
  static const dbNow = RawSql("(statement_timestamp() AT TIME ZONE 'UTC')");

  static const sysVersion = PostgresqlAttribute(
    name: 'sys_version',
    type: PostgresqlInt(),
    constraints: [NotNullConstraint()],
  );

  static const sysCreator = PostgresqlAttribute(
    name: 'sys_creator',
    type: PostgresqlString(),
  );

  static const sysCreated = PostgresqlAttribute(
    name: 'sys_created',
    type: PostgresqlDateTime(),
    constraints: [NotNullConstraint(), DefaultConstraint(dbNow)],
  );

  static const sysFrom = PostgresqlAttribute(
    name: 'sys_from',
    type: PostgresqlDateTime(),
    constraints: [NotNullConstraint(), DefaultConstraint(dbNow)],
  );

  static const sysIsDeleted = PostgresqlAttribute(
    name: 'sys_is_deleted',
    type: PostgresqlBool(),
    constraints: [NotNullConstraint(), DefaultConstraint(RawSql('false'))],
  );

  /// Not stored, derived when reading revisions.
  static const sysTo = PostgresqlAttribute(
    name: 'sys_to',
    type: PostgresqlDateTime(),
  );

  static const sysFailedAt = PostgresqlAttribute(
    name: 'sys_failed_at',
    type: PostgresqlDateTime(),
  );

  static const sysError = PostgresqlAttribute(
    name: 'sys_error',
    type: PostgresqlText(),
  );

  static const _notNull = [NotNullConstraint()];

  final DataBean<TData> bean;
  final String schemaName;
  final String baseName;

  late final bool idIsAuto;
  late final PostgresqlSequence? idSequence;
  late final PostgresqlTable historyTable;
  late final PostgresqlTable currentTable;
  late final PostgresqlTable scheduleTable;
  late final PostgresqlDataAttribute historyId;
  late final PostgresqlDataAttribute currentId;
  late final PostgresqlAttribute scheduleId;

  RevisableLayout({
    required this.bean,
    required this.schemaName,
    required this.baseName,
  }) {
    final idField = bean.requireIdField;
    final idColumn = toNamingConvention(
      idField.name,
      NamingConvention.lowerSnakeCase,
    );
    final idType = PostgresqlDataType.findForDataField(idField);

    idIsAuto = idField.hasMetaOfType<Id>((id) => id.auto);
    if (idIsAuto && idType is! PostgresqlInt && idType is! PostgresqlString) {
      throw ApiError(
        'Auto ids of type ${idField.type.name} are not supported by '
        'revisable repositories.',
      );
    }

    idSequence = idIsAuto && idType is PostgresqlInt
        ? PostgresqlSequence(
            schemaName: schemaName,
            name: '${baseName}_${idColumn}_seq',
          )
        : null;

    bool isId(DataField field) => field.name == idField.name;

    PostgresqlDataAttribute attributeOf(
      DataField field, {
      required bool history,
    }) => PostgresqlDataAttribute(
      field: field,
      name: toNamingConvention(field.name, NamingConvention.lowerSnakeCase),
      type: PostgresqlDataType.findForDataField(field),
      constraints: [
        if (!history && isId(field)) const PrimaryKeyConstraint(auto: false),
        if (history && isId(field) && idSequence != null)
          DefaultConstraint(
            Sql.function('nextval', [
              Sql.text(qualifiedName(idSequence!.name).toString()),
            ]),
          ),
        if (history && isId(field) && idIsAuto && idType is PostgresqlString)
          const DefaultConstraint(RawSql('gen_random_uuid()')),
        if (field is DataField<dynamic, Object>) const NotNullConstraint(),
      ],
    );

    final historyData = [
      for (final field in bean.fields) attributeOf(field, history: true),
    ];
    historyId = historyData.firstWhere((e) => isId(e.field));
    historyTable = PostgresqlTable(
      schemaName: schemaName,
      name: historyName,
      attributes: [
        sysVersion,
        sysCreator,
        sysCreated,
        sysFrom,
        sysIsDeleted,
        ...historyData,
      ],
      constraints: [
        PrimaryKeyTableConstraint(attributes: [historyId, sysVersion]),
      ],
    );

    final currentData = [
      for (final field in bean.fields) attributeOf(field, history: false),
    ];
    currentId = currentData.firstWhere((e) => isId(e.field));
    currentTable = PostgresqlTable(
      schemaName: schemaName,
      name: baseName,
      attributes: [
        ...currentData,
        sysVersion,
        sysCreator,
        const PostgresqlAttribute(
          name: 'sys_created',
          type: PostgresqlDateTime(),
          constraints: _notNull,
        ),
        const PostgresqlAttribute(
          name: 'sys_from',
          type: PostgresqlDateTime(),
          constraints: _notNull,
        ),
      ],
    );

    scheduleId = PostgresqlAttribute(
      name: idColumn,
      type: idType,
      constraints: _notNull,
    );
    scheduleTable = PostgresqlTable(
      schemaName: schemaName,
      name: scheduleName,
      attributes: [
        scheduleId,
        sysVersion,
        const PostgresqlAttribute(
          name: 'sys_from',
          type: PostgresqlDateTime(),
          constraints: _notNull,
        ),
        sysFailedAt,
        sysError,
      ],
      constraints: [
        PrimaryKeyTableConstraint(attributes: [scheduleId, sysVersion]),
      ],
    );

    for (final name in [
      baseName,
      historyName,
      scheduleName,
      scheduleIndexName,
      ?idSequence?.name,
    ]) {
      if (utf8.encode(name).length > 63) {
        throw SqlException(
          'Identifier "$name" exceeds the PostgreSQL limit of 63 bytes. '
          'Use the relationName config to choose a shorter relation name.',
        );
      }
    }
  }

  String get historyName => '${baseName}_history';

  String get scheduleName => '${baseName}_schedule';

  String get scheduleIndexName => '${baseName}_schedule_from_idx';

  // TODO move away
  /// Name of the revision table of the view based layout (before 0.18).
  String get legacyRevisionName => '${baseName}_revision';

  /// Identifies this repository in advisory lock keys and notifications.
  String get key => '$schemaName.$baseName';

  Iterable<PostgresqlDataAttribute> get historyDataAttributes =>
      historyTable.attributes.whereType<PostgresqlDataAttribute>();

  Iterable<PostgresqlDataAttribute> get currentDataAttributes =>
      currentTable.attributes.whereType<PostgresqlDataAttribute>();

  // TODO refactor?
  Sql qualifiedName(String name) => Sql.qualifiedName([schemaName, name]);

  /// Creates missing relations and migrates the view based layout.
  ///
  /// Must run inside a transaction. Concurrent setups of the same repository
  /// (multiple instances starting at once) are serialized.
  Future<void> setup(PostgresqlContext db) async {
    await db.ensureSchema(schemaName);
    await db.execute(
      RawSql('SELECT pg_advisory_xact_lock(hashtextextended(') +
          Sql.text('datahub.revisable.ddl:$key') +
          RawSql(', 0))'),
    );

    if (idSequence case final sequence?) {
      await sequence.ensureRelation(db);
    }

    var baseKind = await _kindOf(db, baseName);
    var historyKind = await _kindOf(db, historyName);

    if (historyKind == null) {
      final legacyKind = await _kindOf(db, legacyRevisionName);
      if (legacyKind != null) {
        await _migrateLegacyLayout(db, baseKind, legacyKind);
        baseKind = null;
        historyKind = PostgresqlRelationKind.table;
      }
    }

    if (historyKind == null) {
      if (baseKind != null) {
        throw SqlException(
          'Relation "$schemaName"."$baseName" exists, but its revision '
          'history "$schemaName"."$historyName" does not.',
        );
      }

      log.warn(
        'Table "$schemaName"."$historyName" does not exist. '
        'Creating relation.',
      );
      await db.executeLiteral(SqlCreateRelation(schemaName, historyTable));
    } else if (!historyKind.isTable) {
      throw SqlException(
        'Relation "$schemaName"."$historyName" is a ${historyKind.name}, '
        'expected a table.',
      );
    }

    var fillCurrent = false;
    if (baseKind == null) {
      log.warn(
        'Table "$schemaName"."$baseName" does not exist. Creating relation.',
      );
      await db.executeLiteral(SqlCreateRelation(schemaName, currentTable));
      fillCurrent = true;
    } else if (baseKind != PostgresqlRelationKind.table ||
        !await _hasColumn(db, baseName, sysVersion.name)) {
      throw SqlException(
        'Relation "$schemaName"."$baseName" is not the current state table '
        'of a revisable repository.',
      );
    }

    var fillSchedule = false;
    switch (await _kindOf(db, scheduleName)) {
      case null:
        log.warn(
          'Table "$schemaName"."$scheduleName" does not exist. '
          'Creating relation.',
        );
        await db.executeLiteral(SqlCreateRelation(schemaName, scheduleTable));
        // TODO index annotations
        await db.execute(
          Sql.join([
            RawSql('CREATE INDEX IF NOT EXISTS '),
            Sql.name(scheduleIndexName),
            RawSql(' ON '),
            qualifiedName(scheduleName),
            RawSql(' ("sys_from")'),
          ]),
        );
        fillSchedule = true;
      case PostgresqlRelationKind.table:
        break;
      case final kind:
        throw SqlException(
          'Relation "$schemaName"."$scheduleName" is a ${kind.name}, '
          'expected a table.',
        );
    }

    if (fillCurrent || fillSchedule) {
      // one point in time for both, so no revision falls between them
      final now =
          (await db.execute(RawSql('SELECT ') + dbNow)).first.first as DateTime;

      if (fillCurrent) {
        await db.execute(_fillCurrentSql(now));
      }

      if (fillSchedule) {
        await db.execute(_fillScheduleSql(now));
      }
    }
  }

  Future<PostgresqlRelationKind?> _kindOf(PostgresqlContext db, String name) =>
      PostgresqlRelation.findKind(db, schemaName, name);

  Future<bool> _hasColumn(
    PostgresqlContext db,
    String relation,
    String column,
  ) async {
    final result = await db.execute(
      Sql.join([
        RawSql(
          'SELECT EXISTS (SELECT 1 FROM information_schema.columns '
          'WHERE table_schema = ',
        ),
        ParameterSql<String>(schemaName, const PostgresqlString()),
        RawSql(' AND table_name = '),
        ParameterSql<String>(relation, const PostgresqlString()),
        RawSql(' AND column_name = '),
        ParameterSql<String>(column, const PostgresqlString()),
        RawSql(')'),
      ]),
    );
    return result.first.first as bool;
  }

  /// Converts the view based layout (`<base>` view on `<base>_revision`) by
  /// renaming the revision table to `<base>_history`. `<base>` and
  /// `<base>_schedule` are created and filled from history afterwards.
  Future<void> _migrateLegacyLayout(
    PostgresqlContext db,
    PostgresqlRelationKind? baseKind,
    PostgresqlRelationKind legacyKind,
  ) async {
    if (!legacyKind.isTable) {
      throw SqlException(
        'Relation "$schemaName"."$legacyRevisionName" is a '
        '${legacyKind.name}, expected a table.',
      );
    }

    log.warn(
      'Migrating revisable repository "$schemaName"."$baseName" from the '
      'view based layout: "$legacyRevisionName" becomes "$historyName", '
      '"$baseName" becomes a table holding the current state.',
    );

    switch (baseKind) {
      case null:
        break;
      case PostgresqlRelationKind.view:
        // RESTRICT: fails when other objects depend on the view
        await db.execute(RawSql('DROP VIEW ') + qualifiedName(baseName));
      case final kind:
        throw SqlException(
          'Cannot migrate revisable repository "$schemaName"."$baseName": '
          'expected a view, found a ${kind.name}.',
        );
    }

    await db.execute(
      RawSql('ALTER TABLE ') +
          qualifiedName(legacyRevisionName) +
          RawSql(' RENAME TO ') +
          Sql.name(historyName),
    );

    // sys_to is derived from later revisions when reading
    await db.execute(
      RawSql('ALTER TABLE ') +
          qualifiedName(historyName) +
          RawSql(' DROP COLUMN IF EXISTS "sys_to"'),
    );
  }

  Sql _fillCurrentSql(DateTime now) {
    final columns = [
      for (final attribute in currentTable.attributes)
        SqlColumnAttribute(attribute.name),
    ];

    return SqlInsertSelect(
      SqlQualifiedRelation.of(currentTable),
      columns,
      SqlSelect(
        Sql.join([
          RawSql('(SELECT DISTINCT ON ('),
          Sql.name(historyId.name),
          RawSql(') * FROM '),
          qualifiedName(historyName),
          RawSql(' WHERE "sys_from" <= '),
          ParameterSql(now, const PostgresqlDateTime()),
          RawSql(' ORDER BY '),
          Sql.name(historyId.name),
          RawSql(', "sys_version" DESC) AS "cur"'),
        ]),
        columns,
        where: RawSql('NOT "cur"."sys_is_deleted"'),
      ),
    );
  }

  Sql _fillScheduleSql(DateTime now) {
    final id = Sql.name(historyId.name);
    return SqlInsertSelect(
      SqlQualifiedRelation.of(scheduleTable),
      [
        SqlColumnAttribute(scheduleId.name),
        SqlColumnAttribute(sysVersion.name),
        SqlColumnAttribute(sysFrom.name),
      ],
      Sql.join([
        RawSql('SELECT '),
        id,
        RawSql(', "sys_version", "sys_from" FROM (SELECT '),
        id,
        RawSql(
          ', "sys_version", "sys_from", min("sys_from") OVER (PARTITION BY ',
        ),
        id,
        RawSql(
          ' ORDER BY "sys_version" ROWS BETWEEN 1 FOLLOWING AND UNBOUNDED '
          'FOLLOWING) AS "sys_next" FROM ',
        ),
        qualifiedName(historyName),
        RawSql(') AS "x" WHERE "x"."sys_from" > '),
        ParameterSql(now, const PostgresqlDateTime()),
        RawSql(
          ' AND ("x"."sys_next" IS NULL OR "x"."sys_from" < "x"."sys_next")',
        ),
      ]),
    );
  }
}
