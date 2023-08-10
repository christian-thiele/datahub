import 'dart:convert';

import 'package:datahub/api.dart';
import 'package:datahub/transfer_object.dart';

import '../transport/resource_transport_message.dart';
import 'client_transport_stream_controller.dart';
import 'resource_transport_exception.dart';

class ClientElementResourceStreamController<T extends TransferObjectBase>
    extends ClientTransportStreamController<T> {
  final TransferBean<T> bean;
  T? _current;

  T? get current => _current;

  ClientElementResourceStreamController(
    super.client,
    super.routePattern,
    super.params,
    super.query,
    this.bean,
  );

  @override
  void onData(ResourceTransportMessage message) {
    if (message.resourceType != ResourceTransportResourceType.simple) {
      throw ApiRequestException.badRequest(
          'Invalid resource type in transport message.');
    }

    switch (message.messageType) {
      case ResourceTransportMessageType.set:
        subject.add(
            _current = bean.toObject(jsonDecode(utf8.decode(message.payload))));
        break;
      case ResourceTransportMessageType.patch:
        if (_current != null) {
          final patchData = jsonDecode(utf8.decode(message.payload));
          //TODO better patch method (maybe integrate in transfer object generator?)
          final cacheData = _current!.toJson() as Map<String, dynamic>;
          cacheData.addAll(patchData);
          subject.add(_current = bean.toObject(cacheData));
        } else {
          // what to do? cannot patch...
        }
        break;
      case ResourceTransportMessageType.delete:
        subject.addError(
            ApiRequestException.notFound('The resource was removed.'));
        subject.close();
        break;
      default:
        throw ResourceTransportException(
            'Invalid message type in transport message.');
    }
  }
}
