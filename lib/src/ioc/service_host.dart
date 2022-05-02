import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:boost/boost.dart';
import 'package:cl_datahub/config.dart';
import 'package:cl_datahub/services.dart';

import 'base_service.dart';

/// Hosts services and provides dependency injection.
///
/// There can only be one ServiceHost in an application.
/// Use this code in your main function:
///
/// ```
/// await ServiceHost([() => ServiceA(), () => ServiceB()]).run();
/// ```
///
/// This should not be confused with the IoC container provided
/// by the client library `cl_appbase`. While providing a similar
/// pattern for dependency injection, this class also controls the
/// execution of the application itself, providing a framework for
/// services to live in.
class ServiceHost {
  final _runTimeCompleter = Completer();
  late final List<BaseService Function()> _factories;
  final List<BaseService> _services = [];
  bool _isInShutdown = false;

  // catches CTRL+C and shuts down gracefully
  final bool catchSignal;
  final bool failWithServices;
  final Function? onInitialized;

  static ServiceHost? _applicationHost;

  ServiceHost._(
    List<BaseService Function()> factories,
    this.catchSignal,
    this.failWithServices,
    LogBackend? logBackend,
    this.onInitialized,
    List<String> args,
  ) : assert(_applicationHost == null) {
    final configFiles = args.map((e) => File(e)).toList();

    _factories = <BaseService Function()>[
      () => LogService(logBackend ?? ConsoleLogBackend()),
      () => ConfigService(configFiles),
      () => SchedulerService(),
    ].followedBy(factories).toList(growable: false);
  }

  /// Creates a [ServiceHost] instance.
  ///
  /// [catchSignal] listens to CTRL+C in command line and shuts down services gracefully
  /// [failWithServices] service hosts terminates the app if a single service fails to initialize
  /// [logBackend] initializes LogService with custom backend
  /// [onInitialized] is called when service initialization is done
  factory ServiceHost(
    List<BaseService Function()> factories, {
    bool catchSignal = true,
    bool failWithServices = true,
    LogBackend? logBackend,
    Function? onInitialized,
    List<String> args = const <String>[],
  }) {
    return _applicationHost = ServiceHost._(
      factories,
      catchSignal,
      failWithServices,
      logBackend,
      onInitialized,
      args,
    );
  }

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
    for (final factory in _factories) {
      try {
        final service = factory();
        await service.initialize();
        _services.add(service);
      } catch (e, stack) {
        _onError(
            'Error while initializing service.', e, stack, failWithServices);
        if (failWithServices) {
          rethrow;
        }
      }
    }

    if (catchSignal) {
      ProcessSignal.sigint.watch().listen((signal) {
        if (_isInShutdown) {
          exit(0);
        } else {
          _shutdown();
        }
      });
    }

    cancel?.attach(_shutdown);
    stopwatch.stop();

    tryResolveService<LogService>()?.info(
      'Initialization done in ${stopwatch.elapsed}.',
      sender: 'DataHub',
    );

    onInitialized?.call();

    await _runTimeCompleter.future;

    if (catchSignal) {
      exit(0);
    }
  }

  TService resolveService<TService>() {
    return tryResolveService<TService>() ??
        (throw Exception('Could not find service of type $TService.'));
  }

  TService? tryResolveService<TService>() {
    return _services.whereIs<TService>().firstOrNull;
  }

  static TService resolve<TService>() {
    return _applicationHost?.resolveService<TService>() ??
        (throw Exception('ServiceHost is not initialized.'));
  }

  static TService? tryResolve<TService>() {
    if (_applicationHost == null) {
      throw Exception('ServiceHost is not initialized.');
    }
    return _applicationHost!.tryResolveService<TService>();
  }

  Future<void> _shutdown() async {
    if (_isInShutdown) {
      return;
    }

    _isInShutdown = true;

    for (final service in _services) {
      try {
        await service.shutdown();
      } catch (e, stack) {
        _onError('Could not shutdown service gracefully.', e, stack, false);
      }
    }

    _runTimeCompleter.complete();
  }

  void _onError(
      String msg, dynamic exception, StackTrace trace, bool critical) {
    final logService = tryResolveService<LogService>();
    if (logService != null) {
      final method = critical ? logService.c : logService.e;
      method(msg, error: exception, trace: trace, sender: 'DataHub');
    } else {
      print('$msg\n$e');
    }
  }
}

/// Convenience method for injecting services.
///
/// See [ServiceHost.resolve].
TService resolve<TService>() => ServiceHost.resolve<TService>();
