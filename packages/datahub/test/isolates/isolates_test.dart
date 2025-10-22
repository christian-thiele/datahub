import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:datahub/datahub.dart';
import 'package:test/scaffolding.dart';

class IsolateFuture<Request, Response> {
  final Request request;
  final responsePort = ReceivePort();
  late final isolateCompleter = IsolateCompleter<Request, Response>(
    request,
    responsePort.sendPort,
  );
  final _completer = Completer<Response>();

  Future<Response> get future => _completer.future;

  IsolateFuture(this.request) {
    responsePort.listen((response) {
      if (response is Response) {
        _completer.complete(response);
      } else {
        _completer.completeError(
          ApiError('Received invalid response in IsolateFuture.'),
        );
      }
      responsePort.close();
    });
  }
}

class IsolateCompleter<Request, Response> {
  final Request request;
  final SendPort responsePort;

  IsolateCompleter(this.request, this.responsePort);

  void complete(Response response) {
    responsePort.send(response);
  }
}

class IsolateShutdown {
  const IsolateShutdown();
}

class TaskIsolate {
  late final Isolate _isolate;
  final _mainPort = ReceivePort();
  final _setupCompleter = Completer<SendPort>();
  final _onExitPort = ReceivePort();
  final _onErrorPort = ReceivePort();
  final _onExitCompleter = Completer();
  bool _inShutdown = false;

  final void Function(IsolateCompleter) isolatedHandler;

  TaskIsolate._(this.isolatedHandler) {
    _mainPort.listen((sendPort) async {
      if (sendPort is SendPort) {
        _setupCompleter.complete(sendPort);
      } else {
        log.error('Invalid message: $sendPort');
      }
    });
    _onErrorPort.listen((message) {
      print('onError: $message');
      _onExitCompleter.complete();
    });
    _onExitPort.listen((message) {
      print('onExit: $message');
      _onExitCompleter.complete();
    });
  }

  Future<void> get onExitFuture => _onExitCompleter.future;

  static Future<TaskIsolate> spawn(
    void Function(IsolateCompleter) handler,
  ) async {
    final taskIsolate = TaskIsolate._(handler);
    taskIsolate._isolate = await Isolate.spawn(
      (sendPort) => _isolateMain(sendPort, handler),
      taskIsolate._mainPort.sendPort,
      onExit: taskIsolate._onExitPort.sendPort,
      onError: taskIsolate._onErrorPort.sendPort,
    );

    return taskIsolate;
  }

  static void _isolateMain(
    SendPort sendPort,
    void Function(IsolateCompleter) handler,
  ) {
    final mainPort = ReceivePort();
    mainPort.listen((message) async {
      if (message is IsolateCompleter) {
        handler(message);
      } else if (message is IsolateShutdown) {
        print('Shutdown received');
        mainPort.close();
      } else {
        log.error('Invalid message: $message');
      }
    });
    sendPort.send(mainPort.sendPort);
  }

  Future<TResponse> send<TRequest, TResponse>(
    IsolateFuture<TRequest, TResponse> future,
  ) async {
    if (_onExitCompleter.isCompleted) {
      throw ApiError('Isolate already finished.');
    }

    final sendPort = await _setupCompleter.future;
    sendPort.send(future.isolateCompleter);
    return await future.future;
  }

  Future<void> shutdown() async {
    if (_onExitCompleter.isCompleted) {
      throw ApiException('Isolate already finished.');
    }

    if (_inShutdown) {
      throw ApiException('Isolate already in shutdown.');
    }

    _inShutdown = true;

    final sendPort = await _setupCompleter.future;
    sendPort.send(const IsolateShutdown());
    await onExitFuture;
  }

  void kill() {
    _isolate.kill();
  }
}

void main() async {
  test('test', () async {
    final isolate = await TaskIsolate.spawn((IsolateCompleter completer) {
      if (completer is IsolateCompleter<String, int>) {
        print('Start long running thing');
        print('#1');
        sleep(const Duration(milliseconds: 500));
        print('#2');
        sleep(const Duration(milliseconds: 500));
        print('#3');
        sleep(const Duration(milliseconds: 500));
        completer.complete(completer.request.length);
      } else {
        log.error('Invalid message: $completer');
      }
    });

    final future = isolate.send(IsolateFuture<String, int>('abc123'));
    final future2 = isolate.send(
      IsolateFuture<String, int>('idahgfjosekmskmsaö'),
    );
    print(await future);
    print(await future2);

    await isolate.onExitFuture;
  });
}
