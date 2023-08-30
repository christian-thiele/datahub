import 'dart:async';

import 'package:datahub/datahub.dart';

import 'resource_transport_message.dart';

abstract class ServerTransportStreamController<T> {
  final LogService _logService = resolve<LogService>();
  final String id;
  final ResourceTransportResourceType resourceType;
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
    this.resourceType,
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
    if (e is ApiRequestException) {
      _logService
          .info('ApiRequestException in resource window stream: ${e.message}');

      try {
        emit(ResourceTransportMessage(
          resourceType,
          ResourceTransportMessageType.exception,
          await e.toResponse().getData().fold(<int>[], (p, e) => p..addAll(e)),
        ));
      } catch (e, stack) {
        _logService.error(
          'Could not send exception transport message.',
          error: e,
          trace: stack,
        );
      }
    } else {
      _logService.error(
        'Exception in resource window stream.',
        error: e,
        trace: stack,
      );
    }

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

    await _resourceSubscription?.cancel();
    await _expirationSubscription.cancel();
    _onDone(this);
  }
}
