import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import 'data/person.dart';
import 'utils/revision_test_utils.dart';

/// View definition of datahub_postgres 0.18.0-dev.23.
const _joinView = '''
  CREATE VIEW "public"."person" AS SELECT "person_revision".*
  FROM "public"."person_revision" INNER JOIN (
    SELECT "person_revision"."id", MAX("person_revision"."sys_version") AS "sys_version_max"
    FROM "public"."person_revision"
    WHERE now() >= "person_revision"."sys_from"
      AND ("person_revision"."sys_to" IS NULL OR now() <= "person_revision"."sys_to")
    GROUP BY "person_revision"."id") "sys_latest"
  ON "person_revision"."id"= "sys_latest"."id" AND "sys_version"= "sys_latest"."sys_version_max"
  WHERE NOT "sys_is_deleted";
''';

/// View definition before commit 2e080d2.
const _distinctOnView = '''
  CREATE VIEW "public"."person" AS SELECT * FROM (
    SELECT DISTINCT ON ("id") * FROM "public"."person_revision"
    WHERE ((now() BETWEEN "sys_from" AND "sys_to") OR (now() >= "sys_from" AND "sys_to" IS NULL))
    ORDER BY "id", "sys_version" DESC) AS "sub"
  WHERE NOT "sys_is_deleted";
''';

/// Revisions per element as (version, sys_from offset, deleted).
const _revisions = {
  // live
  1: [(0, '-1 day', false)],
  // updated
  2: [(0, '-2 days', false), (1, '-1 day', false)],
  // deleted
  3: [(0, '-2 days', false), (1, '-1 day', true)],
  // revived
  4: [(0, '-3 days', false), (1, '-2 days', true), (2, '-1 day', false)],
  // pending update
  5: [(0, '-1 day', false), (1, '1 hour', false)],
  // pending update, superseded by an immediate one
  6: [(0, '-1 day', false), (1, '1 hour', false), (2, '-1 minute', false)],
  // pending chain
  7: [(0, '-1 day', false), (1, '1 hour', false), (2, '2 hours', false)],
  // pending create
  8: [(0, '1 hour', false)],
  // pending delete
  9: [(0, '-1 day', false), (1, '1 hour', true)],
  // pending update, superseded by an earlier scheduled one
  10: [(0, '-1 day', false), (1, '2 hours', false), (2, '1 hour', false)],
};

/// Current state as returned by the legacy view, captured before migration.
List<(int, int, String)>? _legacyCurrent;

class LegacyLayoutSeeder implements Service {
  final String view;

  const LegacyLayoutSeeder(this.view);

  @override
  ServiceInstance<LegacyLayoutSeeder> createInstance() =>
      _LegacyLayoutSeederInstance();
}

class _LegacyLayoutSeederInstance extends ServiceInstance<LegacyLayoutSeeder> {
  @override
  Future<void> initialize() async {
    await super.initialize();

    final rows = [
      for (final MapEntry(key: id, value: revisions) in _revisions.entries)
        for (final (version, offset, deleted) in revisions)
          "($version, 'legacy', (now() AT TIME ZONE 'UTC') + interval '$offset', "
              "$deleted, $id, 'P$id-$version', 'Legacy', false)",
    ];

    await find(const Find<Postgresql>()).runTransaction((db) async {
      await db.executeLiteral(
        RawSql('''
          CREATE SEQUENCE "public"."person_id_seq";
          CREATE TABLE "public"."person_revision" ("sys_version" bigint NOT NULL, "sys_creator" varchar,
            "sys_created" timestamp NOT NULL DEFAULT now(), "sys_from" timestamp NOT NULL DEFAULT now(),
            "sys_to" timestamp, "sys_is_deleted" boolean NOT NULL DEFAULT false,
            "id" bigint DEFAULT nextval('public.person_id_seq') NOT NULL, "first_name" varchar NOT NULL,
            "last_name" varchar NOT NULL, "birthday" timestamp, "is_special" boolean NOT NULL,
            UNIQUE ("id","sys_version"));
          INSERT INTO "public"."person_revision"
            (sys_version, sys_creator, sys_from, sys_is_deleted, id, first_name, last_name, is_special)
            VALUES ${rows.join(', ')};
          UPDATE "public"."person_revision" r SET sys_to = n.sys_from FROM "public"."person_revision" n
            WHERE n.id = r.id AND n.sys_version = r.sys_version + 1;
          SELECT setval('public.person_id_seq', 10);
          ${service.view}
        '''),
      );

      _legacyCurrent = [
        for (final row in await db.execute(
          RawSql('SELECT id, sys_version, first_name FROM person ORDER BY id'),
        ))
          (row[0] as int, row[1] as int, row[2] as String),
      ];
    });
  }
}

void main() {
  for (final (name, view) in [
    ('join view', _joinView),
    ('distinct on view', _distinctOnView),
  ]) {
    declareTest(
      'Revisable: migrate from $name',
      environment: postgresEnvironment,
      [
        testPostgresqlService(),
        LegacyLayoutSeeder(view),
        PostgresqlRevisableRepositoryService(bean: $Person.bean),
        // a second instance initializes on the migrated layout
        PostgresqlRevisableRepositoryService(bean: $Person.bean),
      ],
      () async {
        final repo = Find<RevisableDataRepository<Person>>().find();

        expect(_legacyCurrent, [
          (1, 0, 'P1-0'),
          (2, 1, 'P2-1'),
          (4, 2, 'P4-2'),
          (5, 0, 'P5-0'),
          (6, 2, 'P6-2'),
          (7, 0, 'P7-0'),
          (9, 0, 'P9-0'),
          (10, 0, 'P10-0'),
        ]);

        final kinds = await sql(
          "SELECT relname, relkind::text FROM pg_class WHERE relname LIKE 'person%' "
          "AND relkind IN ('r', 'v') ORDER BY relname",
        );
        expect(kinds.map((r) => (r[0], r[1])), [
          ('person', 'r'),
          ('person_history', 'r'),
          ('person_schedule', 'r'),
        ]);
        expect(
          await sql(
            "SELECT 1 FROM information_schema.columns WHERE column_name = 'sys_to'",
          ),
          isEmpty,
        );

        final current = await repo.revisableReadAll(sort: $Person.$id.asc());
        expect(
          current.map((e) => (e.data.id, e.version, e.data.firstName)),
          _legacyCurrent,
        );

        final schedule = await sql(
          'SELECT id, sys_version FROM person_schedule ORDER BY id, sys_version',
        );
        expect(schedule.map((r) => (r[0], r[1])), [
          (5, 1),
          (7, 1),
          (7, 2),
          (8, 0),
          (9, 1),
          (10, 2),
        ]);
        await expectConsistent('person');

        // the migrated repository keeps working
        await asUser(() async {
          final p1 = await repo.readById(1);
          expect(await repo.updateById(p1!.copyWith(isSpecial: true)), isTrue);
          expect((await repo.revisableReadById(1))!.version, 1);

          final created = await repo.create(
            Person(firstName: 'New', lastName: 'Person', birthday: null),
          );
          expect(created.id, 11);

          expect(await repo.deleteById(5), isTrue);
          expect(await repo.readById(5), isNull);

          final revisions = await repo.readRevisionsById(6);
          expect(revisions.map((e) => e.version), [2, 1, 0]);
          // superseded before it became effective
          expect(revisions[1].to!.isAfter(revisions[1].from), isFalse);
        });
        await expectConsistent('person');
      },
    );
  }
}
