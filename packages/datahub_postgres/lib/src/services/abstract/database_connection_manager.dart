import 'dart:async';
import 'dart:io';

import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/telemetry.dart';
import 'package:datahub/utils.dart';

import 'database_connection.dart';

/// Abstract class for connecting to a database.
/// TODO more docs
mixin DatabaseConnectionManager<
  TService extends Service,
  TConnection extends DatabaseConnection
>
    on ServiceInstance<TService> {
  final _adapterId = randomHexId(5);

  late final _pool = Pool<TConnection>(
    read(targetPoolSize),
    _create,
    maxLifetime: read(maxConnectionLifetime),
    checkIsLive: (c) => c.isOpen,
    onChange: _updateMetrics,
    onRemoveItem: (c) => c.close(),
  );

  Config<int> get targetPoolSize;

  Config<Duration> get maxConnectionLifetime;

  Config<Duration> get poolTimeout;

  Config<bool> get enableMetrics;

  Config<String> get metricPrefix;

  int get poolSize => _pool.total;

  int get poolAvailable => _pool.available;

  late final GaugeMetric? _poolTargetMetric;
  late final GaugeMetric? _poolTotalMetric;
  late final GaugeMetric? _poolAvailableMetric;

  Future<TConnection> openConnection();

  @override
  Future<void> initialize() async {
    if (read(enableMetrics)) {
      final instrumentation = Context.ofZone().find(Find<Telemetry>());
      final prefix = read(metricPrefix);
      _poolTargetMetric = instrumentation.gauge('${prefix}_pool_size_target');
      _poolTotalMetric = instrumentation.gauge('${prefix}_pool_size_total');
      _poolAvailableMetric = instrumentation.gauge(
        '${prefix}_pool_size_available',
      );
    } else {
      _poolTargetMetric = null;
      _poolTotalMetric = null;
      _poolAvailableMetric = null;
    }

    await _pool.fill();
    super.initialize();
  }

  Future<TConnection> _create() async {
    log.debug('Creating new connection for pool.');

    return await openConnection();
  }

  /// Provides a connection from the connection pool.
  Future<TResult> useConnection<TResult>(
    Future<TResult> Function(TConnection) delegate, {
    Duration? timeout,
  }) async {
    if (Zone.current['$_adapterId/connection'] is TConnection) {
      return await delegate(Zone.current['$_adapterId/connection']);
    }

    final connection = await _pool.take(timeout: timeout ?? read(poolTimeout));

    return await runZoned(() async {
      try {
        return await delegate(connection);
      } on SocketException catch (e, stack) {
        log.warn(
          'Socket exception in database connection.',
          error: e,
          stack: stack,
        );

        try {
          await connection.close();
        } catch (e, stack) {
          log.warn('Could not close connection.', error: e, stack: stack);
        }

        rethrow;
      } finally {
        _pool.give(connection);
      }
    }, zoneValues: {'$_adapterId/connection': connection});
  }

  void _updateMetrics() {
    _poolTargetMetric?.set(_pool.targetSize);
    _poolTotalMetric?.set(_pool.total);
    _poolAvailableMetric?.set(_pool.available);
  }
}
