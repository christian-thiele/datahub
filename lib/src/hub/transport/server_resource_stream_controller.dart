import 'dart:async';
import 'dart:convert';

import 'package:datahub/transfer_object.dart';

import 'resource_transport_message.dart';

class ServerResourceStreamController<T extends TransferObjectBase> {
  final String id;
  final Stream<T> resourceStream;
  StreamSubscription? _resourceSubscription;
  late final StreamSubscription _expirationSubscription;
  final void Function(ServerResourceStreamController) _onDone;

  late final _controller = StreamController<ResourceTransportMessage>(
    onListen: _onListen,
    onCancel: _onCancel,
  );

  ServerResourceStreamController(
    this.resourceStream,
    this._onDone,
    this.id,
    Stream<void> expiration,
  ) {
    _expirationSubscription = expiration.listen((_) => _onCancel());
  }

  Stream<ResourceTransportMessage> get stream => _controller.stream;

  void _onListen() {
    _resourceSubscription = resourceStream.listen(
      (event) {
        try {
          //TODO patch instead of set
          _controller.add(ResourceTransportMessage(
              ResourceTransportMessageType.set,
              utf8.encode(jsonEncode(event))));
        } catch (e) {
          //TODO error handling (encoding)
        }
      },
      onError: (e, stack) {
        //TODO error handling
        _onCancel();
      },
      onDone: () {
        _onCancel();
      },
    );
  }

  FutureOr<void> _onCancel() async {
    await _controller.close();
    await _resourceSubscription?.cancel();
    await _expirationSubscription.cancel();
    _onDone(this);
  }
}
