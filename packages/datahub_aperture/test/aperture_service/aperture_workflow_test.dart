// The workflow administration of Aperture, through its HTTP API. The tests
// sign in at the demo OIDC provider like the frontend does.
import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:test/test.dart';

import '../_mock/order.dart';
import '../_mock/todo.dart';
import '../_utils/test_auth_provider.dart';
import '../scenarios/demo/demo_auth_service.dart';

const _apiPort = 18180;
const _authPort = 18181;
const _issuer = 'http://localhost:$_authPort/realms/test';

typedef OrderStep = WorkflowStep<Order, OrderState>;
typedef OrderHandler = Future<Order> Function(StepContext<Order> step);

Future<Order> _pack(StepContext<Order> step) async =>
    step.element.copyWith(state: OrderState.packed);

Future<Order> _deliver(StepContext<Order> step) async =>
    step.element.copyWith(state: OrderState.delivered);

/// placed -> packed -(ShipOrder)-> shipped -> delivered
List<OrderStep> _steps({
  OrderHandler deliver = _deliver,
  Duration deliverAfter = Duration.zero,
}) => [
  OnEnter(OrderState.placed, _pack),
  OnSignal(
    $ShipOrder.bean,
    accept: [OrderState.packed],
    target: (signal) => signal.orderId,
    handle: (step) async => step.element.copyWith(state: OrderState.shipped),
  ),
  OnEnter(
    OrderState.shipped,
    deliver,
    after: deliverAfter,
    retry: const RetryPolicy.none(),
  ),
];

List<Component> _components(List<OrderStep> steps, {bool history = true}) => [
  KeyService(),
  const DemoAuthService(issuer: Config.value(_issuer)),
  const TestAuthProvider(),
  MemoryRepositoryService(bean: $Order.bean),
  MemoryRepositoryService(bean: $Todo.bean),
  MemoryRepositoryService(bean: $WorkflowEvent.bean),
  if (history) MemoryRepositoryService(bean: $WorkflowHistoryEntry.bean),
  const MemoryLockService<String>(),
  WorkflowService<Order, OrderState>(
    steps: steps,
    pollInterval: const Config.value(Duration(milliseconds: 20)),
    heartbeatInterval: const Config.value(Duration(milliseconds: 50)),
  ),
  ApiService(
    port: const Config.value(_apiPort),
    routes: [
      ApertureApi(
        oidcIssuer: const Config.value(_issuer),
        resources: [
          ApertureResource(repository: Find<DataRepository<Order>>()),
          ApertureResource(repository: Find<DataRepository<Todo>>()),
        ],
      ),
    ],
  ),
];

DataRepository<Order> get _orders => Find<DataRepository<Order>>().find();

/// Signs in at the demo provider and returns a client of the Aperture API.
Future<RestClient> _signIn() async {
  const redirectUri = 'http://localhost/callback';
  final http = io.HttpClient();
  try {
    final authorize = await http.getUrl(
      Uri.parse('$_issuer/protocol/openid-connect/auth').replace(
        queryParameters: {
          'response_type': 'code',
          'client_id': 'aperture',
          'redirect_uri': redirectUri,
          'scope': 'openid',
        },
      ),
    );
    authorize.followRedirects = false;
    final redirect = await authorize.close();
    await redirect.drain<void>();
    final code = Uri.parse(
      redirect.headers.value(io.HttpHeaders.locationHeader)!,
    ).queryParameters['code']!;

    final token = await http.postUrl(
      Uri.parse('$_issuer/protocol/openid-connect/token'),
    );
    token.headers.contentType = io.ContentType(
      'application',
      'x-www-form-urlencoded',
    );
    token.write(
      Uri(
        queryParameters: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'client_id': 'aperture',
        },
      ).query,
    );
    final response = await token.close();
    final body = jsonDecode(await utf8.decodeStream(response));

    final client = await RestClient.connect(
      Uri.parse('http://localhost:$_apiPort/aperture'),
    );
    client.auth = TokenAuth(body['access_token'] as String);
    addTearDown(client.close);
    return client;
  } finally {
    http.close();
  }
}

