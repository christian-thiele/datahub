import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
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
        Scope(name: 'internal', components: [TelemetryService(), KeyService()]),
        Scope(name: 'application', components: components),
      ],
    );
  }

  void _parseArguments() {
    final parser = ArgParser();
    parser.addMultiOption('config', abbr: 'c');
    parser.addMultiOption('file', abbr: 'f');

    final result = parser.parse(arguments);
    if (result.rest.isNotEmpty) {
      log.warn('Unrecognized command line arguments: ${result.rest.join(' ')}');
    }

    // ArgParser invokes option callbacks grouped by option, not in the order
    // the arguments were given, so the raw argument list is scanned instead to
    // preserve the documented left-to-right override semantics of -c and -f.
    for (final (option, value) in _optionsInOrder(parser)) {
      switch (option) {
        case 'config':
          configuration.addConfigDirective(value);
        case 'file':
          configuration.addConfigFile(File(value));
      }
    }
  }

  /// Yields the options of [parser] in the order they appear in [arguments],
  /// paired with their value.
  ///
  /// [arguments] is expected to have been parsed by [parser] beforehand, so
  /// unknown options have already been rejected.
  Iterable<(String, String)> _optionsInOrder(ArgParser parser) sync* {
    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];
      if (argument == '--') {
        return;
      }

      String? option;
      String? value;

      if (argument.startsWith('--')) {
        final name = argument.substring(2);
        final splitPoint = name.indexOf('=');
        if (splitPoint >= 0) {
          // --option=value
          option = parser
              .findByNameOrAlias(name.substring(0, splitPoint))
              ?.name;
          value = name.substring(splitPoint + 1);
        } else {
          // --option value
          option = parser.findByNameOrAlias(name)?.name;
        }
      } else if (argument.length > 1 && argument.startsWith('-')) {
        option = parser.findByAbbreviation(argument[1])?.name;
        if (option != null && argument.length > 2) {
          // -ovalue (ArgParser does not strip a leading '=' here)
          value = argument.substring(2);
        }
      }

      if (option == null) {
        continue;
      }

      // Options without an attached value consume the following argument.
      value ??= i + 1 < arguments.length ? arguments[++i] : null;
      if (value != null) {
        yield (option, value);
      }
    }
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
