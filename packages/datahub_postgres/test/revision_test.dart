import 'dart:convert';

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
        host: Config.value('192.168.178.85'),
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
      expect(() async {
        await postgres.useConnection((connection) async {
          await connection.runTransaction((context) async {
            final data = await repo.readAll();
            print('${data.length} entries:');
            for (final entry in data) {
              print(jsonEncode(entry.toJson()));
            }

            throw Exception('done');
          });
        });
      }, throwsA(isA<Exception>()));
    },
  );
}
