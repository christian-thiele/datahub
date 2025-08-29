import 'package:datahub/collection.dart';
import 'package:datahub/src/hub/transport/resource_transport_exception.dart';
import 'package:datahub/src/hub/transport/resource_transport_message.dart';
import 'package:rxdart/rxdart.dart';

import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/utils.dart';

import '../collection_resource.dart';
import '../transport/resource_transport_stream.dart';
import '../transport/server_collection_resource_stream_controller.dart';
import '../transport/server_transport_stream_controller.dart';
import 'resource_rest_endpoint.dart';

class CollectionResourceRestEndpoint extends ResourceRestEndpoint {
  final _logService = resolve<LogService>();
  final CollectionResourceProvider _resource;
  final _controllers = <ServerCollectionResourceStreamController>[];

  @override
  RoutePattern get routePattern => _resource.routePattern;

  CollectionResourceRestEndpoint(this._resource)
      : super(_resource.routePattern);

  @override
  Future get(ApiRequest request) async {
    if (request.headers.containsKey(HttpHeaders.accept)) {
      if (request.headers[HttpHeaders.accept]!
          .contains(Mime.datahubResourceStream)) {
        final offset = request.getParam<int>('offset');
        final length = request.getParam<int>('length');

        final controller = ServerCollectionResourceStreamController(
          _resource.getWindow(request, offset, length),
          _removeController,
          uuid(),
          ResourceTransportResourceType.collection,
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
    final offset = request.getParam<int>('offset');
    final length = request.getParam<int>('length');

    final event = _resource.getWindow(request, offset, length).first;
    if (event case CollectionInitEvent initEvent) {
      return JsonResponse({
        'offset': initEvent.windowOffset,
        'total': initEvent.collectionLength,
        'data': initEvent.data.map((e) => e.data.toJson()).toList(),
      });
    } else {
      throw ResourceTransportException(
          'Protocol error. Window did not emit init message.');
    }
  }

  void _removeController(ServerTransportStreamController controller) {
    _controllers.remove(controller);
    _logService.verbose('ResourceStream #${controller.id} closed.');
  }
}
