import 'package:datahub/datahub.dart';
import 'package:datahub/http.dart';
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

  MutableResourceRestClient(this.client, super.routePattern, super.bean);

  @override
  Future<void> set(T value) async {
    //TODO route params?
    final response = await client.putObject(
      routePattern.encode({}),
      value,
      bean: bean,
    );
    response.throwOnError();
  }
}

mixin _ImmutableResourceMethods<T extends TransferObjectBase> on Resource<T> {
  RestClient get client;

  late final _streamController =
      ClientResourceStreamController<T>(client, routePattern, bean);

  @override
  Future<T> get() async {
    if (_streamController.current != null) {
      return _streamController.current!;
    }

    //TODO route params?
    final response = await client.getObject(
      routePattern.encode({}),
      bean: bean,
    );
    response.throwOnError();
    return response.data;
  }

  @override
  Stream<T> get stream => _streamController.stream;
}
