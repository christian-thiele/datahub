import 'dart:async';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';

import '../transport/client_resource_stream_controller.dart';

class ResourceRestClient<T extends TransferObjectBase> extends ResourceClient<T>
    with _ImmutableResourceMethods {
  @override
  final RestClient client;

  @override
  final Map<String, String> routeParams;

  ResourceRestClient(
      this.client, super.routePattern, super.bean, this.routeParams);
}

class MutableResourceRestClient<T extends TransferObjectBase>
    extends MutableResourceClient<T> with _ImmutableResourceMethods {
  @override
  final RestClient client;

  @override
  final Map<String, String> routeParams;

  //TODO short-circuit flag (don't wait for stream to update when calling set, fake new value on streams)

  MutableResourceRestClient(
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

mixin _ImmutableResourceMethods<T extends TransferObjectBase>
    on ResourceClient<T> {
  RestClient get client;
  Map<String, String> get routeParams;

  //TODO force-get flag (don't reuse controllers current value on get)

  final _streamControllers = <ClientResourceStreamController<T>>[];

  ClientResourceStreamController<T> _getController(Map<String, String> params) {
    final existing = _streamControllers
        .firstOrNullWhere((p0) => p0.params.entriesEqual(params));

    if (existing != null) {
      return existing;
    }

    final controller =
        ClientResourceStreamController(client, routePattern, params, bean);
    _streamControllers.add(controller);

    return controller;
  }

  @override
  Future<T> get() async {
    final controller = _getController(routeParams);
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
  Stream<T> getStream() {
    return _getController(routeParams).stream;
  }
}
