import 'package:datahub/ioc.dart';

import 'memo.dart';
import 'memo_hub.dart';
import 'memo_repository.dart';

class MemoHubProviderImpl extends MemoHubProvider {
  final _repo = resolve<MemoRepository>();

  @override
  Future<Memo> getMemo(Map<String, String> params) async {
    return _repo.current;
  }

  @override
  Stream<Memo> getMemoStream(Map<String, String> params) {
    return _repo.memo;
  }

  @override
  Future<void> setMemo(Memo value, Map<String, String> params) async {
    _repo.setMemo(value);
  }
}
