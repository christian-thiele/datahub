import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

/// The value of the sample [name] with exactly [labels], or null if it was
/// not exported.
Future<num?> _metric(
  String name, [
  Map<String, String> labels = const {},
]) async {
  final groups = await Find<Telemetry>().find().scrapeMetrics();
  for (final sample in groups.expand((g) => g.samples)) {
    if (sample.name == name && equals(labels).matches(sample.labels, {})) {
      return sample.value;
    }
  }
  return null;
}

void main() {
  declareTest(
    'PostgreSQL telemetry',
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
    ],
    () async {
      final spans = <LocalSpan>[];
      final subscription = Find<Telemetry>().find().endedSpans.listen(
        spans.add,
      );
      final postgres = Find<Postgresql>().find();

      await postgres.runTransaction(
        (context) => context.execute(RawSql('SELECT 1337;')),
      );
      await expectLater(
        postgres.runTransaction(
          (context) => context.execute(RawSql('SELECT * FROM missing;')),
        ),
        throwsA(anything),
      );
      await subscription.cancel();

      final select = spans.firstWhere((s) => s.type == SpanType.client);
      expect(select.name, equals('SELECT'));
      expect(select.attributes['db.system.name'], equals('postgresql'));
      expect(select.attributes['db.namespace'], equals('datahub_postgres'));
      expect(select.attributes['db.operation.name'], equals('SELECT'));
      expect(select.attributes['db.query.text'], equals('SELECT 1337;'));
      expect(select.attributes['server.port'], isA<int>());
      expect(select.parent, isA<LocalSpan>());
      expect((select.parent! as LocalSpan).name, 'postgresql transaction');

      final failed = spans.lastWhere((s) => s.type == SpanType.client);
      expect(failed.hasError, isTrue);
      // undefined_table
      expect(failed.attributes['db.response.status_code'], equals('42P01'));
      expect(failed.attributes['error.type'], equals('42P01'));

      expect(
        await _metric('postgresql_queries_total', {'status': 'ok'}),
        greaterThanOrEqualTo(1),
      );
      expect(
        await _metric('postgresql_queries_total', {'status': 'error'}),
        equals(1),
      );
      expect(
        await _metric('postgresql_query_duration_seconds_count'),
        greaterThanOrEqualTo(2),
      );
      expect(await _metric('postgresql_pool_size_target'), equals(3));
      // connections are reset (DISCARD ALL) before they are available again
      for (var i = 0; i < 50; i++) {
        if (await _metric('postgresql_pool_size_in_use') == 0) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 20));
      }
      expect(await _metric('postgresql_pool_size_in_use'), equals(0));
      expect(
        await _metric('postgresql_pool_wait_seconds_count'),
        greaterThanOrEqualTo(2),
      );
    },
  );
}
