import 'package:datahub/datahub.dart';
import 'package:datahub_aperture/data.dart';
import 'package:datahub_aperture/services.dart';
import 'package:datahub_postgres/datahub_postgres.dart';

import '../_mock/person.dart';
import '../_mock/todo.dart';
import '../_utils/test_auth_provider.dart';

void main() => runApp([
  KeyService(),
  PostgresqlService(
    database: Config.value('datahub_postgres'),
    username: Config.value('postgres'),
    password: Config.value('postgres'),
    useSsl: Config.value(false),
  ),
  PostgresqlDataRepositoryService(bean: $Person.bean),
  PostgresqlRevisableRepositoryService(bean: $Todo.bean),

  TestAuthProvider(),
  ApiService(
    routes: [
      ApertureApi(
        configDelegate: ApertureConfigDataDelegate(
          dataResources: [
            ApertureDataResource($Person.bean, Find<DataRepository<Person>>()),
            ApertureDataResource($Todo.bean, Find<DataRepository<Todo>>()),
          ],
        ),
        oidcIssuer: Config.value('http://localhost:8081/realms/local-oidc'),
        oidcClientId: Config.value('aperture'),
      ),
    ],
  ),
]);
