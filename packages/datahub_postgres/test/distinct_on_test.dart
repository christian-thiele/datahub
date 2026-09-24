import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_postgres/datahub_postgres.dart';
import 'package:test/test.dart';

import 'data/city.dart';
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

PostgresqlDataRelation<T> _relationOf<T extends DataObject<T>>(
  DataRepository<T> repo,
) => (repo as PostgresqlDataRepository<Service, T>).dataRelation;

Future<void> _createSales(DataRepository<Sale> repo) async {
  for (final sale in [
    Sale(region: 'north', quantity: 2, price: 10.0),
    Sale(region: 'north', quantity: 4, price: 20.0),
    Sale(region: 'north', quantity: 4, price: 5.0),
    Sale(region: 'south', quantity: 5, price: 7.5),
  ]) {
    await repo.create(sale);
  }
}

void main() {
  declareTest(
    'Postgresql Distinct On Select Data',
    environment: _environment,
    [_postgresService(), PostgresqlDataRepositoryService(bean: $Sale.bean)],
    () async {
      final postgres = Find<Postgresql>().find();
      final repo = Find<DataRepository<Sale>>().find();
      final relation = _relationOf(repo);

      await _createSales(repo);

      await postgres.runTransaction((context) async {
        // most expensive sale per region
        final result = await relation.selectData(
          context,
          distinctOn: [$Sale.$region],
          sort: Sort.followedBy([$Sale.$region.asc(), $Sale.$price.desc()]),
        );
        expect(result.map((e) => (e.region, e.price)), [
          ('north', 20.0),
          ('south', 7.5),
        ]);

        // filter is applied before distinct on
        final filtered = await relation.selectData(
          context,
          distinctOn: [$Sale.$region],
          filter: $Sale.$price.lessThan(15.0),
          sort: Sort.followedBy([$Sale.$region.asc(), $Sale.$price.desc()]),
        );
        expect(filtered.map((e) => (e.region, e.price)), [
          ('north', 10.0),
          ('south', 7.5),
        ]);
      });
    },
  );

  declareTest(
    'Postgresql Distinct On Multiple Expressions',
    environment: _environment,
    [_postgresService(), PostgresqlDataRepositoryService(bean: $Sale.bean)],
    () async {
      final postgres = Find<Postgresql>().find();
      final repo = Find<DataRepository<Sale>>().find();
      final relation = _relationOf(repo);

      await _createSales(repo);

      await postgres.runTransaction((context) async {
        final result = await relation.select(
          context,
          [
            $Sale.$region,
            $Sale.$quantity,
            PostgresqlAliasExpression('p', $Sale.$price),
          ],
          distinctOn: [$Sale.$region, $Sale.$quantity],
          sort: Sort.followedBy([
            $Sale.$region.asc(),
            $Sale.$quantity.asc(),
            $Sale.$price.desc(),
          ]),
        );
        expect(result, [
          {'region': 'north', 'quantity': 2, 'p': 10.0},
          {'region': 'north', 'quantity': 4, 'p': 20.0},
          {'region': 'south', 'quantity': 5, 'p': 7.5},
        ]);
      });
    },
  );

  declareTest(
    'Postgresql Distinct On Join',
    environment: _environment,
    [
      _postgresService(),
      PostgresqlDataRepositoryService(bean: $Sale.bean),
      PostgresqlDataRepositoryService(bean: $City.bean),
    ],
    () async {
      final postgres = Find<Postgresql>().find();
      final saleRepo = Find<DataRepository<Sale>>().find();
      final cityRepo = Find<DataRepository<City>>().find();
      final sales = _relationOf(saleRepo);
      final cities = _relationOf(cityRepo);

      await _createSales(saleRepo);
      await cityRepo.create(City(id: 'n', name: 'north', zip: '1000'));
      await cityRepo.create(City(id: 's', name: 'south', zip: '2000'));

      await postgres.runTransaction((context) async {
        // distinct on a field of the right relation
        final result = await sales.selectJoin(
          context,
          cities,
          SqlJoinType.inner,
          $Sale.$region.equals($City.$name),
          distinctOn: [$City.$id],
          sort: Sort.followedBy([$City.$id.asc(), $Sale.$price.desc()]),
        );
        expect(result.map((e) => (e.$2?.id, e.$1?.price)), [
          ('n', 20.0),
          ('s', 7.5),
        ]);
      });
    },
  );
}
