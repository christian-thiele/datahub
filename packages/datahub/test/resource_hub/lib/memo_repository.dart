import 'dart:async';

import 'package:datahub/datahub.dart';
import 'package:rxdart/rxdart.dart';

import 'memo.dart';

class MemoRepository extends BaseService {
  final _memoController = PublishSubject<Memo>();

  var _current = Memo(1, 'initial', DateTime.now());
  Memo get current => _current;

  Stream<Memo> get memo => _memoController.stream;

  void setMemo(Memo value) => _memoController.add(_current = value);
}
