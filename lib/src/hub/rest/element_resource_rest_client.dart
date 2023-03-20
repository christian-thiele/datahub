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
  final Map<String, String> routeParams;

  ElementResourceRestClient(
      this.client, super.routePattern, super.bean, this.routeParams);
}

class MutableElementResourceRestClient<T extends TransferObjectBase>
    extends MutableElementResourceClient<T>
    with _ImmutableElementResourceMethods {
  @override
  final RestClient client;

  @override
  final Map<String, String> routeParams;

  //TODO short-circuit flag (don't wait for stream to update when calling set, fake new value on streams)

  MutableElementResourceRestClient(
      this.client, super.routePattern, super.bean, this.routeParams);

  @override
  Future<void> set(T value) async {
    final response = await client.putObject<void>(
      routePattern.encode(routeParams),
      value,
    );
    response.throwOnError();
  }
}

mixin _ImmutableElementResourceMethods<T extends TransferObjectBase>
    on ElementResourceClient<T> {
  RestClient get client;

  Map<String, String> get routeParams;

  //TODO force-get flag (don't reuse controllers current value on get)

  final _streamControllers = <ClientElementResourceStreamController<T>>[];

  ClientElementResourceStreamController<T> _getController(
    Map<String, String> params,
    Map<String, String> query,
  ) {
    //TODO this could create more problems than it solves
    final existing = _streamControllers.firstOrNullWhere((p0) =>
        p0.params.entriesEqual(params) && p0.params.entriesEqual(query));

    if (existing != null) {
      return existing;
    }

    final controller = ClientElementResourceStreamController(
        client, routePattern, params, query, bean);
    _streamControllers.add(controller);

    return controller;
  }

  @override
  Future<T> get({Map<String, String> query = const {}}) async {
    final controller = _getController(routeParams, query);
    if (controller.current != null) {
      return controller.current!;
    }

    final response = await client.getObject(
      routePattern.encode(routeParams),
      bean: bean,
    );

    response.throwOnError();
    return response.data;
  }

  @override
  Stream<T> getStream({Map<String, String> query = const {}}) {
    return _getController(routeParams, query).stream;
  }
}
