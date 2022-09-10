import 'dart:async';
import 'dart:convert';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';
import 'package:datahub/http.dart';
import 'package:datahub/rest_client.dart';
import 'package:rxdart/rxdart.dart';

import '../transport/resource_transport_message.dart';
import '../transport/resource_transport_stream.dart';

class ClientResourceStreamController<T extends TransferObjectBase> {
  final RestClient
      _client; //TODO replace this with interface for other transport protocols
  final TransferBean<T> bean;
  final RoutePattern routePattern;

  late final _subject = BehaviorSubject<T>(
    onListen: _connect,
    onCancel: _disconnect,
  );

  bool get isConnected => _subject.hasListener;

  T? get current => _subject.valueOrNull;

  Stream<T> get stream => _subject.stream;

  ClientResourceStreamController(this._client, this.routePattern, this.bean);

  final _connectSemaphore = Semaphore();
  StreamSubscription? _currentSubscription;

  void _connect() async {
    try {
      await _connectSemaphore.runLocked(() async {
        if (_currentSubscription == null) {
          final streamResponse = await _client.getObject<Stream<List<int>>>(
            routePattern.encode({}),
            headers: {
              HttpHeaders.accept: [Mime.datahubResourceStream]
            },
          );
          streamResponse.throwOnError();
          _currentSubscription = streamResponse.data
              .transform(ResourceTransportReadTransformer())
              .listen(
                _onData,
                onDone: _connectionDone,
                onError: _connectionError,
              );
        }
      });
    } catch (e, stack) {
      if (_subject.hasListener) {
        _subject.addError(e, stack);
        await _subject.close();
      }
    }
  }

  void _onData(ResourceTransportMessage message) {
    try {
      switch (message.type) {
        case ResourceTransportMessageType.set:
          _subject.add(bean.toObject(jsonDecode(utf8.decode(message.payload))));
          break;
        case ResourceTransportMessageType.patch:
          if (_subject.hasValue) {
            final patchData = jsonDecode(utf8.decode(message.payload));
            //TODO better patch method (maybe integrate in transfer object generator?)
            final cacheData = _subject.value.toJson() as Map<String, dynamic>;
            cacheData.addAll(patchData);
            _subject.add(bean.toObject(cacheData));
          } else {
            // what to do? cannot patch...
          }
          break;
        case ResourceTransportMessageType.delete:
          if (_subject.hasValue) {
            _subject.addError(
                ApiRequestException.notFound('The resource was removed.'));
            _subject.close();
          }
          break;
      }
    } catch (e, stack) {
      _subject.addError(e, stack);
    }
  }

  FutureOr<void> _disconnect() async {
    await _connectSemaphore.runLocked(() async {
      if (_currentSubscription != null) {
        await _currentSubscription!.cancel();
      }
    });
  }

  void _connectionDone() {
    if (_subject.hasListener) {
      _connect();
    }
  }

  void _connectionError(dynamic e, StackTrace stack) {
    if (_subject.hasListener) {
      _subject.addError(e, stack);
      _subject.close();
    }
  }
}
