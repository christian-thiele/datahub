import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/src/hub/collection_resource.dart';
import 'package:datahub/src/hub/transport/resource_transport_exception.dart';
import 'package:datahub/transfer_object.dart';

import 'client_transport_stream_controller.dart';
import 'resource_transport_message.dart';

class ClientCollectionResourceStreamController<
    T extends TransferObjectBase<TId>,
    TId> extends ClientTransportStreamController<CollectionState<T, TId>> {
  final TransferBean<T> bean;

  ClientCollectionResourceStreamController(
    super.client,
    super.routePattern,
    super.params,
    super.query,
    this.bean,
  );

  @override
  void onData(ResourceTransportMessage message) {
    if (message.resourceType != ResourceTransportResourceType.collection) {
      throw ApiRequestException.badRequest(
          'Invalid resource type in transport message.');
    }

    if (!subject.hasValue &&
        message.messageType != ResourceTransportMessageType.init &&
        message.messageType != ResourceTransportMessageType.delete) {
      throw ResourceTransportException(
          'Protocol error. No init message received.');
    }

    final bytes = ByteData.sublistView(message.payload.asUint8List());
    switch (message.messageType) {
      case ResourceTransportMessageType.init:
        final collectionLength = bytes.getInt64(0);
        final windowOffset = bytes.getInt64(8);
        final data =
            jsonDecode(utf8.decode(message.payload.skip(16).toList())) as List;
        subject.add(CollectionState(collectionLength, windowOffset,
            data.map<T>((e) => bean.toObject(e)).toList()));
        break;
      case ResourceTransportMessageType.align:
        final collectionLength = bytes.getInt64(0);
        final windowOffset = bytes.getInt64(8);
        subject.add(subject.value.align(collectionLength, windowOffset));
        break;
      case ResourceTransportMessageType.add:
        final collectionLength = bytes.getInt64(0);
        final dataOffset = bytes.getInt64(8);
        final data = jsonDecode(utf8.decode(message.payload.skip(16).toList()));
        subject.add(subject.value.add(collectionLength, dataOffset,
            data.map<T>((e) => bean.toObject(e)).toList()));
        break;
      case ResourceTransportMessageType.remove:
        final collectionLength = bytes.getInt64(0);
        final id =
            jsonDecode(utf8.decode(message.payload.skip(8).toList())) as TId;
        subject.add(subject.value.remove(collectionLength, id));
        break;
      case ResourceTransportMessageType.update:
        final object =
            bean.toObject(jsonDecode(utf8.decode(message.payload.toList())));
        subject.add(subject.value.update(object));
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
