import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';
import 'service_host.dart';
import 'package:rxdart/rxdart.dart';

class ApplicationHost extends ServiceHost {
  final List<String> arguments;
  final List<Component> components;
  final Map<String, dynamic> initialConfig;
  final LogWriter logWriter;

  Completer? _runCompleter;
  StreamSubscription? _signalSubscription;

  ApplicationHost({
    required this.components,
    required this.arguments,
    required this.initialConfig,
    this.logWriter = const StdoutLogWriter(),
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
    logWriter.write(
      LogMessage(
        timestamp: DateTime.timestamp(),
        line: 'Initialized in ${stopwatch.elapsedMilliseconds}ms.',
        level: LogLevel.info,
      ),
    );

    return completer.future;
  }

  @override
  Future<void> initialize() async {
    if (state == ServiceHostState.uninitialized) {
      configuration.addConfigMap(initialConfig);
      _parseArguments();
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
        Scope(
          name: 'internal',
          components: [
            LogService(logWriter: logWriter),
            TelemetryService(),
          ],
        ),
        Scope(name: 'application', components: components),
      ],
    );
  }

  void _parseArguments() {
    final parser = ArgParser();
    parser.addMultiOption(
      'config',
      abbr: 'c',
      callback: (values) {
        for (final value in values) {
          configuration.addConfigDirective(value);
        }
      },
    );
    parser.addMultiOption(
      'file',
      abbr: 'f',
      callback: (values) {
        for (final value in values) {
          configuration.addConfigFile(File(value));
        }
      },
    );
    final result = parser.parse(arguments);
    if (result.rest.isNotEmpty) {
      log.warn('Unrecognized command line arguments: ${result.rest.join(' ')}');
    }
  }

  void _onSignal(ProcessSignal signal) {
    if (state == ServiceHostState.initialized &&
        signal == ProcessSignal.sigint) {
      logWriter.write(
        LogMessage(
          timestamp: DateTime.timestamp(),
          line: 'Received ${signal.name}: Shutting down application.',
          level: LogLevel.warning,
        ),
      );
      shutdown();
    } else {
      logWriter.write(
        LogMessage(
          timestamp: DateTime.timestamp(),
          line: 'Received ${signal.name}: Force killing application.',
          level: LogLevel.warning,
        ),
      );
      exit(0);
    }
  }
}
