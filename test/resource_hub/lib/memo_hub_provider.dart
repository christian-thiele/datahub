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
}
