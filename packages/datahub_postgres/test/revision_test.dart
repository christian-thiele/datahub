import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import 'data/city.dart';
import 'data/person.dart';

class TestSession implements Session {
  @override
  String get debugName => 'test/$identity';

  @override
  final String identity;

  TestSession(this.identity);
}

void main() {
  declareTest(
    'Revisable: Simple CRUD',
    environment: ComposeEnvironment.fromFile(
      'test/single-postgres.docker-compose.yml',
    ),
    [
      PostgresqlService(
        host: Config('test.services.postgres.host'),
        port: Config('test.services.postgres.5432'),
        database: Config.value('datahub_postgres'),
        username: Config.value('postgres'),
        password: Config.value('postgres'),
        useSsl: Config.value(false),
      ),
      PostgresqlRevisableRepositoryService(bean: $Person.bean),
    ],
    () async {
      final dataRepo = Find<DataRepository<Person>>().find();
      final revisableRepo = Find<RevisableDataRepository<Person>>().find();

      await Context.ofZone().withSession(TestSession('test-user'), () async {
        expect(await dataRepo.count(), equals(0));
        final created = await dataRepo.create(
          Person(
            firstName: 'Peter',
            lastName: 'Lustig',
            birthday: DateTime.utc(1937, 10, 27),
          ),
        );

        expect(
          created,
          isA<Person>()
              .having((e) => e.firstName, 'firstName', 'Peter')
              .having((e) => e.lastName, 'lastName', 'Lustig')
              .having((e) => e.birthday, 'birthday', DateTime.utc(1937, 10, 27))
              .having((e) => e.id, 'id', greaterThan(0)),
        );

        expect(await dataRepo.count(), equals(1));
        expect(
          await dataRepo.first(),
          isA<Person>()
              .having((e) => e.firstName, 'firstName', 'Peter')
              .having((e) => e.lastName, 'lastName', 'Lustig')
              .having((e) => e.birthday, 'birthday', DateTime.utc(1937, 10, 27))
              .having((e) => e.id, 'id', created.id),
        );

        expect(await dataRepo.any(), isTrue);
        expect(
          await dataRepo.any(filter: $Person.$firstName.equals('Peter')),
          isTrue,
        );
        expect(
          await dataRepo.any(filter: $Person.$firstName.equals('Nobody')),
          isFalse,
        );
        expect(
          await dataRepo.first(filter: $Person.$firstName.equals('Nobody')),
          isNull,
        );

        expect(
          await revisableRepo.revisableReadById(created.id),
          isA<RevisionData<Person>>()
              .having((e) => e.version, 'version', 0)
              .having((e) => e.creator, 'creator', 'test-user')
              .having((e) => e.to, 'to', isNull)
              .having(
                (e) => e.data,
                'data',
                isA<Person>()
                    .having((e) => e.firstName, 'firstName', 'Peter')
                    .having((e) => e.lastName, 'lastName', 'Lustig'),
              ),
        );

        expect((await revisableRepo.readRevisionsById(created.id)).length, 1);

        await dataRepo.updateById(created.copyWith(isSpecial: true));

        final revisions = await revisableRepo.readRevisionsById(created.id);
        expect(revisions.length, 2);

        expect(
          revisions.first,
          isA<RevisionData<Person>>()
              .having((e) => e.version, 'version', 1)
              .having((e) => e.to, 'to', isNull)
              .having(
                (e) => e.data,
                'data',
                isA<Person>()
                    .having((e) => e.firstName, 'firstName', 'Peter')
                    .having((e) => e.lastName, 'lastName', 'Lustig')
                    .having((e) => e.isSpecial, 'isSpecial', true),
              ),
        );

        expect(
          revisions.last,
          isA<RevisionData<Person>>()
              .having((e) => e.version, 'version', 0)
              .having((e) => e.to, 'to', isNotNull)
              .having(
                (e) => e.data,
                'data',
                isA<Person>()
                    .having((e) => e.firstName, 'firstName', 'Peter')
                    .having((e) => e.lastName, 'lastName', 'Lustig')
                    .having((e) => e.isSpecial, 'isSpecial', false),
              ),
        );

        final second = await dataRepo.create(
          Person(
            firstName: 'Anna',
            lastName: 'Lustig',
            birthday: DateTime.utc(1940, 1, 1),
          ),
        );

        expect(
          await dataRepo.first(sort: $Person.$firstName.asc()),
          isA<Person>().having((e) => e.id, 'id', second.id),
        );
        expect(
          await dataRepo.first(sort: $Person.$firstName.desc()),
          isA<Person>().having((e) => e.id, 'id', created.id),
        );
        expect(
          await dataRepo.first(sort: $Person.$firstName.asc(), offset: 1),
          isA<Person>().having((e) => e.id, 'id', created.id),
        );

        await dataRepo.deleteById(second.id);

        await dataRepo.deleteById(created.id);
        expect(await revisableRepo.readRevisionsById(created.id), hasLength(3));
        expect(await dataRepo.count(), equals(0));
        expect(await dataRepo.any(), isFalse);
      });
    },
  );

  declareTest(
    'Revisable: Simple CRUD in transaction',
    environment: ComposeEnvironment.fromFile(
      'test/single-postgres.docker-compose.yml',
    ),
    [
      PostgresqlService(
        host: Config('test.services.postgres.host'),
        port: Config('test.services.postgres.5432'),
        database: Config.value('datahub_postgres'),
        username: Config.value('postgres'),
        password: Config.value('postgres'),
        useSsl: Config.value(false),
      ),
      PostgresqlRevisableRepositoryService(bean: $Person.bean),
    ],
    () async {
      await Context.ofZone().withSession(TestSession('test-user'), () async {
        final dataRepo = Find<DataRepository<Person>>().find();
        final revisableRepo = Find<RevisableDataRepository<Person>>().find();

        await dataRepo.atomic(() async {
          expect(await dataRepo.count(), equals(0));
          final created = await dataRepo.create(
            Person(
              firstName: 'Peter',
              lastName: 'Lustig',
              birthday: DateTime.utc(1937, 10, 27),
            ),
          );

          expect(
            created,
            isA<Person>()
                .having((e) => e.firstName, 'firstName', 'Peter')
                .having((e) => e.lastName, 'lastName', 'Lustig')
                .having(
                  (e) => e.birthday,
                  'birthday',
                  DateTime.utc(1937, 10, 27),
                )
                .having((e) => e.id, 'id', greaterThan(0)),
          );

          expect(await dataRepo.count(), equals(1));
          expect(
            await dataRepo.first(),
            isA<Person>()
                .having((e) => e.firstName, 'firstName', 'Peter')
                .having((e) => e.lastName, 'lastName', 'Lustig')
                .having(
                  (e) => e.birthday,
                  'birthday',
                  DateTime.utc(1937, 10, 27),
                )
                .having((e) => e.id, 'id', created.id),
          );

          expect(
            await revisableRepo.revisableReadById(created.id),
            isA<RevisionData<Person>>()
                .having((e) => e.version, 'version', 0)
                .having((e) => e.to, 'to', isNull)
                .having((e) => e.creator, 'creator', 'test-user')
                .having(
                  (e) => e.data,
                  'data',
                  isA<Person>()
                      .having((e) => e.firstName, 'firstName', 'Peter')
                      .having((e) => e.lastName, 'lastName', 'Lustig'),
                ),
          );

          expect((await revisableRepo.readRevisionsById(created.id)).length, 1);

          await dataRepo.updateById(created.copyWith(isSpecial: true));

          final revisions = await revisableRepo.readRevisionsById(created.id);
          expect(revisions.length, 2);

          expect(
            revisions.first,
            isA<RevisionData<Person>>()
                .having((e) => e.version, 'version', 1)
                .having((e) => e.to, 'to', isNull)
                .having(
                  (e) => e.data,
                  'data',
                  isA<Person>()
                      .having((e) => e.firstName, 'firstName', 'Peter')
                      .having((e) => e.lastName, 'lastName', 'Lustig')
                      .having((e) => e.isSpecial, 'isSpecial', true),
                ),
          );

          expect(
            revisions.last,
            isA<RevisionData<Person>>()
                .having((e) => e.version, 'version', 0)
                .having((e) => e.to, 'to', isNotNull)
                .having(
                  (e) => e.data,
                  'data',
                  isA<Person>()
                      .having((e) => e.firstName, 'firstName', 'Peter')
                      .having((e) => e.lastName, 'lastName', 'Lustig')
                      .having((e) => e.isSpecial, 'isSpecial', false),
                ),
          );

          await dataRepo.deleteById(created.id);
          expect(
            await revisableRepo.readRevisionsById(created.id),
            hasLength(3),
          );
          expect(await dataRepo.count(), equals(0));
        });
      });
    },
  );

  declareTest(
    'Revisable: Revive deleted element',
    environment: ComposeEnvironment.fromFile(
      'test/single-postgres.docker-compose.yml',
    ),
    [
      PostgresqlService(
        host: Config('test.services.postgres.host'),
        port: Config('test.services.postgres.5432'),
        database: Config.value('datahub_postgres'),
        username: Config.value('postgres'),
        password: Config.value('postgres'),
        useSsl: Config.value(false),
      ),
      PostgresqlRevisableRepositoryService(bean: $City.bean),
    ],
    () async {
      await Context.ofZone().withSession(TestSession('test-user'), () async {
        final dataRepo = Find<DataRepository<City>>().find();
        final revisableRepo = Find<RevisableDataRepository<City>>().find();

        expect(await dataRepo.count(), equals(0));
        expect(await revisableRepo.readRevisionsById('berlin'), hasLength(0));

        final created = await dataRepo.create(
          City(id: 'berlin', name: 'Berlin', zip: '12345'),
        );
        expect(await dataRepo.count(), equals(1));
        await expectLater(() async {
          await dataRepo.create(
            City(id: 'berlin', name: 'Berlin', zip: '12345'),
          );
        }, throwsA(isA<RevisableInconsistencyException>()));

        await dataRepo.deleteById(created.id);
        expect(await dataRepo.count(), equals(0));

        await dataRepo.create(City(id: 'berlin', name: 'Berlin', zip: '12345'));
        expect(await dataRepo.count(), equals(1));

        await dataRepo.deleteById(created.id);
        expect(await dataRepo.count(), equals(0));

        expect(await revisableRepo.readRevisionsById('berlin'), hasLength(4));
      });
    },
  );

  declareTest(
    'Revisable: Revive deleted element in transaction',
    environment: ComposeEnvironment.fromFile(
      'test/single-postgres.docker-compose.yml',
    ),
    [
      PostgresqlService(
        host: Config('test.services.postgres.host'),
        port: Config('test.services.postgres.5432'),
        database: Config.value('datahub_postgres'),
        username: Config.value('postgres'),
        password: Config.value('postgres'),
        useSsl: Config.value(false),
      ),
      PostgresqlRevisableRepositoryService(bean: $City.bean),
    ],
    () async {
      final dataRepo = Find<DataRepository<City>>().find();
      await Context.ofZone().withSession(TestSession('test-user'), () async {
        await dataRepo.atomic(() async {
          expect(await dataRepo.count(), equals(0));
          final created = await dataRepo.create(
            City(id: 'berlin', name: 'Berlin', zip: '12345'),
          );
          expect(await dataRepo.count(), equals(1));
          await expectLater(() async {
            await dataRepo.create(
              City(id: 'berlin', name: 'Berlin', zip: '12345'),
            );
          }, throwsA(isA<RevisableInconsistencyException>()));

          await dataRepo.deleteById(created.id);
          expect(await dataRepo.count(), equals(0));

          await dataRepo.create(
            City(id: 'berlin', name: 'Berlin', zip: '12345'),
          );
          expect(await dataRepo.count(), equals(1));
        });
      });
    },
  );
}
