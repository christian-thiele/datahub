import 'dart:async';
import 'dart:math';

import 'package:boost/boost.dart';
import 'package:datahub/services.dart';

import 'base_service.dart';

/// Convenience method for injecting services.
///
/// See [ServiceHost.resolve].
TService resolve<TService>() => ServiceHost.resolve<TService>();

/// Base class for ServiceHosts.
///
/// See:
///   [ApplicationHost]
///   [TestHost]
abstract class ServiceHost {
  late final List<BaseService Function()> _factories;
  final List<BaseService> _services = [];
  Completer? _shutdownCompleter;

  final bool failWithServices;

  static ServiceHost? _applicationHost;

  ServiceHost(
    List<BaseService Function()> factories, {
    this.failWithServices = true,
    LogBackend? logBackend,
    List<String> args = const <String>[],
    Map<String, dynamic> config = const <String, dynamic>{},
  }) {
    _factories = <BaseService Function()>[
      () => LogService(logBackend ?? ConsoleLogBackend()),
      () => ConfigService(config, args),
      SchedulerService.new,
      KeyService.new,
      ...factories,
    ];
  }

  bool get isInShutdown => _shutdownCompleter != null;

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

  Future<void> initialize() async {
    _applicationHost = this;
    for (final factory in _factories) {
      BaseService? service;
      try {
        service = factory();
        await service.initialize();
        _services.add(service);
      } catch (e, stack) {
        if (service == null) {
          _onError('Error while creating service instance.', e, stack,
              failWithServices);
        } else {
          _onError(
              'Error while initializing service instance of ${service.runtimeType}.',
              e,
              stack,
              failWithServices);
        }

        if (failWithServices) {
          rethrow;
        }
      }
    }
  }

  Future<void> shutdown() async {
    if (_shutdownCompleter != null) {
      return _shutdownCompleter!.future;
    }

    _shutdownCompleter = Completer();

    for (final service in _services.reversed) {
      try {
        await service.shutdown();
      } catch (e, stack) {
        _onError('Could not shutdown service gracefully.', e, stack, false);
      }
    }

    _services.clear();
    _shutdownCompleter!.complete();
    _shutdownCompleter = null;
    _applicationHost = null;
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
