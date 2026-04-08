import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import 'data/person.dart';

void main() {
  declareTest(
    'Postgresql Table Repository',
    [
      PostgresqlService(
        database: Config.value('datahub_postgres'),
        username: Config.value('postgres'),
        password: Config.value('postgres'),
        useSsl: Config.value(false),
      ),
      PostgresqlRevisableRepositoryService(bean: $Person.bean),
    ],
    () async {
      final postgres = Find<Postgresql>().find();
      final dataRepo = Find<DataRepository<Person>>().find();
      final revisableRepo = Find<RevisableDataRepository<Person>>().find();
      await postgres.useConnection((connection) async {
        await connection.runTransaction((context) async {
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
        });
      });
    },
  );
}
