import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/expect.dart';

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
      PostgresqlDataRepositoryService(bean: $Person.bean),
    ],
    () async {
      final postgres = Find<Postgresql>().find();
      final repo = Find<DataRepository<Person>>().find();
      await postgres.useConnection((connection) async {
        await connection.runTransaction((context) async {
          await repo.create(
            Person(
              firstName: 'Something',
              lastName: 'Something Else',
              birthday: null,
              isSpecial: false,
            ),
          );

          final data = await repo.readAll();
          expect(data, isNotEmpty);

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
        });
      });
    },
  );
}
