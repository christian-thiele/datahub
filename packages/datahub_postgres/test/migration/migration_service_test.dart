import 'dart:io';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/expect.dart';

import '../data/article.dart';
import '../data/person.dart';

/// Writes a migration history for the given services into a temporary
/// directory.
///
/// This happens while the test file is being declared, before any host exists,
/// which is exactly the point: generating a migration needs the model and the
/// history, and nothing else.
Directory _history(
  List<PostgresqlSchemaOwner> schema, {
  List<Migration> Function(SchemaSnapshot desired)? extra,
}) {
  final directory = Directory.systemTemp.createTempSync('datahub_migration');
  final desired = SchemaSnapshot.ofRelations([
    for (final owner in schema) ...owner.buildRelations('public', null),
  ]);

  final migrations = [
    MigrationPlanner.generate(
      name: 'initial',
      history: const [],
      desired: desired,
    )!,
    ...?extra?.call(desired),
  ];

  for (final migration in migrations) {
    File(
      '${directory.path}/${migration.fileName}',
    ).writeAsStringSync(migration.render());
  }

  return directory;
}

List<Component> _components(
  Directory directory,
  List<PostgresqlSchemaOwner> schema,
) => [
  PostgresqlService(
    host: Config('test.services.postgres.host'),
    port: Config('test.services.postgres.5432'),
    database: Config.value('datahub_postgres'),
    username: Config.value('postgres'),
    password: Config.value('postgres'),
    useSsl: Config.value(false),
  ),
  PostgresqlMigrationService(
    directory: Config.value(directory.path),
    // The tests drive the runner themselves so that both the "before" and the
    // "after" of a migration can be asserted in one host.
    mode: Config.value(MigrationMode.none),
    schema: schema,
  ),
];

PostgresqlMigrationServiceInstance get _migrations =>
    Find<PostgresqlMigrationServiceInstance>().find();

Future<int> _trackedCount() async {
  final result = await Find<Postgresql>().find().runTransaction(
    (context) => context.execute(
      const SqlSelect(
        SqlQualifiedRelation('public', MigrationRunner.trackingRelationName),
        [RawSqlAttribute(RawSql('COUNT(*)'))],
      ),
    ),
  );
  return result.first[0] as int;
}

