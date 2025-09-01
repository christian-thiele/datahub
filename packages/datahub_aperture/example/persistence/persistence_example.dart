import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:datahub_aperture/src/aperture_service/aperture_config.dart';
import 'package:datahub_aperture/src/data/aperture_data_repository.dart';
import 'package:datahub_aperture/src/data/aperture_data_resource.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

import 'data/city.dart';
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
              ],
            ),
          ),
      () => PostgresqlDataRepository(bean: City.bean),
      () => PostgresqlDataRepository(bean: Zone.bean),
      () => ApertureService(
            apertureConfig: ApertureConfig(
              resources: [
                ApertureDataResource(
                  City.bean,
                  repository: ApertureDataRepositoryDelegate<City,
                      PostgresqlDataRepository<City>>(City.bean),
                ),
                ApertureDataResource(
                  Zone.bean,
                  repository: ApertureDataRepositoryDelegate<Zone,
                      PostgresqlDataRepository<Zone>>(Zone.bean),
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
      },
    },
  ).run();
}
