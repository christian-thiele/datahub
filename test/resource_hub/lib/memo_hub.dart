import 'package:datahub/datahub.dart';

import 'memo.dart';

part 'memo_hub.g.dart';

@Hub()
abstract class MemoHub {
  @HubResource('/memo')
  MutableResource<Memo> get memo;
}