void main() {
  final simple = _history([
    PostgresqlDataRepositoryService(bean: $Person.bean),
  ]);

  declareTest(
    'Migrations: apply, validate and repository handover',
    environment: ComposeEnvironment.fromFile(
      'test/single-postgres.docker-compose.yml',
    ),
    _components(simple, [PostgresqlDataRepositoryService(bean: $Person.bean)]),
    () async {
      final migrations = _migrations;
      final files = await migrations.loadHistory();
      expect(files, hasLength(1));

      // The repository did not create its table - the migration system owns
      // it now.
      expect(migrations.manages('public.person'), isTrue);

      final before = await migrations.runner.status(files);
      expect(before.pending, hasLength(1));
      expect(before.problems, isEmpty);
      expect(before.isUpToDate, isFalse);
      expect(before.report(), contains('PENDING'));

      await expectLater(
        migrations.runner.validate(files),
        throwsA(isA<MigrationException>()),
      );

      // A dry run reports what it would do and changes nothing.
      expect(await migrations.runner.apply(files, dryRun: true), hasLength(1));
      expect(await _trackedCount(), equals(0));

      expect(await migrations.runner.apply(files), hasLength(1));
      expect(await _trackedCount(), equals(1));

      final after = await migrations.runner.status(files);
      expect(after.pending, isEmpty);
      expect(after.isUpToDate, isTrue);
      await migrations.runner.validate(files);

      // Applying again is a no-op rather than an error.
      expect(await migrations.runner.apply(files), isEmpty);

      // And the table the migration created is the one the repository uses.
      final repository = Find<DataRepository<Person>>().find();
      final created = await repository.create(
        Person(
          firstName: 'Ada',
          lastName: 'Lovelace',
          birthday: null,
          isSpecial: true,
        ),
      );
      expect(created.id, greaterThan(0));
      expect(await repository.count(), equals(1));

      // The model is fully described by the history, so there is nothing left
      // to generate.
      expect(await migrations.plan(), isEmpty);

      // And the database really looks the way the history says it does.
      expect(await migrations.runner.verify(migrations.desiredSchema), isEmpty);
    },
  );

  final revisable = _history([
    PostgresqlRevisableRepositoryService(bean: $Article.bean),
  ]);

  declareTest(
    'Migrations: revisable relations',
    environment: ComposeEnvironment.fromFile(
      'test/single-postgres.docker-compose.yml',
    ),
    _components(revisable, [
      PostgresqlRevisableRepositoryService(bean: $Article.bean),
    ]),
    () async {
      final migrations = _migrations;
      final files = await migrations.loadHistory();

      // The revision table and the view it is read through both come from the
      // migration, not from the repository.
      expect(migrations.manages('public.article_revision'), isTrue);
      expect(migrations.manages('public.article'), isTrue);

      await migrations.runner.apply(files);
      await migrations.runner.validate(files);

      final repository = Find<DataRepository<Article>>().find();
      await Context.ofZone().withSession(_TestSession(), () async {
        await repository.create(
          const Article(
            id: '',
            personId: 1,
            title: 'Notes',
            content: 'On migrations.',
          ),
        );
      });

      expect(await repository.count(), equals(1));
      expect(await migrations.plan(), isEmpty);
      expect(await migrations.runner.verify(migrations.desiredSchema), isEmpty);
    },
  );

  final tampered = _history([
    PostgresqlDataRepositoryService(bean: $Person.bean),
  ]);

  declareTest(
    'Migrations: an edited migration is refused',
    environment: ComposeEnvironment.fromFile(
      'test/single-postgres.docker-compose.yml',
    ),
    _components(tampered, [
      PostgresqlDataRepositoryService(bean: $Person.bean),
    ]),
    () async {
      final migrations = _migrations;
      await migrations.runner.apply(await migrations.loadHistory());

      final file = File('${tampered.path}/0001_initial.sql');
      await file.writeAsString('${await file.readAsString()}\n-- edited\n');

      final edited = await migrations.loadHistory();
      final status = await migrations.runner.status(edited);
      expect(status.problems, hasLength(1));
      expect(status.problems.single, contains('modified after it was applied'));

      await expectLater(
        migrations.runner.validate(edited),
        throwsA(isA<MigrationException>()),
      );
      await expectLater(
        migrations.runner.apply(edited),
        throwsA(isA<MigrationException>()),
      );
    },
  );

  final gated = _history(
    [PostgresqlDataRepositoryService(bean: $Person.bean)],
    extra: (desired) {
      final table = desired['public.person'] as TableSnapshot;
      return [
        Migration.ofChanges(
          version: 2,
          name: 'drop_is_special',
          changes: SchemaDiff.between(
            desired,
            SchemaSnapshot.of([
              table.copyWith(
                attributes: table.attributes
                    .where((e) => e.name != 'is_special')
                    .toList(),
              ),
            ]),
          ),
        ),
      ];
    },
  );

  declareTest(
    'Migrations: destructive changes are gated',
    environment: ComposeEnvironment.fromFile(
      'test/single-postgres.docker-compose.yml',
    ),
    _components(gated, [PostgresqlDataRepositoryService(bean: $Person.bean)]),
    () async {
      final migrations = _migrations;
      final files = await migrations.loadHistory();
      expect(files, hasLength(2));
      expect(files.last.migration.destructive, isTrue);

      await expectLater(
        migrations.runner.apply(files),
        throwsA(isA<MigrationException>()),
      );

      // The first migration still went through - each one is its own
      // transaction, and the run stops at the one it refuses.
      expect(await _trackedCount(), equals(1));

      expect(
        await migrations.runner.apply(files, allowDestructive: true),
        hasLength(1),
      );
      expect(await _trackedCount(), equals(2));
    },
  );

  final adopted = Directory.systemTemp.createTempSync('datahub_migration');

  declareTest(
    'Migrations: baselining an existing database',
    environment: ComposeEnvironment.fromFile(
      'test/single-postgres.docker-compose.yml',
    ),
    _components(adopted, [PostgresqlDataRepositoryService(bean: $Person.bean)]),
    () async {
      final migrations = _migrations;
      expect(await migrations.loadHistory(), isEmpty);

      // Stand in for a database created the old way, before there were any
      // migrations: the tables are there, the history is not.
      await Find<Postgresql>().find().runTransaction((context) async {
        for (final relation in migrations.managedRelations) {
          await relation.ensureRelation(context);
        }
      });

      final baseline = Migration.ofChanges(
        version: 1,
        name: 'baseline',
        changes: SchemaDiff.between(
          SchemaSnapshot.empty,
          await migrations.runner.introspect(),
        ),
      );
      await migrations.store.write(baseline);

      final files = await migrations.loadHistory();
      expect(await migrations.runner.baseline(files), hasLength(1));

      // The history now covers what is already there, so nothing is pending
      // and nothing has to run.
      final status = await migrations.runner.status(files);
      expect(status.isUpToDate, isTrue);
      await migrations.runner.validate(files);

      // And what was adopted matches the model, so there is nothing left to
      // generate either.
      expect(await migrations.plan(), isEmpty);
      expect(await migrations.runner.verify(migrations.desiredSchema), isEmpty);
    },
  );

  final concurrent = _history([
    PostgresqlDataRepositoryService(bean: $Person.bean),
  ]);

  declareTest(
    'Migrations: concurrent applies are serialized',
    environment: ComposeEnvironment.fromFile(
      'test/single-postgres.docker-compose.yml',
    ),
    _components(concurrent, [
      PostgresqlDataRepositoryService(bean: $Person.bean),
    ]),
    () async {
      final migrations = _migrations;
      final files = await migrations.loadHistory();

      final results = await Future.wait([
        migrations.runner.apply(files),
        migrations.runner.apply(files),
        migrations.runner.apply(files),
      ]);

      // Exactly one of them did the work; the others waited for the lock and
      // then found nothing to do.
      expect(results.where((e) => e.isNotEmpty), hasLength(1));
      expect(await _trackedCount(), equals(1));
    },
  );
}

class _TestSession implements Session {
  @override
  String get identity => 'migration-test';

  @override
  String get debugName => 'test/$identity';
}
