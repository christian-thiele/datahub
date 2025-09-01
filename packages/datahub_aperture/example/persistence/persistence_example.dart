import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture/src/data/aperture_config_data_delegate.dart';
import 'package:datahub_aperture/src/data/aperture_data_resource.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

import 'data/city.dart';
import 'data/parking_spot.dart';
import 'data/zone.dart';

void main() {
  ApplicationHost(
    [
      () => PostgresqlService(
            schema: PostgresqlSchema(
              name: 'aperture_test',
              relations: [
                PostgresqlDataTable(City.bean),
                PostgresqlDataTable(Zone.bean),
                PostgresqlDataTable(ParkingSpot.bean),
              ],
            ),
          ),
      () => PostgresqlDataRepository(bean: City.bean),
      () => PostgresqlDataRepository(bean: Zone.bean),
      () => PostgresqlDataRepository(bean: ParkingSpot.bean),
      () => ApertureService(
            apertureConfig: ApertureConfigDataDelegate(
              dataResources: [
                ApertureDataResource(
                  City.bean,
                  ApertureDataRepositoryResolver<City,
                      PostgresqlDataRepository<City>>(),
                ),
                ApertureDataResource(
                  Zone.bean,
                  ApertureDataRepositoryResolver<Zone,
                      PostgresqlDataRepository<Zone>>(),
                ),
                ApertureDataResource(
                  ParkingSpot.bean,
                  ApertureDataRepositoryResolver<ParkingSpot,
                      PostgresqlDataRepository<ParkingSpot>>(),
                ),
              ],
            ),
          ),
    ],
    config: {
      'postgresql': {
        'host': '192.168.178.85',
        'database': 'postgres',
        'username': 'postgres',
        'password': 'postgres',
        'useSsl': false,
        'logStatements': true,
      },
    },
  ).run();
}
