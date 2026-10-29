// The element operations a resource allows, through Aperture's HTTP API.
import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:test/test.dart';

import '../_mock/todo.dart';
import '../_utils/aperture_sign_in.dart';
import '../scenarios/_utils/test_auth_service.dart';

const _apiPort = 18190;
const _authPort = 18191;
const _issuer = 'http://localhost:$_authPort/realms/test';

List<Component> _components({
  bool allowCreate = true,
  bool allowUpdate = true,
  bool allowDelete = true,
  DataField<DataObject, dynamic>? defaultSortField,
  bool defaultSortAscending = true,
}) => [
  const KeyService(),
  const TestAuthService(issuer: Config.value(_issuer)),
  MemoryRepositoryService(bean: $Todo.bean),
  ApiService(
    port: const Config.value(_apiPort),
    routes: [
      ApertureApi(
        oidcIssuer: const Config.value(_issuer),
        resources: [
          ApertureResource(
            repository: const Find<DataRepository<Todo>>(),
            allowCreate: allowCreate,
            allowUpdate: allowUpdate,
            allowDelete: allowDelete,
            defaultSortField: defaultSortField,
            defaultSortAscending: defaultSortAscending,
          ),
        ],
      ),
    ],
  ),
];

DataRepository<Todo> get _todos => const Find<DataRepository<Todo>>().find();

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

  declareTest(
    'sorts elements by the default sort field',
    _components(defaultSortField: $Todo.$title, defaultSortAscending: false),
    () async {
      final client = await _signIn();
      for (final title in ['b', 'c', 'a']) {
        await _todos.create(Todo(title: title, description: '', dueDate: null));
      }

      final description = await _describe(client);
      expect(description.defaultSortField, 'title');
      expect(description.defaultSortAscending, isFalse);

      final defaultSorted = await client
          .get('/api/resources/Todo/elements')
          .thenGetData($ResourceElementsResponse.bean);
      expect(defaultSorted.data.map((e) => e.fieldData['title']), [
        'c',
        'b',
        'a',
      ]);

      final requestSorted = await client
          .get(
            '/api/resources/Todo/elements',
            query: {
              'sort': ['title'],
              'asc': ['true'],
            },
          )
          .thenGetData($ResourceElementsResponse.bean);
      expect(requestSorted.data.map((e) => e.fieldData['title']), [
        'a',
        'b',
        'c',
      ]);
    },
  );
}
