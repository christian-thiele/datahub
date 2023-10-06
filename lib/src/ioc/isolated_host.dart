import 'dart:async';
import 'dart:isolate';

import 'package:datahub/services.dart';

import 'isolated_host_configuration.dart';
import 'service_host.dart';
import 'service_resolver.dart';

class IsolatedHost extends ServiceHost {
  static int _isolateIndex = 1;
  final int isolateId = _isolateIndex++;
  final _log = resolve<LogService>();
  final String debugName;
  late final Isolate _isolate;
  late final ReceivePort _mainReceivePort;
  late final Completer<SendPort> _mainSendPort;
  late final Completer<SendPort> _shutdownSendPort;
  late final Completer _completed;

  final Future<void> Function(Stream receivePort) _initializeIsolate;
  final Future<void> Function() _shutdownIsolate;

  IsolatedHost(
    IsolatedHostConfiguration configuration,
    this._initializeIsolate,
    this._shutdownIsolate,
    this.debugName,
  ) : super(
          [],
          config: configuration.config,
          logBackend: configuration.logBackend,
        );

  @override
  Future<void> initialize() async {
    final _rcv = ReceivePort();
    final errorReceivePort = ReceivePort();
    final exitReceivePort = ReceivePort();

    _isolate = await Isolate.spawn<SendPort>(
      _entryPoint,
      _rcv.sendPort,
      onError: errorReceivePort.sendPort,
      onExit: exitReceivePort.sendPort,
      debugName: 'ISO#$isolateId $debugName',
    );

    _mainReceivePort = _rcv;
    _mainSendPort = Completer<SendPort>();
    _shutdownSendPort = Completer<SendPort>();
    _completed = Completer();

    _mainReceivePort.listen(
      _isolateReceive,
      onError: (e, stack) => _log.error('$debugName main port error.',
          error: e, trace: stack, sender: 'DataHub'),
    );

    exitReceivePort.listen(_isolateExit);

    //TODO error handling
    errorReceivePort.listen(
      _isolateError,
      onDone: () =>
          _log.debug('$debugName error port done.', sender: 'DataHub'),
      onError: (e, stack) => _log.error('$debugName error port error.',
          error: e, trace: stack, sender: 'DataHub'),
    );
  }

  Future<void> _entryPoint(SendPort mainSendPort) async {
    final mainReceivePort = ReceivePort();
    final shutdownReceivePort = ReceivePort();
    mainSendPort.send(mainReceivePort.sendPort);
    mainSendPort.send(shutdownReceivePort.sendPort);

    await super.initialize();

    shutdownReceivePort.listen((_) => runAsService(() async {
          await _shutdownIsolate();
          mainReceivePort.close();
          shutdownReceivePort.close();
          await super.shutdown();
        }));

    await runAsService(() async => await _initializeIsolate(mainReceivePort));
  }

  void _isolateReceive(message) {
    if (message is SendPort) {
      if (_mainSendPort.isCompleted) {
        _shutdownSendPort.complete(message);
      } else {
        _mainSendPort.complete(message);
      }
    } else {
      _log.debug('Received $message from isolate.');
    }
  }

  void _isolateError(dynamic message) {
    //TODO error handling
    _log.error('Error in IsolatedService: $message');
  }

  void _isolateExit(dynamic message) => _completed.complete();

  @override
  Future<void> shutdown() async {
    final port = await _shutdownSendPort.future;
    port.send(null);
    _mainReceivePort.close();
    await _completed.future;
  }

  Future<void> send(dynamic message) async =>
      (await _mainSendPort.future).send(message);
}
