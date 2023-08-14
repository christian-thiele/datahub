import 'dart:async';

import 'resource_transport_message.dart';

abstract class ServerTransportStreamController<T> {
  final String id;
  final Stream<T> resourceStream;
  StreamSubscription? _resourceSubscription;
  late final StreamSubscription _expirationSubscription;
  final void Function(ServerTransportStreamController) _onDone;

  late final _controller = StreamController<ResourceTransportMessage>(
    onListen: _onListen,
    onCancel: _onCancel,
  );

  ServerTransportStreamController(
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
      _onDataInternal,
      onError: _onError,
      onDone: _onCancel,
    );
  }

  void _onDataInternal(T data) {
    try {
      onData(data);
    } catch (e, stack) {
      _onError(e, stack);
    }
  }

  void onData(T data);

  void emit(ResourceTransportMessage message) => _controller.add(message);

  FutureOr<void> _onError(dynamic e, StackTrace stack) async {
    //TODO error handling
    if (_controller.hasListener) {
      await _controller.close();
    }
    await _resourceSubscription?.cancel();
    await _expirationSubscription.cancel();
    _onDone(this);
  }

  FutureOr<void> _onCancel() async {
    if (_controller.hasListener) {
      await _controller.close();
    }

    await _expirationSubscription.cancel();
    _onDone(this);
  }
}
