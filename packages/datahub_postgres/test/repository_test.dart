import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/expect.dart';

import 'data/person.dart';

void main() {
  declareTest(
    'Postgresql Table Repository',
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
      PostgresqlDataRepositoryService(bean: $Person.bean),
    ],
    () async {
      final postgres = Find<Postgresql>().find();
      final repo = Find<DataRepository<Person>>().find();
      await postgres.useConnection((connection) async {
        await connection.runTransaction((context) async {
          expect(await repo.count(), equals(0));
          await repo.create(
            Person(
              firstName: 'Something',
              lastName: 'Something Else',
              birthday: null,
              isSpecial: false,
            ),
          );

          final data = await repo.readAll();
          expect(data, hasLength(1));

          expect(data.first.birthday, isNull);
          expect(data.first.firstName, 'Something');
          expect(data.first.lastName, 'Something Else');
          expect(data.first.isSpecial, isFalse);

          final count = await repo.count();
          final countWithFilter = await repo.count(
            filter: $Person.$isSpecial.equals(true),
          );

          expect(count, equals(data.length));
          expect(
            countWithFilter,
            equals(data.where((d) => d.isSpecial).length),
          );

          expect(await repo.any(), isTrue);
          expect(
            await repo.any(filter: $Person.$isSpecial.equals(true)),
            isFalse,
          );
          expect(
            await repo.any(filter: $Person.$firstName.equals('Something')),
            isTrue,
          );

          expect(
            await repo.first(),
            isA<Person>().having((e) => e.firstName, 'firstName', 'Something'),
          );
          expect(
            await repo.first(filter: $Person.$isSpecial.equals(true)),
            isNull,
          );

          await repo.create(
            Person(
              firstName: 'Another',
              lastName: 'Person',
              birthday: null,
              isSpecial: true,
            ),
          );

          expect(
            await repo.any(filter: $Person.$isSpecial.equals(true)),
            isTrue,
          );
          expect(
            await repo.first(filter: $Person.$isSpecial.equals(true)),
            isA<Person>().having((e) => e.firstName, 'firstName', 'Another'),
          );
          expect(
            await repo.first(sort: $Person.$firstName.asc()),
            isA<Person>().having((e) => e.firstName, 'firstName', 'Another'),
          );
          expect(
            await repo.first(sort: $Person.$firstName.desc()),
            isA<Person>().having((e) => e.firstName, 'firstName', 'Something'),
          );
          expect(
            await repo.first(sort: $Person.$firstName.asc(), offset: 1),
            isA<Person>().having((e) => e.firstName, 'firstName', 'Something'),
          );
        });
      });
    },
  );
}
