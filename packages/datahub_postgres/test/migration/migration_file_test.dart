import 'dart:io';

import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import '../data/article.dart';
import '../data/person.dart';

const _schema = 'public';

SchemaSnapshot _tableSchema() => SchemaSnapshot.ofRelations([
  DataSchemaBuilder.buildDataTable($Person.bean, schemaName: _schema),
]);

SchemaSnapshot _revisableSchema() => SchemaSnapshot.ofRelations(
  DataSchemaBuilder.buildRevisableRelations(
    $Article.bean,
    schemaName: _schema,
  ).all,
);

Migration _initial(SchemaSnapshot desired) => MigrationPlanner.generate(
  name: 'initial',
  history: const [],
  desired: desired,
)!;

void main() {
  group('Migration file', () {
    test('renders and parses back identically', () {
      final migration = _initial(_revisableSchema());
      final parsed = Migration.parse(migration.render());

      expect(parsed.version, equals(migration.version));
      expect(parsed.name, equals(migration.name));
      expect(
        parsed.created.toUtc().toIso8601String(),
        equals(migration.created.toUtc().toIso8601String()),
      );
      expect(parsed.destructive, equals(migration.destructive));
      expect(parsed.review, equals(migration.review));
      expect(parsed.sql, equals(migration.sql));
      expect(
        MigrationPlanner.replay([parsed]),
        equals(MigrationPlanner.replay([migration])),
      );
    });

    test('survives a "*/" inside the header', () {
      final migration = Migration.ofChanges(
        version: 1,
        name: 'tricky',
        changes: [
          CreateRelation(
            ViewSnapshot(
              schemaName: _schema,
              name: 'tricky',
              select: 'SELECT 1 /* nested */ AS "x"',
              attributes: const [AttributeSnapshot(name: 'x', type: 'bigint')],
            ),
          ),
        ],
      );

      final rendered = migration.render();
      expect(rendered, isNot(contains('nested */\n')));

      final view =
          MigrationPlanner.replay([
                Migration.parse(rendered),
              ])['$_schema.tricky']
              as ViewSnapshot;
      expect(view.select, equals('SELECT 1 /* nested */ AS "x"'));
    });

    test('rejects malformed files', () {
      expect(
        () => Migration.parse('ALTER TABLE "x" ADD COLUMN "y" varchar;'),
        throwsA(isA<MigrationFormatException>()),
      );
      expect(
        () => Migration.parse('/* datahub:migration\n{ nope\n*/\n'),
        throwsA(isA<MigrationFormatException>()),
      );
      expect(
        () => Migration.parse('/* some other comment */\nSELECT 1;'),
        throwsA(isA<MigrationFormatException>()),
      );
      expect(
        () => Migration.parse('/* datahub:migration\n{"version": 1}\n*/'),
        throwsA(isA<MigrationFormatException>()),
      );
    });

    test('checksum covers the whole file', () {
      final migration = _initial(_tableSchema());
      final rendered = migration.render();

      expect(
        Migration.checksumOf(rendered),
        equals(Migration.checksumOf(rendered)),
      );
      expect(
        Migration.checksumOf(rendered),
        isNot(equals(Migration.checksumOf('$rendered\n-- touched'))),
      );
    });
  });

  group('MigrationStore', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('datahub_migrations');
    });

    tearDown(() async {
      await directory.delete(recursive: true);
    });

    test('round trips through the file system', () async {
      final store = MigrationStore(directory);
      expect(await store.load(), isEmpty);

      final migration = _initial(_tableSchema());
      final file = await store.write(migration);
      expect(file.path, endsWith('0001_initial.sql'));

      final loaded = await store.load();
      expect(loaded, hasLength(1));
      expect(loaded.single.migration.name, equals('initial'));
      expect(
        loaded.single.checksum,
        equals(Migration.checksumOf(migration.render())),
      );
    });

    test('refuses to overwrite an existing migration', () async {
      final store = MigrationStore(directory);
      await store.write(_initial(_tableSchema()));

      expect(
        () => store.write(_initial(_tableSchema())),
        throwsA(isA<MigrationFormatException>()),
      );
    });

    test('rejects a gap in the history', () async {
      final store = MigrationStore(directory);
      final desired = _tableSchema();
      await store.write(_initial(desired));

      final third = Migration.ofChanges(
        version: 3,
        name: 'third',
        changes: SchemaDiff.between(SchemaSnapshot.empty, desired),
      );
      await File(
        '${directory.path}/0003_third.sql',
      ).writeAsString(third.render());

      expect(store.load(), throwsA(isA<MigrationFormatException>()));
    });

    test('rejects a file name that disagrees with its header', () async {
      final migration = _initial(_tableSchema());
      await File(
        '${directory.path}/0001_renamed.sql',
      ).writeAsString(migration.render());

      expect(
        MigrationStore(directory).load(),
        throwsA(isA<MigrationFormatException>()),
      );
    });

    test('normalizes names', () {
      expect(
        MigrationStore.normalizeName('Add Person Email'),
        equals('add_person_email'),
      );
      expect(
        MigrationStore.normalizeName('  add--email!! '),
        equals('add_email'),
      );
      expect(
        () => MigrationStore.normalizeName('///'),
        throwsA(isA<MigrationFormatException>()),
      );
    });
  });

  group('MigrationPlanner', () {
    test('replays a history back into the desired schema', () {
      final desired = _revisableSchema();
      final initial = _initial(desired);

      expect(MigrationPlanner.replay([initial]), equals(desired));
      expect(MigrationPlanner.plan([initial], desired), isEmpty);
    });

    test('returns null when there is nothing to do', () {
      final desired = _tableSchema();
      final initial = _initial(desired);

      expect(
        MigrationPlanner.generate(
          name: 'noop',
          history: [initial],
          desired: desired,
        ),
        isNull,
      );
    });

    test('generates the follow up migration for a model change', () {
      final desired = _tableSchema();
      final initial = _initial(desired);

      final table = desired['$_schema.person'] as TableSnapshot;
      final extended = SchemaSnapshot.of([
        table.copyWith(
          attributes: [
            ...table.attributes,
            const AttributeSnapshot(name: 'email', type: 'varchar'),
          ],
        ),
      ]);

      final next = MigrationPlanner.generate(
        name: 'add_email',
        history: [initial],
        desired: extended,
      )!;

      expect(next.version, equals(2));
      expect(next.fileName, equals('0002_add_email.sql'));
      expect(next.sql, contains('ADD COLUMN "email" varchar'));
      expect(next.requiresReview, isFalse);
      expect(MigrationPlanner.replay([initial, next]), equals(extended));
    });

    test('an empty migration does not move the replayed schema', () {
      final desired = _tableSchema();
      final initial = _initial(desired);
      final manual = MigrationPlanner.empty(
        name: 'by_hand',
        history: [initial],
      );

      expect(manual.version, equals(2));
      expect(MigrationPlanner.replay([initial, manual]), equals(desired));
    });

    test('reports an unreplayable history', () {
      final orphan = Migration.ofChanges(
        version: 1,
        name: 'orphan',
        changes: const [
          AddAttribute(
            'public.nowhere',
            AttributeSnapshot(name: 'x', type: 'bigint'),
          ),
        ],
      );

      expect(
        () => MigrationPlanner.replay([orphan]),
        throwsA(isA<MigrationHistoryException>()),
      );
    });
  });
}
