import 'package:datahub/datahub.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/src/hub/resource.dart';

class ResourceRestClient<T extends TransferObjectBase> extends Resource<T> {
  final RestClient client;

  ResourceRestClient(this.client, super.routePattern, super.bean);

  @override
  Future<T> get() async {
    final response =
        await client.getObject(routePattern.encode({}), bean: bean);
    response.throwOnError();
    return response.data;
  }
}

class MutableResourceRestClient<T extends TransferObjectBase>
    extends MutableResource<T> {
  final RestClient client;

  MutableResourceRestClient(this.client, super.routePattern, super.bean);

  @override
  Future<T> get() async {
    final response =
        await client.getObject(routePattern.encode({}), bean: bean);
    response.throwOnError();
    return response.data;
  }

  @override
  Future<void> set(T value) async {
    final response =
        await client.putObject(routePattern.encode({}), value, bean: bean);
    response.throwOnError();
  }
}
