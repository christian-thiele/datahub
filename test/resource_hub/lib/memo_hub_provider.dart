import 'package:datahub/datahub.dart';

import 'memo.dart';
import 'memo_hub.dart';
import 'memo_repository.dart';

class MemoHubProviderImpl extends MemoHubProvider {
  final _repo = resolve<MemoRepository>();

  @override
  Future<Memo> getMemo(ApiRequest request) async {
    resolve<LogService>().d(
        'METHOD: ${request.method} ACCEPT: ${request.headers[HttpHeaders.accept]}');
    return _repo.current;
  }

  @override
  Stream<Memo> getMemoStream(ApiRequest request) {
    resolve<LogService>().d(
        'METHOD: ${request.method} ACCEPT: ${request.headers[HttpHeaders.accept]}');
    return _repo.memo;
  }

  @override
  Future<void> setMemo(ApiRequest request, Memo value) async {
    resolve<LogService>().d(
        'METHOD: ${request.method} ACCEPT: ${request.headers[HttpHeaders.accept]}');
    _repo.setMemo(value);
  }

  @override
  Stream<CollectionWindowEvent<Memo, int>> getTodosWindow(
      ApiRequest request, int offset, int length) async* {
    final current = List.generate(
      length,
      (index) => OrderedData(
          10 + index * 2,
          Memo(offset + index, uuid(),
              DateTime.now().subtract(Duration(seconds: length - offset)))),
    );

    yield CollectionInitEvent(100, offset, current);
    await Future.delayed(Duration(seconds: 1));
    yield CollectionAlignEvent(101, offset + 1);
    await Future.delayed(Duration(seconds: 1));
    yield CollectionRemoveEvent(100, offset);
    await Future.delayed(Duration(seconds: 60));
  }
}
