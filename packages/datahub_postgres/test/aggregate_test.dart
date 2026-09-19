import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import 'data/person.dart';
import 'data/sale.dart';

final _environment = ComposeEnvironment.fromFile(
  'test/single-postgres.docker-compose.yml',
);

PostgresqlService _postgresService() => PostgresqlService(
  host: Config('test.services.postgres.host'),
  port: Config('test.services.postgres.5432'),
  database: Config.value('datahub_postgres'),
  username: Config.value('postgres'),
  password: Config.value('postgres'),
  useSsl: Config.value(false),
);

PostgresqlDataRelation _relationOf(DataRepository repo) =>
    (repo as PostgresqlDataRepository).dataRelation;

Future<void> _createSales(DataRepository<Sale> repo) async {
  for (final sale in [
    Sale(region: 'north', quantity: 2, price: 10.0),
    Sale(region: 'north', quantity: 4, price: 20.0),
    Sale(region: 'south', quantity: 5, price: 7.5),
  ]) {
    await repo.create(sale);
  }
}

void main() {
  declareTest(
    'Postgresql Aggregate Round Trip',
    environment: _environment,
    [_postgresService(), PostgresqlDataRepositoryService(bean: $Sale.bean)],
    () async {
      final postgres = Find<Postgresql>().find();
      final repo = Find<DataRepository<Sale>>().find();
      final relation = _relationOf(repo);

      await _createSales(repo);

      await postgres.runTransaction((context) async {
        // one aggregate of each type, grouped
        final grouped = await relation.select(
          context,
          [
            $Sale.$region,
            const AggregateExpression.count(),
            $Sale.$quantity.sum(),
            $Sale.$quantity.min(),
            $Sale.$price.max(),
            $Sale.$price.avg(),
          ],
          group: [$Sale.$region],
          sort: $Sale.$region.asc(),
        );

        expect(grouped, hasLength(2));
        expect(grouped[0], {
          'region': 'north',
          'count': 2,
          'sum': 6,
          'min': 2,
          'max': 20.0,
          'avg': 15.0,
        });
        expect(grouped[1], {
          'region': 'south',
          'count': 1,
          'sum': 5,
          'min': 5,
          'max': 7.5,
          'avg': 7.5,
        });

        // aggregates over the whole relation, with filter
        final filtered = await relation.select(context, [
          const AggregateExpression.count(),
          $Sale.$quantity.sum(),
        ], filter: $Sale.$price.greaterThan(8.0));
        expect(filtered, [
          {'count': 2, 'sum': 6},
        ]);

        // empty input: COUNT yields 0, other aggregates yield null
        final empty = await relation.select(context, [
          const AggregateExpression.count(),
          $Sale.$quantity.sum(),
        ], filter: $Sale.$region.equals('west'));
        expect(empty, [
          {'count': 0, 'sum': null},
        ]);

        // multiple aggregates of the same type must not overwrite each other
        final sums = await relation.select(context, [
          PostgresqlAliasExpression('total_quantity', $Sale.$quantity.sum()),
          PostgresqlAliasExpression('total_price', $Sale.$price.sum()),
        ]);
        expect(sums, hasLength(1));
        expect(sums.single.values, unorderedEquals([11, 37.5]));
        expect(
          sums.single.keys,
          unorderedEquals(['total_quantity', 'total_price']),
        );
      });
    },
  );

  declareTest(
    'Postgresql Aggregate Result Types',
    environment: _environment,
    [_postgresService(), PostgresqlDataRepositoryService(bean: $Sale.bean)],
    () async {
      final postgres = Find<Postgresql>().find();
      final repo = Find<DataRepository<Sale>>().find();
      final relation = _relationOf(repo);

      await _createSales(repo);

      await postgres.runTransaction((context) async {
        final result = await relation.select(context, [
          PostgresqlAliasExpression('count', const AggregateExpression.count()),
          PostgresqlAliasExpression('sum_quantity', $Sale.$quantity.sum()),
          PostgresqlAliasExpression('min_quantity', $Sale.$quantity.min()),
          PostgresqlAliasExpression('max_quantity', $Sale.$quantity.max()),
          PostgresqlAliasExpression('avg_quantity', $Sale.$quantity.avg()),
          PostgresqlAliasExpression('sum_price', $Sale.$price.sum()),
          PostgresqlAliasExpression('min_price', $Sale.$price.min()),
          PostgresqlAliasExpression('max_price', $Sale.$price.max()),
          PostgresqlAliasExpression('avg_price', $Sale.$price.avg()),
        ]);
        final row = result.single;

        // int columns stay int (6 == 6.0 in Dart, so check the type explicitly)
        expect(row['count'], allOf(isA<int>(), equals(3)));
        expect(row['sum_quantity'], allOf(isA<int>(), equals(11)));
        expect(row['min_quantity'], allOf(isA<int>(), equals(2)));
        expect(row['max_quantity'], allOf(isA<int>(), equals(5)));

        // AVG is fractional even for int columns
        expect(
          row['avg_quantity'],
          allOf(isA<double>(), closeTo(11 / 3, 1e-9)),
        );

        expect(row['sum_price'], allOf(isA<double>(), equals(37.5)));
        expect(row['min_price'], allOf(isA<double>(), equals(7.5)));
        expect(row['max_price'], allOf(isA<double>(), equals(20.0)));
        expect(row['avg_price'], allOf(isA<double>(), equals(12.5)));
      });
    },
  );

  declareTest(
    'Postgresql Aggregate Non-Numeric Columns',
    environment: _environment,
    [_postgresService(), PostgresqlDataRepositoryService(bean: $Person.bean)],
    () async {
      final postgres = Find<Postgresql>().find();
      final repo = Find<DataRepository<Person>>().find();
      final relation = _relationOf(repo);

      for (final person in [
        Person(
          firstName: 'Carla',
          lastName: 'C',
          birthday: DateTime.utc(1990, 5),
        ),
        Person(firstName: 'Anna', lastName: 'A', birthday: DateTime.utc(1985)),
        Person(firstName: 'Bert', lastName: 'B', birthday: null),
      ]) {
        await repo.create(person);
      }

      await postgres.runTransaction((context) async {
        final result = await relation.select(context, [
          PostgresqlAliasExpression('min_name', $Person.$firstName.min()),
          PostgresqlAliasExpression('max_name', $Person.$firstName.max()),
          PostgresqlAliasExpression('min_birthday', $Person.$birthday.min()),
          PostgresqlAliasExpression('max_birthday', $Person.$birthday.max()),
        ]);
        final row = result.single;

        expect(row['min_name'], allOf(isA<String>(), equals('Anna')));
        expect(row['max_name'], allOf(isA<String>(), equals('Carla')));

        // MIN / MAX ignore NULL values
        expect(
          row['min_birthday'],
          isA<DateTime>().having((e) => e.toUtc(), 'utc', DateTime.utc(1985)),
        );
        expect(
          row['max_birthday'],
          isA<DateTime>().having(
            (e) => e.toUtc(),
            'utc',
            DateTime.utc(1990, 5),
          ),
        );
      });

      await postgres.runTransaction((context) async {
        // COUNT(field) only counts non-null values, COUNT(*) counts all rows
        final result = await relation.select(context, [
          PostgresqlAliasExpression('all', const AggregateExpression.count()),
          PostgresqlAliasExpression(
            'with_birthday',
            AggregateExpression(AggregateType.count, $Person.$birthday),
          ),
        ]);
        expect(result.single, {'all': 3, 'with_birthday': 2});
      });
    },
  );

  declareTest(
    'Postgresql Aggregate Alias Usage',
    environment: _environment,
    [_postgresService(), PostgresqlDataRepositoryService(bean: $Sale.bean)],
    () async {
      final postgres = Find<Postgresql>().find();
      final repo = Find<DataRepository<Sale>>().find();
      final relation = _relationOf(repo);

      await _createSales(repo);

      final region = PostgresqlAliasExpression('r', $Sale.$region);
      final total = PostgresqlAliasExpression('total', $Sale.$quantity.sum());

      await postgres.runTransaction((context) async {
        // alias in group and sort must render without "AS"
        final sorted = await relation.select(
          context,
          [region, total],
          group: [region],
          sort: total.asc(),
        );
        expect(sorted, [
          {'r': 'south', 'total': 5},
          {'r': 'north', 'total': 6},
        ]);

        final sortedDesc = await relation.select(
          context,
          [region, total],
          group: [region],
          sort: total.desc(),
        );
        expect(sortedDesc.map((e) => e['r']), ['north', 'south']);

        // alias in filter must render without "AS"
        final filtered = await relation.select(
          context,
          [region, total],
          group: [region],
          filter: region.equals('north'),
        );
        expect(filtered, [
          {'r': 'north', 'total': 6},
        ]);
      });
    },
  );
}
