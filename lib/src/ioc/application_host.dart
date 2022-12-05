import 'dart:async';
import 'dart:io';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';

/// Hosts services and provides dependency injection.
///
/// This class also controls the execution of the application itself,
/// providing a framework for services to live in.
///
/// There can only be one ServiceHost in an application.
///
/// Use this code in your main function:
///
/// ```
/// await ApplicationHost([() => ServiceA(), () => ServiceB()]).run();
/// ```
class ApplicationHost extends ServiceHost {
  final _runTimeCompleter = Completer();

  final Function? onInitialized;

  /// Creates a [ServiceHost] instance.
  ///
  /// [failWithServices] service hosts terminates the app if a single service fails to initialize.
  /// [logBackend] initializes LogService with custom backend.
  /// [onInitialized] is called when service initialization is done.
  /// Feed the command line arguments from the applications main function into
  /// [args] for the [ConfigService] to detect configuration arguments.
  /// [config] provides default configuration values to the [ConfigService].
  ApplicationHost(
    super.factories, {
    super.failWithServices = true,
    super.logBackend,
    this.onInitialized,
    super.args = const <String>[],
    super.config = const <String, dynamic>{},
  });

  /// Runs the application.
  ///
  /// All services will be initialized in the order they are
  /// supplied.
  ///
  /// When [catchSignal] is true and termination is requested by CTRL+C or
  /// as soon as [cancel] is triggered, all services will be shut down and
  /// this future will complete.
  Future<void> run([CancellationToken? cancel]) async {
    final stopwatch = Stopwatch()..start();
    try {
      await initialize();
    } catch (e) {
      await shutdown();
      exit(0);
    }

    ProcessSignal.sigint.watch().listen((signal) {
      if (isInShutdown) {
        exit(0);
      } else {
        shutdown();
      }
    });

    cancel?.attach(shutdown);
    stopwatch.stop();

    final configService = resolveService<ConfigService?>();
    if (configService != null) {
      resolveService<LogService?>()?.info(
        'Initialized ${configService.serviceName} in ${stopwatch.elapsed}.',
        sender: 'DataHub',
      );
    } else {
      resolveService<LogService?>()?.info(
        'Initialisation done in ${stopwatch.elapsed}.',
        sender: 'DataHub',
      );
    }

    onInitialized?.call();

    await _runTimeCompleter.future;

    exit(0);
  }

  @override
  Future<void> shutdown() async {
    await super.shutdown();
    _runTimeCompleter.complete();
  }
}
