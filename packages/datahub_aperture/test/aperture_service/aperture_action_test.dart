import 'package:datahub/datahub.dart';
import 'package:datahub/test.dart';
import 'package:datahub_aperture/datahub_aperture.dart';
import 'package:test/test.dart';

import '../_mock/order.dart';
import '../_mock/todo.dart';
import '../_utils/aperture_sign_in.dart';
import '../scenarios/_utils/test_auth_service.dart';
import '../scenarios/demo/data/actions/resolve_ticket.dart';
import '../scenarios/demo/data/actions/send_payment_reminders.dart';

const _apiPort = 18170;
const _authPort = 18171;
const _issuer = 'http://localhost:$_authPort/realms/test';

ApertureAction<T> _action<T extends DataObject>(DataBean<T> bean) =>
    ApertureAction<T>(bean: bean, handler: (_, _) async => null);

void main() {
  group('decodeParameters', () {
    test('decodes the parameters', () {
      final parameters = _action($ResolveTicket.bean).decodeParameters({
        'resolution': 'Replaced the router.',
        'closeImmediately': true,
      });

      expect(parameters.resolution, 'Replaced the router.');
      expect(parameters.closeImmediately, isTrue);
    });

    test('falls back to the defaults of missing parameters', () {
      final parameters = _action($SendPaymentReminders.bean)
          .decodeParameters(<String, dynamic>{});

      expect(parameters.minDaysOverdue, 7);
    });

    test('fails for missing required parameters', () {
      expect(
        () =>
            _action($ResolveTicket.bean).decodeParameters(<String, dynamic>{}),
        throwsA(
          isA<CodecException>().having((e) => e.name, 'name', 'resolution'),
        ),
      );
    });

    test('fails for parameters that violate constraints', () {
      expect(
        () =>
            _action($ResolveTicket.bean)
                .decodeParameters({'resolution': 'Done.'}),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.violatedConstraints.keys.map((f) => f.name),
            'fields',
            ['resolution'],
          ),
        ),
      );
    });
  });

  group('results', () {
    List<Component> components(ApertureActionHandler<ResolveTicket> handler) =>
        [
          const KeyService(),
          const TestAuthService(issuer: Config.value(_issuer)),
          MemoryRepositoryService(bean: $Order.bean),
          MemoryRepositoryService(bean: $Todo.bean),
          ApiService(
            port: const Config.value(_apiPort),
            routes: [
              ApertureApi(
                oidcIssuer: const Config.value(_issuer),
                resources: [
                  ApertureResource(
                    repository: const Find<DataRepository<Todo>>(),
                    actions: [
                      ApertureAction<ResolveTicket>(
                        bean: $ResolveTicket.bean,
                        handler: handler,
                      ),
                    ],
                  ),
                ],
                actions: [
                  ApertureAction<ResolveTicket>(
                    bean: $ResolveTicket.bean,
                    handler: handler,
                  ),
                ],
              ),
            ],
          ),
        ];

    Future<ResourceActionResult> run({String? elementId}) async {
      final client = await signInToAperture(issuer: _issuer, apiPort: _apiPort);
      const parameters = {'resolution': 'Replaced the router.'};
      return client
          .post(
            elementId == null ? '/api/actions/ResolveTicket' : '/api/resources/Todo/elements/{elementId}/actions/ResolveTicket',
            parameters,
            urlParams: {'elementId': ?elementId},
          )
          .thenGetData($ResourceActionResult.bean);
    }

    declareTest(
      'responds with success without a result',
      components((_, _) async => null),
      () async {
        final result = await run(elementId: '1');
        expect(result.success, isTrue);
        expect(result.message, isNull);
        expect(result.data, isNull);
        expect(result.redirect, isNull);
      },
    );

    declareTest(
      'responds with the message and data of the result',
      components(
        (elementId, parameters) async => ActionResult(
          success: false,
          message: 'Could not notify the customer.',
          data: {
            'elementId': elementId,
            'resolution': parameters.resolution,
            'attempts': [1, 2],
          },
        ),
      ),
      () async {
        final result = await run(elementId: '1');
        expect(result.success, isFalse);
        expect(result.message, 'Could not notify the customer.');
        expect(result.data, {
          'elementId': '1',
          'resolution': 'Replaced the router.',
          'attempts': [1, 2],
        });
        expect(result.redirect, isNull);

        expect((await run()).data?['elementId'], isNull);
      },
    );

    declareTest(
      'responds with the element to redirect to',
      components(
        (_, _) async => RedirectActionResult(bean: $Todo.bean, id: '42'),
      ),
      () async {
        final redirect = (await run()).redirect!;
        expect(redirect.resourceId, 'Todo');
        expect(redirect.elementId, '42');
      },
    );

    declareTest(
      'responds with the file to download as attachment',
      components(
        (_, _) async => DownloadActionResult(
          data: Stream.fromIterable([
            [1, 2],
            [3],
          ]),
          fileName: 'Übersicht "Q3".csv',
          contentType: 'text/csv',
        ),
      ),
      () async {
        final client = await signInToAperture(
          issuer: _issuer,
          apiPort: _apiPort,
        );
        final response = await client.post('/api/actions/ResolveTicket', {
          'resolution': 'Replaced the router.',
        });

        expect(response.headers[HttpHeaders.contentType], ['text/csv']);
        expect(response.headers[HttpHeaders.contentDisposition], [
          'attachment; filename="_bersicht _Q3_.csv"; '
              "filename*=UTF-8''%C3%9Cbersicht%20%22Q3%22.csv",
        ]);
        expect(await response.getByteBody(), [1, 2, 3]);
      },
    );

    declareTest(
      'fails to redirect to something that is not a resource',
      components(
        (_, _) async => RedirectActionResult(bean: $Order.bean, id: '42'),
      ),
      () async {
        await expectLater(
          run(),
          throwsA(
            isA<ApiRequestException>().having((e) => e.statusCode, 'code', 500),
          ),
        );
      },
    );
  });
}
