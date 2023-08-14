import 'package:datahub/src/hub/transport/resource_transport_message.dart';
import 'package:rxdart/rxdart.dart';

import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/utils.dart';

import '../element_resource.dart';
import '../transport/resource_transport_stream.dart';
import '../transport/server_element_resource_stream_controller.dart';
import '../transport/server_transport_stream_controller.dart';
import 'resource_rest_endpoint.dart';

class ElementResourceRestEndpoint extends ResourceRestEndpoint {
  final _logService = resolve<LogService>();
  final ElementResourceProvider _resource;
  final _controllers = <ServerElementResourceStreamController>[];

  @override
  RoutePattern get routePattern => _resource.routePattern;

  ElementResourceRestEndpoint(this._resource) : super(_resource.routePattern);

  @override
  Future get(ApiRequest request) async {
    if (request.headers.containsKey(HttpHeaders.accept)) {
      if (request.headers[HttpHeaders.accept]!
          .contains(Mime.datahubResourceStream)) {
        final controller = ServerElementResourceStreamController(
          _resource
              .getStream(request)
              .shareValueSeeded(await _resource.get(request)),
          _removeController,
          uuid(),
          ResourceTransportResourceType.simple,
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

    return await _resource.get(request);
  }

  @override
  Future put(ApiRequest request) async {
    if (_resource is MutableElementResourceProvider) {
      final body = await request.getBody(bean: _resource.bean);
      await (_resource as MutableElementResourceProvider).set(request, body);
    } else {
      throw ApiRequestException.methodNotAllowed();
    }
  }

  void _removeController(ServerTransportStreamController controller) {
    _controllers.remove(controller);
    _logService.verbose('ResourceStream #${controller.id} closed.');
  }
}
