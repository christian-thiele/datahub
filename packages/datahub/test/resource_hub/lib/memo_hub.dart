import 'package:datahub/datahub.dart';

import 'memo.dart';

part 'memo_hub.g.dart';

@Hub()
abstract class MemoHub {
  @HubResource('/memo')
  MutableElementResource<Memo> get memo;

  @HubResource('/todos')
  CollectionResource<Memo, int> get todos;
}
