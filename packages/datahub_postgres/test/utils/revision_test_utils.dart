import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:test/test.dart';

final postgresEnvironment = ComposeEnvironment.fromFile(
  'test/single-postgres.docker-compose.yml',
);

PostgresqlService testPostgresqlService({
  String timeZone = 'UTC',
  int poolSize = 3,
}) => PostgresqlService(
  host: Config('test.services.postgres.host'),
  port: Config('test.services.postgres.5432'),
  database: Config.value('datahub_postgres'),
  username: Config.value('postgres'),
  password: Config.value('postgres'),
  useSsl: Config.value(false),
  timeZone: Config.value(timeZone),
  targetPoolSize: Config.value(poolSize),
  poolQueueLimit: Config.value(1000),
  poolTimeout: Config.value(const Duration(seconds: 60)),
);

class TestSession implements Session {
  @override
  String get debugName => 'test/$identity';

  @override
  final String identity;

  TestSession(this.identity);
}

Future<T> asUser<T>(
  Future<T> Function() body, {
  String identity = 'test-user',
}) => Context.ofZone().withSession(TestSession(identity), body);

/// Retries [body] until it completes without throwing.
Future<void> eventually(
  FutureOr<void> Function() body, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (true) {
    try {
      await body();
      return;
    } catch (_) {
      if (DateTime.now().isAfter(end)) {
        rethrow;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }
}

/// Executes [query] in its own transaction.
Future<pg.Result> sql(String query) async {
  return await Find<Postgresql>().find().runDetachedTransaction(
    (db) => db.execute(RawSql(query)),
  );
}

/// Executes [query] (which may contain multiple statements) in simple mode.
Future<void> sqlScript(String query) async {
  await Find<Postgresql>().find().runDetachedTransaction(
    (db) => db.executeLiteral(RawSql(query)),
  );
}

/// Waits until [time] has passed on the database clock.
Future<void> waitUntil(DateTime time) async {
  final delay = time.difference(DateTime.now());
  if (delay > Duration.zero) {
    await Future<void>.delayed(delay);
  }
  await eventually(() async {
    final result = await sql(
      "SELECT (statement_timestamp() AT TIME ZONE 'UTC') >= "
      "'${time.toUtc().toIso8601String()}'::timestamp",
    );
    expect(result.first.first, isTrue);
  });
}

/// Asserts that the current state table `<base>` equals the state derived
/// from `<base>_history` and that `<base>_schedule` contains exactly the
/// pending, non-superseded revisions.
///
/// Only valid while no scheduled revision is due but not promoted yet.
Future<void> expectConsistent(String base) async {
  const now = "(statement_timestamp() AT TIME ZONE 'UTC')";
  final history = '${base}_history';
  final schedule = '${base}_schedule';

  Future<int> count(String query) async =>
      (await sql('SELECT count(*) FROM ($query) AS "x"')).first.first as int;

  const derived =
      'SELECT id, sys_version FROM (SELECT DISTINCT ON (id) id, sys_version, '
      'sys_is_deleted FROM "#h" WHERE sys_from <= $now '
      'ORDER BY id, sys_version DESC) AS d WHERE NOT sys_is_deleted';

  expect(
    await count(
      '(${derived.replaceAll('#h', history)} '
      'EXCEPT SELECT id, sys_version FROM "$base") UNION ALL '
      '(SELECT id, sys_version FROM "$base" '
      'EXCEPT ${derived.replaceAll('#h', history)})',
    ),
    0,
    reason: 'current state must equal the state derived from history',
  );

  expect(
    await count(
      'SELECT 1 FROM "$base" c JOIN "$history" h '
      'ON h.id = c.id AND h.sys_version = c.sys_version '
      "WHERE to_jsonb(c) IS DISTINCT FROM (to_jsonb(h) - 'sys_is_deleted')",
    ),
    0,
    reason: 'current rows must equal their history rows',
  );

  const expectedSchedule =
      'SELECT id, sys_version FROM (SELECT id, sys_version, sys_from, '
      'min(sys_from) OVER (PARTITION BY id ORDER BY sys_version '
      'ROWS BETWEEN 1 FOLLOWING AND UNBOUNDED FOLLOWING) AS nxt FROM "#h") '
      'AS s WHERE sys_from > $now AND (nxt IS NULL OR sys_from < nxt)';

  expect(
    await count(
      '(${expectedSchedule.replaceAll('#h', history)} '
      'EXCEPT SELECT id, sys_version FROM "$schedule") UNION ALL '
      '(SELECT id, sys_version FROM "$schedule" '
      'EXCEPT ${expectedSchedule.replaceAll('#h', history)})',
    ),
    0,
    reason: 'schedule must contain exactly the pending revisions',
  );

  expect(
    await count(
      'SELECT 1 FROM "$schedule" q LEFT JOIN "$history" h '
      'ON h.id = q.id AND h.sys_version = q.sys_version '
      'WHERE h.id IS NULL OR h.sys_from <> q.sys_from',
    ),
    0,
    reason: 'schedule entries must match their history rows',
  );
}