Future<ResourceDescription> _describe(RestClient client, String resourceId) =>
    client
        .get(
          '/api/resources/{resourceId}',
          urlParams: {'resourceId': resourceId},
        )
        .thenGetData($ResourceDescription.bean);

Future<ResourceWorkflowEventsResponse> _events(
  RestClient client, {
  String? elementId,
  WorkflowEventStatus? status,
  int? offset,
  int? limit,
}) => client
    .get(
      '/api/resources/Order/workflow/events',
      query: {
        if (elementId != null) 'elementId': [elementId],
        if (status != null)
          'status': [const JsonDataCodec().encodeEnum(status)],
        if (offset != null) 'offset': ['$offset'],
        if (limit != null) 'limit': ['$limit'],
      },
    )
    .thenGetData($ResourceWorkflowEventsResponse.bean);

Future<List<WorkflowHistoryEntry>> _history(
  RestClient client,
  String elementId,
) async => await (await client.get(
  '/api/resources/Order/elements/{elementId}/workflow/history',
  urlParams: {'elementId': elementId},
)).getList($WorkflowHistoryEntry.bean);

Future<void> _ship(RestClient client, String elementId, Object signal) =>
    client.post(
      '/api/resources/Order/elements/{elementId}/workflow/signals/ShipOrder',
      signal,
      urlParams: {'elementId': elementId},
    );

Future<OrderState> _stateOf(String id) async =>
    (await _orders.readById(id))!.state;

