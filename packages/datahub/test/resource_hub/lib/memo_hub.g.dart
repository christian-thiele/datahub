// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_hub.dart';

// **************************************************************************
// HubClientGenerator
// **************************************************************************

class MemoHubClient extends HubClient<MemoHub> implements MemoHub {
  final RestClient _client;
  final String basePath;
  MemoHubClient(this._client, {this.basePath = ''});
  @override
  late final MutableElementResourceClient<Memo> memo =
      MutableElementResourceRestClient(
    _client,
    RoutePattern('$basePath/memo'),
    MemoTransferBean,
  );
  @override
  late final CollectionResourceClient<Memo, int> todos =
      CollectionResourceRestClient(
    _client,
    RoutePattern('$basePath/todos'),
    MemoTransferBean,
  );
  @override
  Future<void> closeAll() async {
    await memo.closeAll();
    await todos.closeAll();
  }

  @override
  Future<void> reconnectAll() async {
    await memo.reconnectAll();
    await todos.reconnectAll();
  }
}

// **************************************************************************
// HubProviderGenerator
// **************************************************************************

abstract class MemoHubProvider extends HubProvider<MemoHub> implements MemoHub {
  MemoHubProvider();

  @override
  late final MutableElementResourceProvider<Memo> memo =
      MutableElementResourceAdapter(
    RoutePattern('/memo'),
    MemoTransferBean,
    getMemo,
    setMemo,
    getMemoStream,
  );

  @override
  late final CollectionResourceProvider<Memo, int> todos =
      CollectionResourceAdapter(
    RoutePattern('/todos'),
    MemoTransferBean,
    getTodosWindow,
  );

  @override
  List<ResourceProvider> get resources => [
        memo,
        todos,
      ];

  Future<Memo> getMemo(ApiRequest request);

  Future<void> setMemo(ApiRequest request, Memo value);

  Stream<Memo> getMemoStream(ApiRequest request);

  Stream<CollectionWindowEvent<Memo, int>> getTodosWindow(
      ApiRequest request, int offset, int length);
}
