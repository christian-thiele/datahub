import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/schema.dart';
import 'package:datahub_postgres/services.dart';

import 'migration_mode.dart';
import 'migration_planner.dart';
import 'migration_runner.dart';
import 'migration_store.dart';
import 'migration_tool.dart';
import 'schema_change.dart';
import 'postgresql_schema_owner.dart';

/// Manages the postgres schema of the services declared inside it.
///
/// ```dart
/// runApp([
///   PostgresqlService(host: Config.value('localhost')),
///   PostgresqlMigrationService(
///     schema: [
///       PostgresqlDataRepositoryService(bean: $Person.bean),
///       PostgresqlRevisableRepositoryService(bean: $Article.bean),
///     ],
///   ),
/// ]);
/// ```
///
/// The services in [schema] are initialized by this service, after the
/// migrations have run - so a repository never sees a table that a migration
/// has not created yet, and never creates one behind the migration system's
/// back.
///
/// What happens at startup is decided by [mode] and defaults to
/// [MigrationMode.validate]: the application refuses to start against a
/// database that is not at the head of the migration history, and applying is
/// left to `datahub migrate apply`.
class PostgresqlMigrationService implements MigrationToolService {
  /// The services whose relations are managed here.
  final List<PostgresqlSchemaOwner> schema;

  final Find<Postgresql> postgresql;

  /// The schema holding the migration tracking table.
  final Config<String> schemaName;

  /// Where the migration files live, relative to the working directory.
  final Config<String> directory;

  final Config<MigrationMode> mode;

  /// Whether migrations that can lose data may be applied.
  final Config<bool> allowDestructive;

  /// Recorded alongside every applied migration.
  final Config<String> applicationName;

  const PostgresqlMigrationService({
    this.schema = const [],
    this.postgresql = const Find(),
    this.schemaName = const Config('schemaName', defaultValue: 'public'),
    this.directory = const Config(
      'migration.directory',
      defaultValue: 'resources/migrations',
    ),
    this.mode = const Config(
      'migration.mode',
      defaultValue: MigrationMode.validate,
      values: MigrationMode.values,
    ),
    this.allowDestructive = const Config(
      'migration.allowDestructive',
      defaultValue: false,
    ),
    this.applicationName = const Config('serviceName', defaultValue: 'DataHub'),
  });

  @override
  ServiceInstance<PostgresqlMigrationService> createInstance() =>
      PostgresqlMigrationServiceInstance();
}

class PostgresqlMigrationServiceInstance
    extends ServiceInstance<PostgresqlMigrationService>
    implements PostgresqlMigrations, SchemaMigrationTool {
  /// The relations the declared services expect to exist.
  late final List<PostgresqlRelation> managedRelations;

  /// The schema the model describes, which migrations have to add up to.
  late final SchemaSnapshot desiredSchema;

  late final MigrationStore store;

  /// Built on first use, so that the commands which never talk to a database
  /// do not require one to be reachable.
  late final MigrationRunner runner = MigrationRunner(
    postgresql: find(service.postgresql),
    schemaName: read(service.schemaName),
    appliedBy: read(service.applicationName),
  );

  @override
  bool manages(String qualifiedName) =>
      managedRelations.any((e) => e.qualifiedName == qualifiedName);

  @override
  Future<void> initialize() async {
    await super.initialize();

    managedRelations = [
      for (final owner in service.schema)
        ...owner.buildRelations(
          read(owner.schemaName),
          read(owner.relationName),
        ),
    ];
    desiredSchema = SchemaSnapshot.ofRelations(managedRelations);
    store = MigrationStore.ofPath(read(service.directory));

    // A tool host builds the tree to read these declarations, not to touch a
    // database; the command it was started for decides what happens next.
    if (purpose != HostPurpose.tool) {
      await _runStartupMode();
    }

    for (final owner in service.schema) {
      registry.register(owner);
    }
  }

  Future<void> _runStartupMode() async {
    switch (read(service.mode)) {
      case MigrationMode.none:
        return;

      case MigrationMode.validate:
        final files = await store.load();
        _requireHistoryDescribesModel(files);
        await runner.validate(files);
        log.debug(
          'Schema "${read(service.schemaName)}" is at migration head '
          '(${files.length} applied).',
        );

      case MigrationMode.apply:
        final files = await store.load();
        _requireHistoryDescribesModel(files);
        final applied = await runner.apply(
          files,
          allowDestructive: read(service.allowDestructive),
        );
        if (applied.isEmpty) {
          log.debug('No pending migrations.');
        } else {
          log.info(
            'Applied ${applied.length} migration(s): '
            '${applied.map((e) => e.id).join(', ')}.',
          );
        }
    }
  }

  /// Fails startup when the data model has changes no migration describes.
  ///
  /// Without this the application would come up against a database that no
  /// migration will ever bring in line - most obviously when there are no
  /// migrations at all, where the repositories no longer create their tables
  /// and nothing else would either.
  void _requireHistoryDescribesModel(List<MigrationFile> files) {
    final missing = MigrationPlanner.plan(
      files.map((e) => e.migration),
      desiredSchema,
    );

    if (missing.isEmpty) {
      return;
    }

    throw MigrationException(
      'The data model has ${missing.length} change(s) that no migration '
      'describes:\n'
      '${missing.map((e) => '  ${e.describe()}').join('\n')}\n'
      'Run "datahub migrate new <name>" to generate the migration for them.',
    );
  }

  /// Loads the migration history from disk.
  Future<List<MigrationFile>> loadHistory() => store.load();

  @override
  String get migrationToolName => read(service.schemaName);

  @override
  Future<int> runMigrationCommand(MigrationCommand command) {
    // The command runs in this service's context: the connection pool and the
    // telemetry it traces through are both resolved from the zone.
    return context.run(
      () => PostgresqlMigrationTool(
        schemaName: read(service.schemaName),
        store: store,
        desiredSchema: desiredSchema,
        runner: () => runner,
      ).run(command),
    );
  }

  /// The changes still missing from the migration history for the model to be
  /// fully described by it.
  Future<List<SchemaChange>> plan() async => MigrationPlanner.plan(
    (await loadHistory()).map((e) => e.migration),
    desiredSchema,
  );
}