Future<void> _eventually(
  FutureOr<bool> Function() condition, {
  String reason = 'condition',
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!await condition()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for $reason.');
    }
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

Future<void> _eventuallyInState(String id, OrderState state) => _eventually(
  () async => await _stateOf(id) == state,
  reason: 'order $id to be ${state.name}',
);

Matcher _throwsStatus(int statusCode) => throwsA(
  isA<ApiRequestException>().having((e) => e.statusCode, 'code', statusCode),
);

void main() {
  group('description', () {
    declareTest(
      'describes the workflow of a resource',
      _components(_steps()),
      () async {
        final client = await _signIn();

        final workflow = (await _describe(client, 'Order')).workflow!;
        expect(workflow.stateField, 'state');
        expect(workflow.writesHistory, isTrue);
        expect(
          workflow.states,
          unorderedEquals(['placed', 'packed', 'shipped']),
        );
        expect(workflow.steps.map((s) => (s.name, s.kind)), [
          ('placed', WorkflowStepKind.enter),
          ('ShipOrder', WorkflowStepKind.signal),
          ('shipped', WorkflowStepKind.enter),
        ]);
        expect(workflow.steps[0].state, 'placed');
        expect(workflow.steps[1].signal, 'ShipOrder');
        expect(workflow.steps[1].accept, ['packed']);

        final signal = workflow.signals.single;
        expect(signal.accept, ['packed']);
        expect(signal.action.id, 'ShipOrder');
        expect(signal.action.displayName, 'Ship order');
        expect(signal.action.parameterFields.map((f) => f.id), [
          'orderId',
          'carrier',
        ]);
        // The element id can be filled in from the element.
        expect(signal.action.parameterFields.first.lookup?.resourceId, 'Order');

        expect((await _describe(client, 'Todo')).workflow, isNull);
        await expectLater(
          client.get('/api/resources/Todo/workflow/events'),
          _throwsStatus(404),
        );
      },
    );

    declareTest(
      'tells that the history is not written',
      _components(_steps(), history: false),
      () async {
        final client = await _signIn();
        await _orders.create(const Order(id: 'o-1', customer: 'ACME'));

        final workflow = (await _describe(client, 'Order')).workflow!;
        expect(workflow.writesHistory, isFalse);
        await expectLater(_history(client, 'o-1'), _throwsStatus(404));
      },
    );
  });

  group('elements', () {
    declareTest(
      'starts the workflow of created elements',
      _components(_steps()),
      () async {
        final client = await _signIn();
        Future<void> create() => client.post(
          '/api/resources/Order/elements',
          const ResourceRevisionRequest(
            fieldData: {'id': 'o-1', 'customer': 'ACME', 'state': 'placed'},
          ),
        );

        await create();
        await _eventuallyInState('o-1', OrderState.packed);

        // Like creating an element twice.
        await expectLater(create(), _throwsStatus(409));
      },
    );

    declareTest(
      'resumes the workflow of elements whose state is edited',
      _components(_steps()),
      () async {
        final client = await _signIn();
        // Stored without the workflow, so it does not move by itself.
        await _orders.create(const Order(id: 'o-1', customer: 'ACME'));
        Future<void> edit(Map<String, dynamic> fieldData) => client.patch(
          '/api/resources/Order/elements/o-1',
          ResourceRevisionRequest(fieldData: fieldData),
        );

        await edit({'customer': 'ACME Corp.'});
        await Future.delayed(const Duration(milliseconds: 200));
        expect(await _stateOf('o-1'), OrderState.placed);
        expect(
          (await _history(client, 'o-1')).map((e) => e.kind),
          isNot(contains(WorkflowHistoryKind.resumed)),
        );

        await edit({'state': 'shipped'});
        await _eventuallyInState('o-1', OrderState.delivered);
        expect(
          (await _history(client, 'o-1')).map((e) => e.kind),
          contains(WorkflowHistoryKind.resumed),
        );
      },
    );

    declareTest(
      'resumes the workflow of an element',
      _components(_steps()),
      () async {
        final client = await _signIn();
        await _orders.create(const Order(id: 'o-1', customer: 'ACME'));

        await client.post(
          '/api/resources/Order/elements/o-1/workflow/resume',
          null,
        );
        await _eventuallyInState('o-1', OrderState.packed);
      },
    );
  });

  group('signals', () {
    declareTest(
      'sends a signal to an element',
      _components(_steps()),
      () async {
        final client = await _signIn();
        await _orders.create(
          const Order(id: 'o-1', customer: 'ACME', state: OrderState.packed),
        );
        await _orders.create(
          const Order(id: 'o-2', customer: 'ACME', state: OrderState.packed),
        );

        // Meant for another element than the one it is sent to.
        await expectLater(
          _ship(client, 'o-2', {'orderId': 'o-1', 'carrier': 'DHL'}),
          _throwsStatus(400),
        );

        await _ship(client, 'o-1', {'orderId': 'o-1', 'carrier': 'DHL'});
        await _eventuallyInState('o-1', OrderState.delivered);
        expect(await _stateOf('o-2'), OrderState.packed);
      },
    );

    declareTest(
      'names the invalid fields of a signal',
      _components(_steps()),
      () async {
        final client = await _signIn();
        await _orders.create(
          const Order(id: 'o-1', customer: 'ACME', state: OrderState.packed),
        );

        for (final invalid in [
          {'orderId': 'o-1'},
          {'orderId': 'o-1', 'carrier': 'X'},
        ]) {
          await expectLater(
            _ship(client, 'o-1', invalid),
            throwsA(
              isA<ApiRequestException>()
                  .having((e) => e.statusCode, 'code', 400)
                  .having(
                    (e) => e.data['fields'],
                    'fields',
                    contains('carrier'),
                  ),
            ),
          );
        }

        await expectLater(
          client.post(
            '/api/resources/Order/elements/o-1/workflow/signals/Unknown',
            {},
          ),
          _throwsStatus(404),
        );
        expect(await _stateOf('o-1'), OrderState.packed);
      },
    );
  });

  group('events', () {
    final deliveryStarted = Completer<void>();
    final deliveryMayFinish = Completer<void>();
    declareTest(
      'shows the events that are being handled',
      _components(
        _steps(
          deliver: (step) async {
            log.info('Handing the parcel over.');
            deliveryStarted.complete();
            await deliveryMayFinish.future;
            return _deliver(step);
          },
        ),
      ),
      () async {
        addTearDown(() {
          if (!deliveryMayFinish.isCompleted) {
            deliveryMayFinish.complete();
          }
        });
        final client = await _signIn();
        await Find<Workflow<Order>>().find().start(
          const Order(id: 'o-1', customer: 'ACME', state: OrderState.shipped),
        );
        await deliveryStarted.future;

        await _eventually(() async {
          final event = (await _events(client, elementId: 'o-1')).data.single;
          return event.event.messages.any((m) => m.contains('parcel'));
        }, reason: 'the log of the running step');
        final running = (await _events(client, elementId: 'o-1')).data.single;
        expect(running.running, isTrue);
        expect(running.event.step, 'shipped');

        // A running event can not be cancelled.
        await expectLater(
          client.delete(
            '/api/resources/Order/workflow/events/${running.event.id}',
          ),
          _throwsStatus(409),
        );

        deliveryMayFinish.complete();
        await _eventuallyInState('o-1', OrderState.delivered);
        expect((await _events(client, elementId: 'o-1')).data, isEmpty);
      },
    );

    declareTest(
      'lists the events by status, a page at a time',
      _components(_steps(deliverAfter: const Duration(hours: 1))),
      () async {
        final client = await _signIn();
        final workflow = Find<Workflow<Order>>().find();
        for (final id in ['o-1', 'o-2', 'o-3']) {
          await workflow.start(
            Order(id: id, customer: 'ACME', state: OrderState.shipped),
          );
        }

        final first = await _events(
          client,
          status: WorkflowEventStatus.pending,
          limit: 2,
        );
        expect(first.data.map((e) => e.event.elementId), ['o-1', 'o-2']);
        expect(first.data.map((e) => e.running), [false, false]);
        expect(first.hasNextPage, isTrue);

        final second = await _events(
          client,
          status: WorkflowEventStatus.pending,
          offset: 2,
          limit: 2,
        );
        expect(second.data.map((e) => e.event.elementId), ['o-3']);
        expect(second.hasNextPage, isFalse);

        expect(
          (await _events(client, status: WorkflowEventStatus.failed)).data,
          isEmpty,
        );
      },
    );

    declareTest(
      'cancels a pending event',
      _components(_steps(deliverAfter: const Duration(hours: 1))),
      () async {
        final client = await _signIn();
        await Find<Workflow<Order>>().find().start(
          const Order(id: 'o-1', customer: 'ACME', state: OrderState.shipped),
        );
        final pending = (await _events(client, elementId: 'o-1')).data.single;

        await client.delete(
          '/api/resources/Order/workflow/events/${pending.event.id}',
        );
        expect((await _events(client, elementId: 'o-1')).data, isEmpty);
        expect(
          (await _history(client, 'o-1')).first.kind,
          WorkflowHistoryKind.cancelled,
        );
      },
    );

    var deliveries = 0;
    declareTest(
      'retries a parked event',
      _components(
        _steps(
          deliver: (step) async {
            if (++deliveries == 1) {
              throw ApiRequestException(503, 'Carrier not reachable.');
            }
            return _deliver(step);
          },
        ),
      ),
      () async {
        final client = await _signIn();
        await Find<Workflow<Order>>().find().start(
          const Order(id: 'o-1', customer: 'ACME', state: OrderState.shipped),
        );
        await _eventually(
          () async => (await _events(
            client,
            status: WorkflowEventStatus.failed,
          )).data.isNotEmpty,
          reason: 'the event to be parked',
        );
        final parked = (await _events(
          client,
          status: WorkflowEventStatus.failed,
        )).data.single;
        expect(parked.event.lastError, contains('Carrier not reachable'));

        await client.post(
          '/api/resources/Order/workflow/events/${parked.event.id}/retry',
          null,
        );
        await _eventuallyInState('o-1', OrderState.delivered);

        // The event is gone once it is handled.
        await expectLater(
          client.post(
            '/api/resources/Order/workflow/events/${parked.event.id}/retry',
            null,
          ),
          _throwsStatus(404),
        );
      },
    );
  });

  group('history', () {
    declareTest(
      'reads the history newest first',
      _components(_steps()),
      () async {
        final client = await _signIn();
        await Find<Workflow<Order>>().find().start(
          const Order(id: 'o-1', customer: 'ACME'),
        );
        await _eventually(
          () async => (await _history(client, 'o-1')).length == 2,
          reason: 'the history to be written',
        );

        expect((await _history(client, 'o-1')).map((e) => e.kind), [
          WorkflowHistoryKind.stepSucceeded,
          WorkflowHistoryKind.started,
        ]);
      },
    );
  });
}
