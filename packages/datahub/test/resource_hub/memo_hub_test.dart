import 'package:datahub/datahub.dart';
import 'package:datahub/src/test/matchers.dart';
import 'package:datahub/src/test/test_host.dart';
import 'package:datahub/src/test/utils/stream_batch_listener.dart';
import 'package:test/test.dart';

import 'lib/memo.dart';
import 'lib/memo_hub.dart';
import 'lib/memo_hub_provider.dart';
import 'lib/memo_repository.dart';

void main() {
  TestHost([
    MemoRepository.new,
    MemoHubProviderImpl.new,
    () => ApiService(
          'api',
          [
            ...ResourceRestEndpoint.allOf<MemoHub>(),
          ],
        ),
  ]).declare((host) {
    group('Memo Hub', () {
      host.apiTest('REST Client', (client) async {
        await Future.delayed(const Duration(seconds: 1));
        final initial = await client.get('/memo');
        expect(initial, isSuccess);
        expect(
          initial.getBody(),
          completion(
            isA<Map<String, dynamic>>()
                .having((p0) => p0['text'], 'text', 'initial'),
          ),
        );

        final setResponse =
            await client.put('/memo', Memo(1, 'changed', DateTime.now()));
        expect(setResponse, isSuccess);
        expect(setResponse.getByteBody(), completion(isEmpty));

        final changed = await client.get('/memo');
        expect(changed, isSuccess);
        expect(
          changed.getBody(bean: MemoTransferBean),
          completion(
            isA<Memo>().having((e) => e.text, 'text', equals('changed')),
          ),
        );
      });

      host.apiTest('Hub Client', (client) async {
        final hub = MemoHubClient(client);
        final initial = await hub.memo.get();
        expect(initial.text, 'initial');

        final future1 = expectLater(
          hub.memo.getStream(),
          emitsInOrder([
            isA<Memo>().having((p0) => p0.text, 'text', equals('initial')),
            isA<Memo>().having((p0) => p0.text, 'text', equals('changed')),
          ]),
        );
        await Future.delayed(const Duration(milliseconds: 100));
        await hub.memo.set(Memo(1, 'changed', DateTime.now()));
        await future1;

        final todoListener = StreamBatchListener(hub.todos.getWindow(5, 10));
        final event1 = await todoListener.next;
        expect(
          event1,
          predicate<CollectionWindowState<Memo, int>>((p0) {
            return p0.windowOffset == 5 &&
                p0.windowLength == 10 &&
                p0.window.length == p0.windowLength;
          }),
        );
        final event2 = await todoListener.next;
        expect(
          event2,
          predicate<CollectionWindowState<Memo, int>>((p0) {
            return p0.windowOffset == 6 &&
                p0.windowLength == 10 &&
                p0.items.length == p0.windowLength;
          }),
        );
        expect(event2.items.map((e) => e.id),
            orderedEquals(event1.items.map((e) => e.id)));
        final event3 = await todoListener.next;
        expect(
          event3,
          predicate<CollectionWindowState<Memo, int>>((p0) {
            return p0.windowOffset == 6 &&
                p0.windowLength == 9 &&
                p0.items.length == p0.windowLength &&
                p0.items.first.id != event2.items.first.id;
          }),
        );
      });

      host.apiTest('Delete Simple Element', (apiClient) async {
        final client = MemoHubClient(apiClient);
        final stream = client.memo.getStream(query: {
          'delete': ['true']
        });
        expectLater(
          stream,
          allOf(
            emitsInOrder(
              [
                isA<Memo>(),
                emitsError(isA<ApiRequestException>()
                    .having((e) => e.statusCode, 'statusCode', equals(404))),
              ],
            ),
          ),
        );
      });
    });
  });
}
