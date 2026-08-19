import 'dart:async';
import 'dart:io';

import 'package:datahub/src/config/config_arguments.dart';
import 'package:datahub/src/services/key_service/key_service.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';
import 'package:rxdart/rxdart.dart';

import 'service_host.dart';

class ApplicationHost extends ServiceHost {
  final List<String> arguments;
  final List<Component> components;
  final Map<String, dynamic> initialConfig;

  Completer? _runCompleter;
  StreamSubscription? _signalSubscription;

  ApplicationHost({
    required this.components,
    required this.arguments,
    required this.initialConfig,
    super.environmentVariables,
  });

  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    if (_runCompleter != null) {
      throw ApiError('ApplicationHost already running.');
    }
    final completer = _runCompleter = Completer();

    _signalSubscription = Rx.merge([
      ProcessSignal.sigint.watch(),
      ProcessSignal.sigterm.watch(),
    ]).listen(_onSignal);

    await initialize();

    stopwatch.stop();
    findComponent(Find<Telemetry?>(), null)?.publishLog(
      LogMessage(
        timestamp: DateTime.timestamp(),
        line: 'Initialized in ${stopwatch.elapsedMilliseconds}ms.',
        level: SeverityLevel.info,
      ),
    );

    return completer.future;
  }

  @override
  Future<void> initialize() async {
    if (state == ServiceHostState.uninitialized) {
      configuration.addConfigMap(initialConfig);
      configuration.applyArguments(arguments);
      await super.initialize();
    } else {
      throw ApiException('ServiceHost already initialized.');
    }
  }

  @override
  Future<void> shutdown() async {
    await super.shutdown();
    _signalSubscription?.cancel();
    _runCompleter?.complete();
  }

  @override
  Component buildRoot() {
    return Scope(
      name: 'root',
      components: [
        Scope(name: 'internal', components: [TelemetryService(), KeyService()]),
        Scope(name: 'application', components: components),
      ],
    );
  }

  void _onSignal(ProcessSignal signal) {
    if (state == ServiceHostState.initialized) {
      findComponent(Find<Telemetry?>(), null)?.publishLog(
        LogMessage(
          timestamp: DateTime.timestamp(),
          line: 'Received ${signal.name}: Shutting down application.',
          level: SeverityLevel.warning,
        ),
      );
      shutdown();
    } else {
      findComponent(Find<Telemetry?>(), null)?.publishLog(
        LogMessage(
          timestamp: DateTime.timestamp(),
          line: 'Received ${signal.name}: Force killing application.',
          level: SeverityLevel.warning,
        ),
      );
      stdout.flush().then((_) => exit(0)).catchError((_) => exit(0));
    }
  }
}
