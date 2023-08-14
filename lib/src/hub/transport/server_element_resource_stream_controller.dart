import 'dart:convert';

import 'package:datahub/transfer_object.dart';

import 'resource_transport_message.dart';
import 'server_transport_stream_controller.dart';

class ServerElementResourceStreamController<T extends TransferObjectBase>
    extends ServerTransportStreamController<T> {
  ServerElementResourceStreamController(
    super.resourceStream,
    super.onDone,
    super.id,
    super.resourceType,
    super.expiration,
  );

  @override
  void onData(T data) {
    //TODO patch instead of set
    emit(ResourceTransportMessage(
      ResourceTransportResourceType.simple,
      ResourceTransportMessageType.set,
      utf8.encode(jsonEncode(data)),
    ));
  }
}
