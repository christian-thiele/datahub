import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import 'data/city.dart';
import 'data/person.dart';
import 'utils/revision_test_utils.dart';

// polling must not be what makes these tests pass
final _noPolling = Config.value(const Duration(minutes: 5));

void main() {
  declareTest(
    'Revisable: scheduled update, create and delete',
    environment: postgresEnvironment,
    [
      testPostgresqlService(),
      PostgresqlRevisableRepositoryService(
        bean: $Person.bean,
        schedulePollInterval: _noPolling,
      ),
    ],
    () async {
      final repo = Find<RevisableDataRepository<Person>>().find();

      await asUser(() async {
        final peter = await repo.create(
          Person(firstName: 'Peter', lastName: 'Lustig', birthday: null),
        );
        final paul = await repo.create(
          Person(firstName: 'Paul', lastName: 'Panzer', birthday: null),
        );

        final due = DateTime.now().add(const Duration(seconds: 2));
        expect(
          await repo.updateById(peter.copyWith(isSpecial: true), from: due),
          isTrue,
        );
        final anna = await repo.create(
          Person(firstName: 'Anna', lastName: 'Lustig', birthday: null),
          from: due,
        );
        expect(await repo.deleteById(paul.id, from: due), isTrue);

        // nothing changed before the revisions become effective
        expect((await repo.readById(peter.id))!.isSpecial, isFalse);
        expect(await repo.readById(anna.id), isNull);
        expect(await repo.readById(paul.id), isNotNull);
        expect(await repo.count(), 2);

        final current = await repo.revisableReadById(peter.id);
        expect(current!.version, 0);
        expect(current.to!.isAtSameMomentAs(due), isTrue);

        final revisions = await repo.readRevisionsById(peter.id);
        expect(revisions.map((e) => e.version), [1, 0]);
        expect(revisions.first.from.isAtSameMomentAs(due), isTrue);
        expect(revisions.first.to, isNull);
        expect(revisions.last.to!.isAtSameMomentAs(due), isTrue);
        await expectConsistent('person');

        // applied by the promoter, without reads or explicit promotion
        await waitUntil(due);
        await eventually(() async {
          final rows = await sql(
            'SELECT id, is_special, sys_version FROM person ORDER BY id',
          );
          expect(rows.map((r) => (r[0], r[1], r[2])), [
            (peter.id, true, 1),
            (anna.id, false, 0),
          ]);
        }, timeout: const Duration(seconds: 2));

        expect(await repo.readById(paul.id), isNull);
        expect((await repo.readRevisionsById(paul.id)).first.isDeleted, isTrue);
        await expectConsistent('person');
      });
    },
  );

  declareTest(
    'Revisable: superseded and chained schedules',
    environment: postgresEnvironment,
    [
      testPostgresqlService(),
      PostgresqlRevisableRepositoryService(
        bean: $City.bean,
        schedulePollInterval: _noPolling,
      ),
    ],
    () async {
      final repo = Find<RevisableDataRepository<City>>().find();

      Future<String?> nameOf(String id) async =>
          (await repo.readById(id))?.name;

      await asUser(() async {
        for (final id in ['a', 'b', 'c']) {
          await repo.create(City(id: id, name: id.toUpperCase(), zip: '1'));
        }

        final start = DateTime.now();
        DateTime at(int seconds) => start.add(Duration(seconds: seconds));

        // a: scheduled, then superseded by an immediate revision
        await repo.updateById(
          City(id: 'a', name: 'A1', zip: '1'),
          from: at(2),
        );
        await repo.updateById(City(id: 'a', name: 'A2', zip: '1'));

        // b: later schedule superseded by an earlier one
        await repo.updateById(
          City(id: 'b', name: 'B1', zip: '1'),
          from: at(4),
        );
        await repo.updateById(
          City(id: 'b', name: 'B2', zip: '1'),
          from: at(2),
        );

        // c: chain
        await repo.updateById(
          City(id: 'c', name: 'C1', zip: '1'),
          from: at(2),
        );
        await repo.updateById(
          City(id: 'c', name: 'C2', zip: '1'),
          from: at(4),
        );

        expect(await nameOf('a'), 'A2');
        expect(await nameOf('b'), 'B');
        expect(await nameOf('c'), 'C');
        await expectConsistent('city');

        await waitUntil(at(3));
        await eventually(() async {
          expect(await nameOf('b'), 'B2');
          expect(await nameOf('c'), 'C1');
        }, timeout: const Duration(seconds: 1));
        expect(await nameOf('a'), 'A2');
        await expectConsistent('city');

        await waitUntil(at(5));
        await eventually(() async {
          expect(await nameOf('c'), 'C2');
        }, timeout: const Duration(seconds: 1));
        expect(await nameOf('a'), 'A2');
        expect(await nameOf('b'), 'B2');
        await expectConsistent('city');

        final a = await repo.readRevisionsById('a');
        expect(a.map((e) => (e.version, e.data.name)), [
          (2, 'A2'),
          (1, 'A1'),
          (0, 'A'),
        ]);
        // superseded before it became effective
        expect(a[1].to!.isAfter(a[1].from), isFalse);

        final b = await repo.readRevisionsById('b');
        expect(b.map((e) => (e.version, e.data.name)), [
          (2, 'B2'),
          (1, 'B1'),
          (0, 'B'),
        ]);
        expect(b[1].to!.isAtSameMomentAs(at(2)), isTrue);
        expect(b[2].to!.isAtSameMomentAs(at(2)), isTrue);

        final c = await repo.readRevisionsById('c');
        expect(c.map((e) => e.to?.isAtSameMomentAs(at(4))), [
          null,
          true,
          false,
        ]);

        expect((await sql('SELECT count(*) FROM city_schedule')).first[0], 0);
      });
    },
  );

  declareTest(
    'Revisable: revive with a scheduled create',
    environment: postgresEnvironment,
    [
      testPostgresqlService(),
      PostgresqlRevisableRepositoryService(
        bean: $City.bean,
        schedulePollInterval: _noPolling,
      ),
    ],
    () async {
      final repo = Find<RevisableDataRepository<City>>().find();

      await asUser(() async {
        await repo.create(City(id: 'berlin', name: 'Berlin', zip: '10115'));
        await repo.deleteById('berlin');

        final due = DateTime.now().add(const Duration(seconds: 1));
        await repo.create(
          City(id: 'berlin', name: 'Berlin', zip: '10117'),
          from: due,
        );

        await expectLater(
          () => repo.create(City(id: 'berlin', name: 'Berlin', zip: '1')),
          throwsA(isA<RevisableInconsistencyException>()),
        );
        expect(await repo.readById('berlin'), isNull);

        await waitUntil(due);
        await eventually(() async {
          expect((await repo.readById('berlin'))?.zip, '10117');
        }, timeout: const Duration(seconds: 2));

        expect((await repo.revisableReadById('berlin'))!.version, equals(2));
        await expectConsistent('city');
      });
    },
  );

  declareTest(
    'Revisable: schedules of other instances, listener reconnect',
    environment: postgresEnvironment,
    [
      testPostgresqlService(),
      PostgresqlRevisableRepositoryService(
        bean: $City.bean,
        schedulePollInterval: _noPolling,
      ),
    ],
    () async {
      final repo = Find<RevisableDataRepository<City>>().find();

      /// Schedules a revision like another instance would.
      Future<DateTime> scheduleExternally(String name, int version) async {
        final due = DateTime.now().toUtc().add(const Duration(seconds: 1));
        await sqlScript('''
          INSERT INTO city_history
            (id, sys_version, sys_creator, sys_from, sys_is_deleted, name, zip)
            VALUES ('x', $version, 'other', '${due.toIso8601String()}', false, '$name', '1');
          INSERT INTO city_schedule (id, sys_version, sys_from)
            VALUES ('x', $version, '${due.toIso8601String()}');
          SELECT pg_notify('datahub_revisable', 'public.city');
        ''');
        return due;
      }

      await asUser(() async {
        await repo.create(City(id: 'x', name: 'X0', zip: '1'));

        var due = await scheduleExternally('X1', 1);
        await waitUntil(due);
        await eventually(() async {
          expect((await repo.readById('x'))!.name, 'X1');
        }, timeout: const Duration(seconds: 2));

        // lose the listener connection
        final listenerPid = await sql(
          "SELECT pid FROM pg_stat_activity WHERE application_name LIKE '%/listener'",
        );
        expect(listenerPid, hasLength(1));
        await sql('SELECT pg_terminate_backend(${listenerPid.first.first})');

        await eventually(() async {
          final pid = await sql(
            'SELECT pid FROM pg_stat_activity '
            "WHERE application_name LIKE '%/listener'",
          );
          expect(pid, hasLength(1));
          expect(pid.first.first, isNot(listenerPid.first.first));
        });

        due = await scheduleExternally('X2', 2);
        await waitUntil(due);
        await eventually(() async {
          expect((await repo.readById('x'))!.name, 'X2');
        }, timeout: const Duration(seconds: 2));
        await expectConsistent('city');
      });
    },
  );

  declareTest(
    'Revisable: poll fallback without notification',
    environment: postgresEnvironment,
    [
      testPostgresqlService(),
      PostgresqlRevisableRepositoryService(
        bean: $City.bean,
        schedulePollInterval: Config.value(const Duration(seconds: 1)),
      ),
    ],
    () async {
      final repo = Find<RevisableDataRepository<City>>().find();

      await asUser(() async {
        await repo.create(City(id: 'x', name: 'X0', zip: '1'));

        final due = DateTime.now().toUtc().add(const Duration(seconds: 1));
        await sqlScript('''
          INSERT INTO city_history
            (id, sys_version, sys_creator, sys_from, sys_is_deleted, name, zip)
            VALUES ('x', 1, 'other', '${due.toIso8601String()}', false, 'X1', '1');
          INSERT INTO city_schedule (id, sys_version, sys_from)
            VALUES ('x', 1, '${due.toIso8601String()}');
        ''');

        await waitUntil(due);
        await eventually(() async {
          expect((await repo.readById('x'))!.name, 'X1');
        }, timeout: const Duration(seconds: 3));
      });
    },
  );

  declareTest(
    'Revisable: failing scheduled revision',
    environment: postgresEnvironment,
    [
      testPostgresqlService(),
      PostgresqlRevisableRepositoryService(
        bean: $City.bean,
        schedulePollInterval: _noPolling,
      ),
    ],
    () async {
      final repo = Find<RevisableDataRepository<City>>().find();

      await asUser(() async {
        await repo.create(City(id: 'a', name: 'A', zip: '1'));
        await repo.create(City(id: 'b', name: 'B', zip: '2'));
        await repo.create(City(id: 'c', name: 'C', zip: '3'));
        await sql('CREATE UNIQUE INDEX city_zip_idx ON city (zip)');

        // immediate revisions violating the index fail like on any table
        await expectLater(
          () => repo.updateById(City(id: 'a', name: 'A', zip: '2')),
          throwsA(isA<Exception>()),
        );

        final due = DateTime.now().add(const Duration(seconds: 1));
        await repo.updateById(
          City(id: 'a', name: 'A', zip: '2'),
          from: due,
        );
        await repo.updateById(
          City(id: 'b', name: 'B1', zip: '2'),
          from: due,
        );
        await repo.updateById(
          City(id: 'c', name: 'C1', zip: '3'),
          from: due,
        );

        await waitUntil(due);
        await eventually(() async {
          expect((await repo.readById('b'))!.name, 'B1');
          expect((await repo.readById('c'))!.name, 'C1');
          final failed = await sql(
            'SELECT id, sys_error FROM city_schedule '
            'WHERE sys_failed_at IS NOT NULL',
          );
          expect(failed.map((r) => r[0]), ['a']);
          expect(failed.first[1], contains('city_zip_idx'));
        }, timeout: const Duration(seconds: 3));

        expect((await repo.readById('a'))!.zip, '1');
        expect((await repo.revisableReadById('a'))!.to, isNull);

        // a later revision supersedes the failed one
        await repo.updateById(City(id: 'a', name: 'A2', zip: '4'));
        expect((await repo.readById('a'))!.name, 'A2');
        expect((await sql('SELECT count(*) FROM city_schedule')).first[0], 0);
        await expectConsistent('city');
      });
    },
  );

  declareTest(
    'Revisable: non-UTC session time zone',
    environment: postgresEnvironment,
    [
      testPostgresqlService(timeZone: 'America/New_York'),
      PostgresqlRevisableRepositoryService(
        bean: $City.bean,
        schedulePollInterval: _noPolling,
      ),
    ],
    () async {
      final repo = Find<RevisableDataRepository<City>>().find();

      await asUser(() async {
        final before = DateTime.now();
        final created = await repo.createRevision(
          City(id: 'x', name: 'X0', zip: '1'),
          type: 1,
        );
        expect(created.created.difference(before).inSeconds.abs(), lessThan(5));
        expect(created.from.difference(before).inSeconds.abs(), lessThan(5));

        final due = DateTime.now().add(const Duration(seconds: 1));
        await repo.updateById(
          City(id: 'x', name: 'X1', zip: '1'),
          from: due,
        );
        expect((await repo.readById('x'))!.name, 'X0');

        await waitUntil(due);
        await eventually(() async {
          expect((await repo.readById('x'))!.name, 'X1');
        }, timeout: const Duration(seconds: 2));
      });
    },
  );

  declareTest(
    'Revisable: schedules and long transactions',
    environment: postgresEnvironment,
    [
      testPostgresqlService(),
      PostgresqlRevisableRepositoryService(
        bean: $City.bean,
        schedulePollInterval: _noPolling,
      ),
    ],
    () async {
      final repo = Find<RevisableDataRepository<City>>().find();

      await asUser(() async {
        await repo.create(City(id: 'x', name: 'X0', zip: '1'));
        await repo.create(City(id: 'y', name: 'Y0', zip: '1'));

        final yDue = DateTime.now().add(const Duration(seconds: 1));
        await repo.updateById(
          City(id: 'y', name: 'Y1', zip: '1'),
          from: yDue,
        );

        late DateTime xDue;
        await repo.atomic(() async {
          await repo.updateById(City(id: 'x', name: 'X1', zip: '1'));

          // x stays locked by this transaction, y is promoted meanwhile
          await waitUntil(yDue);
          await eventually(() async {
            final y = await sql("SELECT name FROM city WHERE id = 'y'");
            expect(y.first.first, 'Y1');
          }, timeout: const Duration(seconds: 2));

          xDue = DateTime.now().add(const Duration(milliseconds: 500));
          await repo.updateById(
            City(id: 'x', name: 'X2', zip: '1'),
            from: xDue,
          );
          await Future<void>.delayed(const Duration(seconds: 1));
        });

        // scheduled inside the transaction, due before its commit
        await eventually(() async {
          expect((await repo.readById('x'))!.name, 'X2');
        }, timeout: const Duration(seconds: 2));
        await expectConsistent('city');
      });
    },
  );
}
