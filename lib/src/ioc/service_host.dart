import 'dart:async';
import 'dart:math';

import 'package:boost/boost.dart';
import 'package:datahub/services.dart';

import 'service_resolver.dart';
import 'base_service.dart';

/// Base class for ServiceHosts.
///
/// See:  [ApplicationHost]
///       [TestHost]
abstract class ServiceHost extends ServiceResolver {
  late final List<BaseService Function()> _factories;
  final List<BaseService> _services = [];
  @override
  final servicesReady = Notifier();
  Completer? _shutdownCompleter;

  final bool failWithServices;

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

  Future<void> initialize() async {
    await runAsService(() async {
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

      servicesReady.notify();
    });
  }

  @override
  TService resolveService<TService extends BaseService?>() {
    final service = _services.whereIs<TService>().firstOrNull;
    if (service is TService) {
      return service;
    } else {
      throw Exception('Could not find service of type $TService.');
    }
  }

  T runAsService<T>(T Function() delegate) {
    return runZoned(
      delegate,
      zoneSpecification: ZoneSpecification(print: _print),
      zoneValues: {#serviceResolver: this},
    );
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
  }

  void _print(Zone self, ZoneDelegate parent, Zone zone, String line) {
    final log = resolveService<LogService?>();
    if (log != null) {
      log.verbose(line);
    } else {
      parent.print(zone, line);
    }
  }

  void _onError(
      String msg, dynamic exception, StackTrace trace, bool critical) {
    final logService = resolveService<LogService?>();
    if (logService != null) {
      final method = critical ? logService.c : logService.e;
      method(msg, error: exception, trace: trace, sender: 'DataHub');
    } else {
      print('$msg\n$e');
    }
  }
}
