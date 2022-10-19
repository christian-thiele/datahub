import 'package:datahub/datahub.dart';
import 'package:rxdart/rxdart.dart';

import '../transport/resource_transport_stream.dart';
import '../transport/server_resource_stream_controller.dart';

typedef ResourceSelector<THub> = Resource Function(THub hub);

class ResourceRestEndpoint extends ApiEndpoint {
  final _logService = resolve<LogService>();
  final Resource _resource;
  final _controllers = <ServerResourceStreamController>[];

  @override
  RoutePattern get routePattern => _resource.routePattern;

  ResourceRestEndpoint(this._resource) : super(_resource.routePattern);

  static ResourceRestEndpoint forHubResource<THub>(
          ResourceSelector<THub> selector) =>
      ResourceRestEndpoint(selector(resolve<HubProvider<THub>>() as THub));

  static List<ResourceRestEndpoint> allOf<THub>() =>
      resolve<HubProvider<THub>>()
          .resources
          .map((e) => ResourceRestEndpoint(e))
          .toList();

  @override
  Future get(ApiRequest request) async {
    if (request.headers.containsKey(HttpHeaders.accept)) {
      if (request.headers[HttpHeaders.accept]!
          .contains(Mime.datahubResourceStream)) {
        final controller = ServerResourceStreamController(
          _resource
              .getStream(request.route.routeParams)
              .shareValueSeeded(await _resource.get(request.route.routeParams)),
          _removeController,
          uuid(),
          request.session?.expiration ?? Rx.never(),
        );
        _controllers.add(controller);
        _logService.verbose(
            'ResourceStream #${controller.id} started with resource path "${request.route.url}".');
        return ByteStreamResponse(
          controller.stream.transform(ResourceTransportWriteTransformer()),
          null,
        );
      }
    }

    return await _resource.get(request.route.routeParams);
  }

  @override
  Future put(ApiRequest request) async {
    if (_resource is MutableResource) {
      final body = await request.getBody(bean: _resource.bean);
      await (_resource as MutableResource).set(body, request.route.routeParams);
    } else {
      throw ApiRequestException.methodNotAllowed();
    }
  }

  void _removeController(ServerResourceStreamController controller) {
    _controllers.remove(controller);
    _logService.verbose('ResourceStream #${controller.id} closed.');
  }
}
