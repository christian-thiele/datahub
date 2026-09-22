import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import 'data/city.dart';
import 'data/person.dart';
import 'utils/revision_test_utils.dart';

void main() {
  declareTest(
    'Revisable: updateAll',
    environment: postgresEnvironment,
    [
      testPostgresqlService(),
      PostgresqlRevisableRepositoryService(
        bean: $City.bean,
        schedulePollInterval: Config.value(const Duration(minutes: 5)),
      ),
    ],
    () async {
      final repo = Find<RevisableDataRepository<City>>().find();

      await asUser(() async {
        for (final (id, zip) in [
          ('a', '1'),
          ('b', '1'),
          ('c', '1'),
          ('d', '1'),
          ('e', '2'),
        ]) {
          await repo.create(City(id: id, name: id.toUpperCase(), zip: zip));
        }

        final due = DateTime.now().add(const Duration(seconds: 2));
        // pending update of a matched element: superseded by updateAll
        await repo.updateById(
          City(id: 'b', name: 'B-scheduled', zip: '1'),
          from: due,
        );
        // pending delete of a matched element: skipped by updateAll
        await repo.deleteById('c', from: due);
        // pending update of an unmatched element: still applied
        await repo.updateById(
          City(id: 'e', name: 'E-scheduled', zip: '2'),
          from: due,
        );

        final updated = await asUser(
          () => repo.updateAll(
            filter: $City.$zip.equals('1'),
            values: {$City.$name: 'Updated'},
          ),
          identity: 'bulk-user',
        );
        expect(updated, 3);

        final a = await repo.revisableReadById('a');
        expect(a!.version, 1);
        expect(a.creator, 'bulk-user');
        expect(a.data.name, 'Updated');
        expect(a.data.zip, '1');
        expect((await repo.readById('b'))!.name, 'Updated');
        expect((await repo.readById('c'))!.name, 'C');
        expect((await repo.readById('d'))!.name, 'Updated');
        expect((await repo.revisableReadById('e'))!.version, 0);
        expect(
          (await repo.readRevisionsById(
            'b',
          )).map((e) => (e.version, e.data.name)),
          [(2, 'Updated'), (1, 'B-scheduled'), (0, 'B')],
        );
        await expectConsistent('city');

        await waitUntil(due);
        await eventually(() async {
          expect(await repo.readById('c'), isNull);
          expect((await repo.readById('e'))!.name, 'E-scheduled');
        }, timeout: const Duration(seconds: 2));
        expect((await repo.readById('b'))!.name, 'Updated');
        await expectConsistent('city');

        // guards
        await expectLater(
          () => repo.updateAll(filter: Filter.empty, values: {$City.$id: 'z'}),
          throwsArgumentError,
        );
        expect(
          await repo.updateAll(
            filter: Filter.nothing,
            values: {$City.$name: 'x'},
          ),
          0,
        );
        expect(await repo.updateAll(filter: Filter.empty, values: {}), 0);
        expect(
          await repo.updateAll(filter: Filter.empty, values: {$City.$zip: '9'}),
          4,
        );
        expect(await repo.count(filter: $City.$zip.equals('9')), 4);

        // constraint violations roll back the whole statement
        for (final id in ['a', 'b', 'd']) {
          await repo.updateById(City(id: id, name: id, zip: '9'));
        }
        await sql('CREATE UNIQUE INDEX city_name_idx ON city (name)');
        final before = await sql('SELECT count(*) FROM city_history');
        await expectLater(
          () => repo.updateAll(
            filter: Filter.empty,
            values: {$City.$name: 'Same'},
          ),
          throwsA(isA<Exception>()),
        );
        expect(
          (await sql('SELECT count(*) FROM city_history')).first[0],
          before.first[0],
        );
        expect(await repo.count(filter: $City.$name.equals('Same')), 0);
        await expectConsistent('city');
      });
    },
  );

  declareTest(
    'Revisable: deleteAll',
    environment: postgresEnvironment,
    [
      testPostgresqlService(),
      PostgresqlRevisableRepositoryService(bean: $City.bean),
    ],
    () async {
      final repo = Find<RevisableDataRepository<City>>().find();

      await asUser(() async {
        for (final (id, zip) in [('a', '1'), ('b', '1'), ('c', '2')]) {
          await repo.create(City(id: id, name: id.toUpperCase(), zip: zip));
        }

        // rolled back with the surrounding transaction
        await expectLater(
          () => repo.atomic(() async {
            expect(await repo.deleteAll(filter: Filter.empty), 3);
            expect(await repo.count(), 0);
            throw StateError('rollback');
          }),
          throwsStateError,
        );
        expect(await repo.count(), 3);

        expect(await repo.deleteAll(filter: Filter.nothing), 0);
        expect(await repo.deleteAll(filter: $City.$zip.equals('1')), 2);
        expect(await repo.readAll(), [
          isA<City>().having((e) => e.id, 'id', 'c'),
        ]);

        final tombstone = (await repo.readRevisionsById('a')).first;
        expect(tombstone.isDeleted, isTrue);
        expect(tombstone.version, 1);
        expect(tombstone.data.name, 'A');

        // already deleted elements are not deleted again
        expect(await repo.deleteAll(filter: Filter.empty), 1);
        expect(await repo.deleteAll(filter: Filter.empty), 0);

        await repo.create(City(id: 'a', name: 'A again', zip: '1'));
        expect((await repo.revisableReadById('a'))!.version, 2);
        await expectConsistent('city');
      });
    },
  );

  declareTest(
    'Revisable: bulk writes with concurrent single writes',
    environment: postgresEnvironment,
    [
      testPostgresqlService(poolSize: 10),
      PostgresqlRevisableRepositoryService(bean: $City.bean),
    ],
    () async {
      final repo = Find<RevisableDataRepository<City>>().find();
      final promoter = Find<PostgresqlRevisableRepository<Service, City>>()
          .find();

      await asUser(() async {
        final ids = [for (var i = 0; i < 20; i++) 'c$i'];
        for (final id in ids) {
          await repo.create(City(id: id, name: id, zip: '1'));
        }
        await repo.updateById(
          City(id: 'c0', name: 'scheduled', zip: '1'),
          from: DateTime.now().add(const Duration(milliseconds: 100)),
        );
        await Future<void>.delayed(const Duration(milliseconds: 150));

        final results = await Future.wait([
          repo.updateAll(filter: Filter.empty, values: {$City.$zip: '2'}),
          for (final id in ids)
            repo.updateById(City(id: id, name: '$id-single', zip: '3')),
          promoter.promoteDue(),
          repo.updateAll(filter: Filter.empty, values: {$City.$zip: '4'}),
        ]);
        expect(results.whereType<bool>(), everyElement(isTrue));

        for (final id in ids) {
          final versions = (await repo.readRevisionsById(
            id,
          )).map((e) => e.version);
          expect(versions, [for (var v = versions.first; v >= 0; v--) v]);
        }

        await promoter.promoteDue();
        await expectConsistent('city');
      });
    },
  );

  declareTest(
    'Revisable: updateAll on many elements',
    environment: postgresEnvironment,
    timeout: const Timeout(Duration(minutes: 3)),
    [
      testPostgresqlService(),
      PostgresqlRevisableRepositoryService(bean: $Person.bean),
    ],
    () async {
      final repo = Find<RevisableDataRepository<Person>>().find();

      await sqlScript('''
        INSERT INTO person_history
          (id, sys_version, sys_creator, sys_is_deleted, first_name, last_name, is_special)
          SELECT nextval('person_id_seq'), 0, 'seed', false, 'P' || g, 'L' || (g % 100), false
          FROM generate_series(1, 50000) AS g;
        INSERT INTO person
          (id, first_name, last_name, birthday, is_special, sys_version, sys_creator, sys_created, sys_from)
          SELECT id, first_name, last_name, birthday, is_special, sys_version, sys_creator, sys_created, sys_from
          FROM person_history;
      ''');

      await asUser(() async {
        expect(
          await repo.updateAll(
            filter: Filter.empty,
            values: {$Person.$isSpecial: true},
          ),
          50000,
        );
        expect(
          await repo.count(filter: $Person.$isSpecial.equals(true)),
          50000,
        );
        expect(
          await repo.deleteAll(filter: $Person.$lastName.equals('L7')),
          500,
        );
        expect(await repo.count(), 49500);
        await expectConsistent('person');
      });
    },
  );
}
