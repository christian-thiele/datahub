import 'dart:math';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import 'data/city.dart';
import 'data/person.dart';
import 'utils/revision_test_utils.dart';

void main() {
  declareTest(
    'Revisable: concurrent writes',
    environment: postgresEnvironment,
    [
      testPostgresqlService(poolSize: 10),
      PostgresqlRevisableRepositoryService(bean: $Person.bean),
      PostgresqlRevisableRepositoryService(bean: $City.bean),
    ],
    () async {
      final persons = Find<RevisableDataRepository<Person>>().find();
      final cities = Find<RevisableDataRepository<City>>().find();

      await asUser(() async {
        // concurrent updates of one element are serialized, versions stay
        // gap-free and no update fails
        final peter = await persons.create(
          Person(firstName: 'Peter', lastName: 'Lustig', birthday: null),
        );
        final updated = await Future.wait([
          for (var i = 0; i < 20; i++)
            persons.updateById(peter.copyWith(lastName: 'L$i')),
        ]);
        expect(updated, everyElement(isTrue));
        final revisions = await persons.readRevisionsById(peter.id);
        expect(revisions.map((e) => e.version), [
          for (var i = 20; i >= 0; i--) i,
        ]);
        expect((await persons.revisableReadById(peter.id))!.version, 20);

        // concurrent creates of the same id: exactly one wins
        final results = await Future.wait([
          for (var i = 0; i < 10; i++)
            cities
                .create(City(id: 'berlin', name: 'Berlin $i', zip: '1'))
                .then<Object>((e) => e, onError: (Object e) => e),
        ]);
        expect(results.whereType<City>(), hasLength(1));
        expect(
          results.whereType<RevisableInconsistencyException>(),
          hasLength(9),
        );

        // concurrent creates with generated ids
        final created = await Future.wait([
          for (var i = 0; i < 20; i++)
            persons.create(
              Person(firstName: 'P$i', lastName: 'Lustig', birthday: null),
            ),
        ]);
        expect(created.map((e) => e.id).toSet(), hasLength(20));
        expect(await persons.count(), 21);

        await expectConsistent('person');
        await expectConsistent('city');
      });
    },
  );

  declareTest(
    'Revisable: concurrent schedules, writes and promotions',
    environment: postgresEnvironment,
    [
      testPostgresqlService(poolSize: 10),
      PostgresqlRevisableRepositoryService(bean: $City.bean),
    ],
    () async {
      final repo = Find<RevisableDataRepository<City>>().find();
      final promoter = Find<PostgresqlRevisableRepository<Service, City>>()
          .find();
      final random = Random(42);

      await asUser(() async {
        final ids = [for (var i = 0; i < 40; i++) 'c$i'];
        for (final id in ids.take(30)) {
          await repo.create(City(id: id, name: id, zip: '0'));
        }

        final start = DateTime.now();
        final end = start.add(const Duration(milliseconds: 1500));

        Future<void> writer(int seed) async {
          final random = Random(seed);
          while (DateTime.now().isBefore(end)) {
            final id = ids[random.nextInt(ids.length)];
            final from = random.nextBool()
                ? DateTime.now().add(
                    Duration(milliseconds: 50 + random.nextInt(1000)),
                  )
                : null;
            final city = City(
              id: id,
              name: '$id-${random.nextInt(1000)}',
              zip: '0',
            );

            switch (random.nextInt(3)) {
              case 0:
                await repo.updateById(city, from: from);
              case 1:
                await repo.deleteById(id, from: from);
              default:
                try {
                  await repo.create(city, from: from);
                } on RevisableInconsistencyException catch (_) {}
            }
          }
        }

        Future<void> promoting() async {
          while (DateTime.now().isBefore(end)) {
            await promoter.promoteDue();
          }
        }

        await Future.wait([
          for (var i = 0; i < 6; i++) writer(random.nextInt(1 << 30)),
          for (var i = 0; i < 4; i++) promoting(),
        ]);

        // everything scheduled is due now, wait until promoted and committed
        await waitUntil(end.add(const Duration(milliseconds: 1100)));
        await eventually(() async {
          await promoter.promoteDue();
          expect((await sql('SELECT count(*) FROM city_schedule')).first[0], 0);
        });
        await expectConsistent('city');
      });
    },
  );
}
