import 'dart:async';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/src/hub/resource.dart';
import 'package:datahub/src/hub/transport/client_resource_stream_controller.dart';

class ResourceRestClient<T extends TransferObjectBase> extends Resource<T>
    with _ImmutableResourceMethods {
  @override
  final RestClient client;

  ResourceRestClient(this.client, super.routePattern, super.bean);
}

class MutableResourceRestClient<T extends TransferObjectBase>
    extends MutableResource<T> with _ImmutableResourceMethods {
  @override
  final RestClient client;

  //TODO short-circuit flag (don't wait for stream to update when calling set, fake new value on streams)

  MutableResourceRestClient(this.client, super.routePattern, super.bean);

  @override
  Future<void> set(T value, [Map<String, String> params = const {}]) async {
    final response = await client.putObject<void>(
      routePattern.encode(params),
      value,
    );
    response.throwOnError();
  }
}

mixin _ImmutableResourceMethods<T extends TransferObjectBase> on Resource<T> {
  RestClient get client;

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
  Future<T> get([Map<String, String> params = const {}]) async {
    final controller = _getController(params);
    if (controller.current != null) {
      return controller.current!;
    }

    final response = await client.getObject(
      routePattern.encode(params),
      bean: bean,
    );

    response.throwOnError();
    return response.data;
  }

  @override
  Stream<T> getStream([Map<String, String> params = const {}]) {
    return _getController(params).stream;
  }
}
