import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/services.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

import '../_mock/person.dart';
import '../_utils/test_auth_provider.dart';

void main() => runApp([
  KeyService(),
  PostgresqlService(
    database: Config.value('datahub_postgres'),
    username: Config.value('postgres'),
    password: Config.value('postgres'),
    useSsl: Config.value(false),
  ),
  PostgresqlRevisableRepositoryService(bean: $Person.bean),

  TestAuthProvider(),
  ApiService(
    routes: [
      ApertureApi(
        configDelegate: ApertureConfigDataDelegate(
          baseUrl: 'http://localhost:8080/aperture',
          dataResources: [
            ApertureDataResource(Find<DataRepository<Person>>()),
          ],
        ),
        oidcIssuer: Config.value('http://localhost:8081/realms/local-oidc'),
        oidcClientId: Config.value('aperture'),
      ),
    ],
  ),
]);
