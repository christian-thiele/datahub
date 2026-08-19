import 'dart:io';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import '../data/person.dart';

/// The startup guard compares the data model against the migration files and
/// nothing else, so it can be exercised without a database - and has to be,
/// since what it does is stop the host from starting.
TestHost _host(Directory directory) => TestHost(
  components: [
    PostgresqlMigrationService(
      directory: Config.value(directory.path),
      mode: Config.value(MigrationMode.validate),
      schema: [PostgresqlDataRepositoryService(bean: $Person.bean)],
    ),
  ],
  testBody: () {},
);

void main() {
  late Directory directory;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('datahub_migration');
  });

  tearDown(() => directory.deleteSync(recursive: true));

  test('startup refuses a model that no migration describes', () async {
    await expectLater(
      _host(directory).initialize(),
      throwsA(
        isA<MigrationException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('no migration describes'),
            contains('create table public.person'),
            contains('migrate new'),
          ),
        ),
      ),
    );
  });

  test('startup refuses a history that has fallen behind the model', () async {
    final table = DataSchemaBuilder.buildDataTable(
      $Person.bean,
      schemaName: 'public',
    );
    final snapshot = SchemaSnapshot.ofRelations([table]);

    // A history that covers everything but the most recent field.
    final outdated = TableSnapshot.of(table).copyWith(
      attributes: TableSnapshot.of(
        table,
      ).attributes.where((e) => e.name != 'is_special').toList(),
    );

    File('${directory.path}/0001_initial.sql').writeAsStringSync(
      MigrationPlanner.generate(
        name: 'initial',
        history: const [],
        desired: SchemaSnapshot.of([outdated]),
      )!.render(),
    );

    await expectLater(
      _host(directory).initialize(),
      throwsA(
        isA<MigrationException>().having(
          (e) => e.message,
          'message',
          contains('add public.person.is_special'),
        ),
      ),
    );

    // With the missing change recorded, the guard is satisfied and startup
    // moves on to the database check - which in this host fails for want of a
    // PostgresqlService, not for want of a migration.
    File('${directory.path}/0002_catch_up.sql').writeAsStringSync(
      MigrationPlanner.generate(
        name: 'catch_up',
        history: [
          Migration.parse(
            File('${directory.path}/0001_initial.sql').readAsStringSync(),
          ),
        ],
        desired: snapshot,
      )!.render(),
    );

    await expectLater(
      _host(directory).initialize(),
      throwsA(isA<ApiException>()),
    );
  });
}
