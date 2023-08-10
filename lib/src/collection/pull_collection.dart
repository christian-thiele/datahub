import 'dart:async';

import 'package:datahub/datahub.dart';

typedef LengthDelegate = Future<int> Function(
  Map<String, dynamic> params,
  Map<String, List<String>> query,
);

typedef ItemsDelegate<Item> = Future<List<Item>> Function(
  int offset,
  int limit,
  Map<String, dynamic> params,
  Map<String, List<String>> query,
);

typedef ItemByIdDelegate<Item, Id> = Future<Item> Function(Id id);

/// Interface for pull collections.
///
/// Pull collections are collections where items are queried from the source.
///
/// For primary key / single object query support use [PrimaryKeyPullCollection].
abstract class PullCollection<Item> {
  PullCollection();

  /// Creates an adapter using delegate functions to implement the interface.
  factory PullCollection.delegate(
    LengthDelegate getLength,
    ItemsDelegate<Item> getItems,
  ) =>
      _PullCollectionAdapter(getLength, getItems);

  factory PullCollection.rest(
    RestClient client,
    String endpoint, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<Item>? bean,
  }) =>
      PullCollection<Item>.delegate(
        (p, q) async {
          final response = await client.getObject<Map<String, dynamic>>(
            endpoint,
            urlParams: {...urlParams, ...p},
            query: {
              ...query,
              ...q,
              '\$count': ['']
            },
            headers: headers,
          );
          response.throwOnError();
          return response.data['count'] as int;
        },
        (offset, limit, p, q) async {
          final response = await client.getList<Item>(
            endpoint,
            urlParams: {...urlParams, ...p},
            query: {...query, ...q},
            headers: headers,
            bean: bean,
          );
          response.throwOnError();
          return response.data;
        },
      );

  Future<int> getLength({
    Map<String, dynamic> params = const {},
    Map<String, List<String>> query = const {},
  });

  Future<List<Item>> getItems(
    int offset,
    int limit, {
    Map<String, dynamic> params = const {},
    Map<String, List<String>> query = const {},
  });
}

/// Interface for pull collections with primary key to query single objects.
///
/// Pull collections are collections where items are queried from the source.
///
/// See:
///   - [PullCollection]
abstract class PrimaryKeyPullCollection<Item, Id> extends PullCollection<Item> {
  PrimaryKeyPullCollection();

  /// Creates an adapter using delegate functions to implement the interface.
  factory PrimaryKeyPullCollection.delegate(
    LengthDelegate getLength,
    ItemsDelegate<Item> getItems,
    ItemByIdDelegate<Item, Id> getItemById,
  ) =>
      _PrimaryKeyPullCollectionAdapter(getLength, getItems, getItemById);

  factory PrimaryKeyPullCollection.rest(
    RestClient client,
    String endpoint, {
    Map<String, dynamic> urlParams = const {},
    Map<String, List<String>> query = const {},
    Map<String, List<String>> headers = const {},
    TransferBean<Item>? bean,
  }) {
    return PrimaryKeyPullCollection<Item, Id>.delegate(
      (p, q) async {
        final response = await client.getObject<Map<String, dynamic>>(
          endpoint,
          urlParams: {...urlParams, ...p},
          query: {
            ...query,
            ...q,
            '\$count': ['']
          },
          headers: headers,
        );
        response.throwOnError();
        return response.data['count'] as int;
      },
      (offset, limit, p, q) async {
        final response = await client.getList<Item>(
          endpoint,
          urlParams: {...urlParams, ...p},
          query: {...query, ...q},
          headers: headers,
          bean: bean,
        );
        response.throwOnError();
        return response.data;
      },
      (id) async {
        final response = await client.getObject<Item>(
          '$endpoint/${Uri.encodeComponent(id.toString())}',
          urlParams: {...urlParams},
          query: {...query},
          headers: headers,
          bean: bean,
        );
        response.throwOnError();
        return response.data;
      },
    );
  }

  Future<Item> getItemById(Id id);
}

extension PullCollectionMapperExtension<Item> on PullCollection<Item> {
  PullCollection<Target> map<Target>(FutureOr<Target> Function(Item) mapper) =>
      _PullCollectionMapper(this, mapper);
}

extension PrimaryKeyPullCollectionMapperExtension<Item, Id>
    on PrimaryKeyPullCollection<Item, Id> {
  PrimaryKeyPullCollection<Target, Id> map<Target>(
          FutureOr<Target> Function(Item) mapper) =>
      _PrimaryKeyPullCollectionMapper(this, mapper);
}

class _PullCollectionAdapter<Item> implements PullCollection<Item> {
  final LengthDelegate _getLength;
  final ItemsDelegate<Item> _getItems;

  _PullCollectionAdapter(this._getLength, this._getItems);

  @override
  Future<List<Item>> getItems(
    int offset,
    int limit, {
    Map<String, dynamic> params = const {},
    Map<String, List<String>> query = const {},
  }) =>
      _getItems(offset, limit, params, query);

  @override
  Future<int> getLength({
    Map<String, dynamic> params = const {},
    Map<String, List<String>> query = const {},
  }) =>
      _getLength(params, query);
}

class _PrimaryKeyPullCollectionAdapter<Item, Id>
    extends _PullCollectionAdapter<Item>
    implements PrimaryKeyPullCollection<Item, Id> {
  final ItemByIdDelegate<Item, Id> _getItemById;

  _PrimaryKeyPullCollectionAdapter(
    super._getLength,
    super._getItems,
    this._getItemById,
  );

  @override
  Future<Item> getItemById(Id id) => _getItemById(id);
}

class _PullCollectionMapper<Source, Target> implements PullCollection<Target> {
  final PullCollection<Source> source;
  final FutureOr<Target> Function(Source) mapper;

  _PullCollectionMapper(this.source, this.mapper);

  @override
  Future<List<Target>> getItems(int offset, int limit,
      {Map<String, dynamic> params = const {},
      Map<String, List<String>> query = const {}}) async {
    final sourceItems =
        await source.getItems(offset, limit, params: params, query: query);
    return await Stream.fromIterable(sourceItems).asyncMap(mapper).toList();
  }

  @override
  Future<int> getLength({
    Map<String, dynamic> params = const {},
    Map<String, List<String>> query = const {},
  }) =>
      source.getLength(params: params, query: query);
}

class _PrimaryKeyPullCollectionMapper<Source, Target, Id>
    extends _PullCollectionMapper<Source, Target>
    implements PrimaryKeyPullCollection<Target, Id> {
  _PrimaryKeyPullCollectionMapper(PrimaryKeyPullCollection<Source, Id> source,
      FutureOr<Target> Function(Source) mapper)
      : super(source, mapper);

  @override
  Future<Target> getItemById(Id id) async {
    final item =
        await (source as PrimaryKeyPullCollection<Source, Id>).getItemById(id);
    return await mapper(item);
  }
}
