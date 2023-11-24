import 'dart:convert';
import 'dart:typed_data';

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/collection.dart';
import 'package:datahub/src/hub/transport/ordered_data_codec.dart';
import 'package:datahub/transfer_object.dart';

import 'client_transport_stream_controller.dart';
import 'resource_transport_exception.dart';
import 'resource_transport_message.dart';

class ClientCollectionResourceStreamController<
        T extends TransferObjectBase<TId>, TId>
    extends ClientTransportStreamController<CollectionWindowEvent<T, TId>> {
  final TransferBean<T> bean;
  bool _initialized = false;

  ClientCollectionResourceStreamController(
    super.client,
    super.routePattern,
    super.params,
    super.query,
    super.onCanceled,
    this.bean,
  );

  @override
  void onData(ResourceTransportMessage message) {
    if (message.resourceType != ResourceTransportResourceType.collection) {
      throw ApiRequestException.badRequest(
          'Invalid resource type in transport message.');
    }

    if (!_initialized &&
        message.messageType != ResourceTransportMessageType.init &&
        message.messageType != ResourceTransportMessageType.delete) {
      throw ResourceTransportException(
          'Protocol error. No init message received.');
    }

    _initialized = true;

    final payload = message.payload.asUint8List();
    final bytes = ByteData.sublistView(payload);
    switch (message.messageType) {
      case ResourceTransportMessageType.init:
        final collectionLength = bytes.getInt64(0);
        final windowOffset = bytes.getInt64(8);
        final data = OrderedDataCodec.decode(
            payload.getRange(16, payload.length).toList(), bean);
        subject.add(CollectionInitEvent(collectionLength, windowOffset, data));
        break;
      case ResourceTransportMessageType.align:
        final collectionLength = bytes.getInt64(0);
        final windowOffset = bytes.getInt64(8);
        subject.add(CollectionAlignEvent(collectionLength, windowOffset));
        break;
      case ResourceTransportMessageType.add:
        final collectionLength = bytes.getInt64(0);
        final data = OrderedDataCodec.decode(
            payload.getRange(8, payload.length).toList(), bean);
        subject.add(CollectionAddEvent(collectionLength, data));
        break;
      case ResourceTransportMessageType.remove:
        final collectionLength = bytes.getInt64(0);
        final id =
            jsonDecode(utf8.decode(message.payload.skip(8).toList())) as TId;
        subject.add(CollectionRemoveEvent(collectionLength, id));
        break;
      case ResourceTransportMessageType.update:
        final data = OrderedDataCodec.decode(payload, bean);
        subject.add(CollectionUpdateEvent(data.single));
        break;
      case ResourceTransportMessageType.delete:
        subject.addError(
            ApiRequestException.notFound('The resource was removed.'));
        subject.close();
      case ResourceTransportMessageType.exception:
        final data = jsonDecode(utf8.decode(payload));
        if (data
            case {'statusCode': int statusCode, 'message': String message}) {
          subject.addError(ApiRequestException(statusCode, message));
        } else {
          subject
              .addError(ApiRequestException(500, 'Invalid exception message.'));
        }
        break;
      default:
        throw ResourceTransportException(
            'Invalid message type in transport message.');
    }
  }
}
