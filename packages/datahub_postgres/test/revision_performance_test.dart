import 'dart:convert';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import 'data/person.dart';
import 'utils/revision_test_utils.dart';

void main() {
  declareTest(
    'Revisable: filtered reads use indices of the current state table',
    environment: postgresEnvironment,
    [
      testPostgresqlService(),
      PostgresqlRevisableRepositoryService(bean: $Person.bean),
    ],
    () async {
      final repo = Find<PostgresqlRevisableRepository<Service, Person>>()
          .find();

      // 5000 elements with 10 revisions each
      await sqlScript('''
        INSERT INTO person_history
          (id, sys_version, sys_creator, sys_is_deleted, first_name, last_name, is_special)
          SELECT g, v, 'seed', false, 'P' || g,
            CASE WHEN v = 9 THEN 'L' || (g % 500) ELSE 'Old' || v END, false
          FROM generate_series(1, 5000) AS g, generate_series(0, 9) AS v;
        SELECT setval('person_id_seq', 5000);
        INSERT INTO person
          (id, first_name, last_name, birthday, is_special, sys_version, sys_creator, sys_created, sys_from)
          SELECT id, first_name, last_name, birthday, is_special, sys_version, sys_creator, sys_created, sys_from
          FROM person_history WHERE sys_version = 9;
        CREATE INDEX person_last_name_idx ON person (last_name);
        ANALYZE person;
        ANALYZE person_history;
      ''');

      final filter = $Person.$lastName.equals('L42');
      expect(await repo.readAll(filter: filter), hasLength(10));

      final plan = await Find<Postgresql>().find().runDetachedTransaction(
        (db) => db.execute(
          RawSql('EXPLAIN (FORMAT JSON) ') +
              repo.statements.selectCurrent(filter: filter, limit: 20),
        ),
      );

      final nodes = <Map<String, dynamic>>[];
      void collect(dynamic node) {
        if (node is Map<String, dynamic>) {
          nodes.add(node);
          for (final child in node['Plans'] as List? ?? const []) {
            collect(child);
          }
        }
      }

      final json = plan.first.first;
      final decoded = json is String ? jsonDecode(json) : json;
      collect((decoded as List).first['Plan']);

      Set<String> relationsOf(Map<String, dynamic> node) => {
        if (node['Relation Name'] case final String name) name,
        for (final child in node['Plans'] as List? ?? const [])
          ...relationsOf(child as Map<String, dynamic>),
      };

      final types = nodes.map((e) => e['Node Type']).toSet();
      final indices = nodes.map((e) => e['Index Name']).nonNulls.toSet();

      expect(indices, contains('person_last_name_idx'), reason: '$types');
      expect(relationsOf(nodes.first), {'person', 'person_schedule'});
      expect(types, isNot(contains('WindowAgg')));
      // only `sys_to` of the returned rows aggregates, over the schedule queue
      for (final aggregate in nodes.where(
        (e) => e['Node Type'] == 'Aggregate',
      )) {
        expect(aggregate['Parent Relationship'], 'SubPlan');
        expect(relationsOf(aggregate), {'person_schedule'});
      }
    },
  );
}
