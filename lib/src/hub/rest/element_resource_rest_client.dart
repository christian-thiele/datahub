import 'dart:async';

import 'package:boost/boost.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/transfer_object.dart';
import 'package:datahub/utils.dart';

import '../element_resource.dart';
import '../transport/client_element_resource_stream_controller.dart';

class ElementResourceRestClient<T extends TransferObjectBase>
    extends ElementResourceClient<T> with _ImmutableElementResourceMethods {
  @override
  final RestClient client;

  @override
  final Map<String, String> defaultParams;

  @override
  final Map<String, List<String>> defaultQuery;

  ElementResourceRestClient(
    this.client,
    super.routePattern,
    super.bean, {
    this.defaultParams = const {},
    this.defaultQuery = const {},
  });
}

class MutableElementResourceRestClient<T extends TransferObjectBase>
    extends MutableElementResourceClient<T>
    with _ImmutableElementResourceMethods {
  @override
  final RestClient client;

  @override
  final Map<String, String> defaultParams;
  @override
  final Map<String, List<String>> defaultQuery;

  //TODO short-circuit flag (don't wait for stream to update when calling set, fake new value on streams)

  MutableElementResourceRestClient(
    this.client,
    super.routePattern,
    super.bean, {
    this.defaultParams = const {},
    this.defaultQuery = const {},
  });

  @override
  Future<void> set(
    T value, {
    Map<String, String> params = const {},
    Map<String, List<String>> query = const {},
  }) async {
    final response = await client.putObject<void>(
      routePattern.pattern,
      value,
      urlParams: {...defaultParams, ...params},
      query: {...defaultQuery, ...query},
    );
    response.throwOnError();
  }
}

mixin _ImmutableElementResourceMethods<T extends TransferObjectBase>
    on ElementResourceClient<T> {
  RestClient get client;

  Map<String, String> get defaultParams;

  Map<String, List<String>> get defaultQuery;

  //TODO force-get flag (don't reuse controllers current value on get)

  final _streamControllers = <ClientElementResourceStreamController<T>>[];

  ClientElementResourceStreamController<T> _getController(
    Map<String, String> params,
    Map<String, List<String>> query,
  ) {
    //TODO this could create more problems than it solves
    final existing = _streamControllers.firstOrNullWhere(
      (p0) =>
          deepMapEquality(p0.params, params) &&
          deepMapEquality(p0.query, query),
    );

    if (existing != null) {
      return existing;
    }

    final controller = ClientElementResourceStreamController(
      client,
      routePattern,
      params,
      query,
      (c) => _streamControllers.remove(c),
      bean,
    );
    _streamControllers.add(controller);

    return controller;
  }

  @override
  Future<T> get({
    Map<String, String> params = const {},
    Map<String, List<String>> query = const {},
  }) async {
    final controller = _getController(
      {...defaultParams, ...params},
      {...defaultQuery, ...query},
    );
    if (controller.current != null) {
      return controller.current!;
    }

    final response = await client.getObject(
      routePattern.pattern,
      urlParams: {...defaultParams, ...params},
      query: {...defaultQuery, ...query},
      bean: bean,
    );

    response.throwOnError();
    return response.data;
  }

  @override
  Stream<T> getStream({
    Map<String, String> params = const {},
    Map<String, List<String>> query = const {},
  }) {
    return _getController(
      {...defaultParams, ...params},
      {...defaultQuery, ...query},
    ).stream;
  }
}
