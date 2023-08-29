import 'dart:async';

import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:datahub/rest_client.dart';
import 'package:datahub/utils.dart';

import '../transport/resource_transport_message.dart';
import '../transport/resource_transport_stream.dart';

abstract class ClientTransportStreamController<T> {
  final RestClient
      _client; //TODO replace this with interface for other transport protocols
  final RoutePattern routePattern;
  final Map<String, String> params;
  final Map<String, List<String>> query;
  final void Function(ClientTransportStreamController) onCanceled;

  late final subject = StreamController<T>.broadcast(
    onListen: _connect,
    onCancel: () {
      _disconnect();
      onCanceled(this);
    },
  );

  bool get isConnected => subject.hasListener;

  Stream<T> get stream => subject.stream;

  ClientTransportStreamController(
    this._client,
    this.routePattern,
    this.params,
    this.query,
    this.onCanceled,
  );

  final _connectSemaphore = Semaphore();
  StreamSubscription? _currentSubscription;

  void _connect() async {
    try {
      await _connectSemaphore.runLocked(() async {
        if (_currentSubscription == null) {
          final streamResponse = await _client.getObject<Stream<List<int>>>(
            routePattern.encode(params),
            query: query,
            headers: {
              HttpHeaders.accept: [Mime.datahubResourceStream]
            },
          );
          streamResponse.throwOnError();
          _currentSubscription = streamResponse.data
              .transform(ResourceTransportReadTransformer())
              .listen(
                _onDataInternal,
                onDone: _connectionDone,
                onError: _connectionError,
              );
        }
      });
    } catch (e, stack) {
      if (subject.hasListener) {
        subject.addError(e, stack);
        await subject.close();
      }
    }
  }

  void _onDataInternal(ResourceTransportMessage message) {
    try {
      onData(message);
    } catch (e, stack) {
      subject.addError(e, stack);
    }
  }

  void onData(ResourceTransportMessage message);

  FutureOr<void> _disconnect() async {
    await _connectSemaphore.runLocked(() async {
      if (_currentSubscription != null) {
        await _currentSubscription!.cancel();
        _currentSubscription = null;
      }
    });
  }

  void _connectionDone() async {
    try {
      await _disconnect();
      if (subject.hasListener) {
        _connect();
      } else {
        onCanceled(this);
      }
    } catch (e, stack) {
      subject.addError(e, stack);
      await subject.close();
      onCanceled(this);
    }
  }

  void _connectionError(dynamic e, StackTrace stack) {
    if (subject.hasListener) {
      subject.addError(e, stack);
      subject.close();
      onCanceled(this);
    }
  }
}
