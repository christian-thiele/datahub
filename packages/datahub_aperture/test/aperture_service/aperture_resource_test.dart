// The element operations a resource allows, through Aperture's HTTP API.
import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:test/test.dart';

import '../_mock/todo.dart';
import '../_utils/aperture_sign_in.dart';
import '../_utils/test_auth_provider.dart';
import '../scenarios/demo/demo_auth_service.dart';

const _apiPort = 18190;
const _authPort = 18191;
const _issuer = 'http://localhost:$_authPort/realms/test';

List<Component> _components({
  bool allowCreate = true,
  bool allowUpdate = true,
  bool allowDelete = true,
}) => [
  KeyService(),
  const DemoAuthService(issuer: Config.value(_issuer)),
  const TestAuthProvider(),
  MemoryRepositoryService(bean: $Todo.bean),
  ApiService(
    port: const Config.value(_apiPort),
    routes: [
      ApertureApi(
        oidcIssuer: const Config.value(_issuer),
        resources: [
          ApertureResource(
            repository: Find<DataRepository<Todo>>(),
            allowCreate: allowCreate,
            allowUpdate: allowUpdate,
            allowDelete: allowDelete,
          ),
        ],
      ),
    ],
  ),
];

DataRepository<Todo> get _todos => Find<DataRepository<Todo>>().find();

Future<RestClient> _signIn() =>
    signInToAperture(issuer: _issuer, apiPort: _apiPort);

Future<ResourceDescription> _describe(RestClient client) => client
    .get('/api/resources/{resourceId}', urlParams: {'resourceId': 'Todo'})
    .thenGetData($ResourceDescription.bean);

Future<void> _create(RestClient client) => client.post(
  '/api/resources/Todo/elements',
  const ResourceRevisionRequest(
    fieldData: {'title': 'Water plants', 'description': '', 'dueDate': null},
  ),
);

Future<void> _update(RestClient client, int id) => client.patch(
  '/api/resources/Todo/elements/{elementId}',
  const ResourceRevisionRequest(fieldData: {'title': 'Water all plants'}),
  urlParams: {'elementId': '$id'},
);

Future<void> _delete(RestClient client, int id) => client.delete(
  '/api/resources/Todo/elements/{elementId}',
  urlParams: {'elementId': '$id'},
);

Future<int> _seed() async => (await _todos.create(
  const Todo(title: 'Water plants', description: '', dueDate: null),
)).id;

Matcher _throwsStatus(int statusCode) => throwsA(
  isA<ApiRequestException>().having((e) => e.statusCode, 'code', statusCode),
);

void main() {
  declareTest('allows all operations by default', _components(), () async {
    final client = await _signIn();

    final description = await _describe(client);
    expect(description.allowCreate, isTrue);
    expect(description.allowUpdate, isTrue);
    expect(description.allowDelete, isTrue);

    await _create(client);
    final id = (await _todos.readAll()).single.id;
    await _update(client, id);
    expect((await _todos.readById(id))!.title, 'Water all plants');
    await _delete(client, id);
    expect(await _todos.readAll(), isEmpty);
  });

  declareTest(
    'blocks creating elements',
    _components(allowCreate: false),
    () async {
      final client = await _signIn();

      expect((await _describe(client)).allowCreate, isFalse);
      await expectLater(_create(client), _throwsStatus(405));
      expect(await _todos.readAll(), isEmpty);
    },
  );

  declareTest(
    'blocks updating elements',
    _components(allowUpdate: false),
    () async {
      final client = await _signIn();
      final id = await _seed();

      expect((await _describe(client)).allowUpdate, isFalse);
      await expectLater(_update(client, id), _throwsStatus(405));
      expect((await _todos.readById(id))!.title, 'Water plants');
    },
  );

  declareTest(
    'blocks deleting elements',
    _components(allowDelete: false),
    () async {
      final client = await _signIn();
      final id = await _seed();

      expect((await _describe(client)).allowDelete, isFalse);
      await expectLater(_delete(client, id), _throwsStatus(405));
      expect(await _todos.readById(id), isNotNull);
    },
  );
}
