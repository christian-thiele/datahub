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
  final host = TestHost([
    MemoRepository.new,
    MemoHubProviderImpl.new,
    () => ApiService('api', [
          ...ResourceRestEndpoint.allOf<MemoHub>(),
        ]),
  ]);

  group('Memo Hub', () {
    test('REST Client', host.apiTest((client) async {
      final initial = await client.getObject('/memo', bean: MemoTransferBean);
      expect(initial, isSuccess);
      expect(initial, hasBody());
      expect(initial.data.text, 'initial');

      final setResponse =
          await client.putObject('/memo', Memo(1, 'changed', DateTime.now()));
      expect(setResponse, isSuccess);
      expect(setResponse, isNot(hasBody()));

      final changed = await client.getObject('/memo', bean: MemoTransferBean);
      expect(changed, isSuccess);
      expect(changed, hasBody());
      expect(changed.data.text, 'changed');
    }));

    test('Hub Client', host.apiTest((client) async {
      final hub = MemoHubClient(client);
      final initial = await hub.memo.get();
      expect(initial.text, 'initial');

      final listener = StreamBatchListener(hub.memo.getStream());
      expect(
        await listener.next,
        predicate<Memo>((p0) => p0.text == 'initial'),
      );

      await hub.memo.set(Memo(1, 'changed', DateTime.now()));
      expect(
        await listener.next,
        predicate<Memo>((p0) => p0.text == 'changed'),
      );

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
              p0.window.length == p0.windowLength;
        }),
      );
      expect(event2.window.map((e) => e.id),
          orderedEquals(event1.window.map((e) => e.id)));
      final event3 = await todoListener.next;
      expect(
        event3,
        predicate<CollectionWindowState<Memo, int>>((p0) {
          return p0.windowOffset == 6 &&
              p0.windowLength == 9 &&
              p0.window.length == p0.windowLength &&
              p0.window.first.id != event2.window.first.id;
        }),
      );
    }));
  });
}
