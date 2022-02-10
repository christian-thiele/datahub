import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:boost/boost.dart';
import 'package:cl_datahub/cl_datahub.dart';

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
  final bool failWithServices;

  final _runTimeCompleter = Completer();
  late final List<BaseService Function()> _factories;
  final List<BaseService> _services = [];
  bool _isInShutdown = false;

  // catches CTRL+C and shuts down gracefully
  final bool catchSignal;

  static ServiceHost? _applicationHost;

  ServiceHost._(
    List<BaseService Function()> factories, {
    this.catchSignal = true,
    this.failWithServices = true,
    LogBackend? logBackend,
  }) : assert(_applicationHost == null) {
    _factories = <BaseService Function()>[
      () => LogService(logBackend ?? ConsoleLogBackend()),
      () => SchedulerService(),
    ].followedBy(factories).toList(growable: false);
  }

  /// Creates a [ServiceHost] instance.
  ///
  /// [catchSignal] listens to CTRL+C in command line and shuts down services gracefully
  /// [failWithServices] service hosts terminates the app if a single service fails to initialize
  factory ServiceHost(
    List<BaseService Function()> factories, {
    bool catchSignal = true,
    bool failWithServices = true,
    LogBackend? logBackend,
  }) {
    return _applicationHost = ServiceHost._(
      factories,
      catchSignal: catchSignal,
      failWithServices: failWithServices,
      logBackend: logBackend,
    );
  }

  Future<void> run([CancellationToken? cancel]) async {
    for (final service in _factories.map((f) => f())) {
      try {
        await service.initialize();
        _services.add(service);
      } catch (e, stack) {
        _onError('Error while initializing service.', e, stack);
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

    await _runTimeCompleter.future;

    if (catchSignal) {
      exit(0);
    }
  }

  TService resolveService<TService extends BaseService>() {
    return tryResolveService<TService>() ??
        (throw Exception('Could not find service of type $TService.'));
  }

  TService? tryResolveService<TService extends BaseService>() {
    return _services.whereIs<TService>().firstOrNull;
  }

  static TService resolve<TService extends BaseService>() {
    return _applicationHost?.resolveService<TService>() ??
        (throw Exception('ServiceHost is not initialized.'));
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
        _onError('Could not shutdown service gracefully.', e, stack);
      }
    }

    _runTimeCompleter.complete();
  }

  void _onError(String msg, dynamic exception, StackTrace trace) {
    final logService = tryResolveService<LogService>();
    if (logService != null) {
      logService.e(msg, error: exception, trace: trace, sender: 'DataHub');
    } else {
      print('$msg\n$e');
    }
  }
}

/// Convenience method for injecting services.
TService resolve<TService extends BaseService>() =>
    ServiceHost.resolve<TService>();
