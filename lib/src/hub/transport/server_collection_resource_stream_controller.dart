import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/collection.dart';
import 'package:datahub/src/hub/transport/ordered_data_codec.dart';
import 'package:datahub/transfer_object.dart';

import 'resource_transport_exception.dart';
import 'resource_transport_message.dart';
import 'server_transport_stream_controller.dart';

class ServerCollectionResourceStreamController<
        T extends TransferObjectBase<TId>, TId>
    extends ServerTransportStreamController<CollectionWindowEvent<T, TId>> {
  ServerCollectionResourceStreamController(
    super.resourceStream,
    super.onDone,
    super.id,
    super.expiration,
  );

  @override
  void onData(CollectionWindowEvent<T, TId> event) {
    if (event is CollectionInitEvent<T, TId>) {
      final payload = OrderedDataCodec.encode(event.data);
      final data = Uint8List(16 + payload.length);
      final byteData = ByteData.sublistView(data);
      byteData.setInt64(0, event.collectionLength);
      byteData.setInt64(8, event.windowOffset);
      data.setRange(16, 16 + payload.length, payload);
      emit(ResourceTransportMessage(
        ResourceTransportResourceType.collection,
        ResourceTransportMessageType.init,
        data,
      ));
    } else if (event is CollectionAlignEvent<T, TId>) {
      final data = Uint8List(16);
      final byteData = ByteData.sublistView(data);
      byteData.setInt64(0, event.collectionLength);
      byteData.setInt64(8, event.windowOffset);
      emit(ResourceTransportMessage(
        ResourceTransportResourceType.collection,
        ResourceTransportMessageType.align,
        data,
      ));
    } else if (event is CollectionAddEvent<T, TId>) {
      final payload = OrderedDataCodec.encode(event.data);
      final data = Uint8List(8 + payload.length);
      final byteData = ByteData.sublistView(data);
      byteData.setInt64(0, event.collectionLength);
      data.setRange(8, 8 + payload.length, payload);
      emit(ResourceTransportMessage(
        ResourceTransportResourceType.collection,
        ResourceTransportMessageType.add,
        data,
      ));
    } else if (event is CollectionRemoveEvent<T, TId>) {
      final payload = jsonEncode(event.id).apply(utf8.encode);
      final data = Uint8List(8 + payload.length);
      final byteData = ByteData.sublistView(data);
      byteData.setInt64(0, event.collectionLength);
      data.setRange(8, 8 + payload.length, payload);
      emit(ResourceTransportMessage(
        ResourceTransportResourceType.collection,
        ResourceTransportMessageType.remove,
        data,
      ));
    } else if (event is CollectionUpdateEvent<T, TId>) {
      final payload = OrderedDataCodec.encode([event.element]);
      emit(ResourceTransportMessage(
        ResourceTransportResourceType.collection,
        ResourceTransportMessageType.remove,
        payload,
      ));
    } else {
      throw ResourceTransportException('Invalid event type.');
    }
    //TODO delete resource?
  }
}
