import 'dart:async';
import 'dart:io';
import 'package:datahub/utils.dart';
import 'service_host.dart';
import 'package:rxdart/rxdart.dart';

class ApplicationHost extends ServiceHost {
  final List<Component> components;

  Completer? _runCompleter;
  StreamSubscription? _signalSubscription;

  ApplicationHost({required this.components});

  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    if (_runCompleter != null) {
      throw ApiException('ApplicationHost already running.');
    }
    final completer = _runCompleter = Completer();

    _signalSubscription = Rx.merge([
      ProcessSignal.sigint.watch(),
      ProcessSignal.sigterm.watch(),
    ]).listen(_onSignal);

    await initialize();
    stopwatch.stop();
    print('Initialized in ${stopwatch.elapsedMilliseconds}ms.');
    return completer.future;
  }


  @override
  Future<void> shutdown() async {
    await super.shutdown();
    _signalSubscription?.cancel();
    _runCompleter?.complete();
  }

  @override
  Component buildRoot() => Scope(name: 'root', components: components);

  void _onSignal(ProcessSignal signal) {
    // TODO log
    if (state == ServiceHostState.initialized &&
        signal == ProcessSignal.sigint) {
      print('Received ${signal.name}: Shutting down application.');
      shutdown();
    } else {
      print('Received ${signal.name}: Force killing application.');
      exit(0);
    }
  }
}
