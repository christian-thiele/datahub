import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_aperture/datahub_aperture.dart';

import '../_mock/person.dart';
import '../_utils/test_auth_provider.dart';

void main(List<String> args) => runApp([
  KeyService(),
  MemoryRepositoryService(bean: $Person.bean),
  TestAuthProvider(),
  ApiService(
    routes: [
      ApertureApi(
        configDelegate: ApertureConfigDataDelegate(
          baseUrl: 'http://localhost:8080/aperture',
          dataResources: [
            ApertureDataResource(
              $Person.bean,
              const Find<DataRepository<Person>>(),
            ),
          ],
        ),
        oidcIssuer: Config.value('http://localhost:8081/realms/local-oidc'),
        oidcClientId: Config.value('aperture'),
      ),
    ],
  ),

  ServiceDelegate(
    initialize: () async {
      final repo = Find<DataRepository<$Person>>().find();
      await repo.create(
        Person(
          id: 0,
          firstName: 'Alice',
          lastName: 'Mock',
          nicknames: ['Test'],
          address: 'Mockstreet 123, 012345 Mockingham',
          homeLocation: Point(wgs84, 13.406856, 52.519623),
        ),
      );
    },
  ),
], arguments: args);
