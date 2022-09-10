import 'package:datahub/datahub.dart';
import 'package:datahub/http.dart';
import 'package:datahub/src/hub/transport/resource_transport_stream.dart';
import 'package:rxdart/rxdart.dart';

import '../transport/server_resource_stream_controller.dart';

class ResourceRestEndpoint<T extends TransferObjectBase> extends ApiEndpoint {
  final _logService = resolve<LogService>();
  final _resourceSubject = BehaviorSubject<T>();
  final _controllers = <ServerResourceStreamController>[];

  ResourceRestEndpoint(super.routePattern, Stream<T> resourceStream) {
    resourceStream.pipe(_resourceSubject);
  }

  @override
  Future get(ApiRequest request) async {
    if (request.headers.containsKey(HttpHeaders.accept)) {
      if (request.headers[HttpHeaders.accept]!
          .contains(Mime.datahubResourceStream)) {
        final controller = ServerResourceStreamController(
          _resourceSubject.stream,
          _removeController,
          uuid(),
        );
        _controllers.add(controller);
        _logService.verbose(
            'ResourceStream #${controller.id} started with resource path "${request.route.url}".');
        return ByteStreamResponse(
            controller.stream.transform(ResourceTransportWriteTransformer()),
            0);
      }
    }

    return _resourceSubject.value;
  }

  void _removeController(ServerResourceStreamController controller) {
    _controllers.remove(controller);
    _logService.verbose('ResourceStream #${controller.id} closed.');
  }
}
