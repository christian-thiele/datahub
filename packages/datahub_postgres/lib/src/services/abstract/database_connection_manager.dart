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

  late final Pool<TConnection> _pool = Pool<TConnection>(
    read(targetPoolSize),
    _create,
    maxLifetime: read(maxConnectionLifetime),
    checkIsLive: (c) => c.isOpen,
    maxQueueLength: read(poolQueueLimit),
    onReturn: read(resetConnectionOnReturn) ? (c) => c.reset() : null,
    maintenanceInterval: read(poolMaintenanceInterval),
    autoRefill: true,
    onChange: () => onPoolChanged(
      target: _pool.targetSize,
      total: _pool.total,
      available: _pool.available,
    ),
    onRemoveItem: (c) => c.close(),
  );

  Config<int> get targetPoolSize;

  Config<Duration> get maxConnectionLifetime;

  Config<Duration> get poolTimeout;

  Config<int> get poolQueueLimit;

  Config<bool> get resetConnectionOnReturn;

  Config<Duration> get poolMaintenanceInterval;

  int get poolSize => _pool.total;

  int get poolAvailable => _pool.available;

  Future<TConnection> openConnection();

  /// Called when the size of the pool changed, e.g. to update metrics.
  void onPoolChanged({
    required int target,
    required int total,
    required int available,
  }) {}

  /// Wraps taking a connection from the pool, e.g. to measure the wait.
  Future<TConnection> onPoolTake(Future<TConnection> Function() take) => take();

  @override
  Future<void> initialize() async {
    await super.initialize();
    await _pool.fill();
  }

  @override
  Future<void> dispose() async {
    await _pool.dispose();
    await super.dispose();
  }

  Future<TConnection> _create() async {
    log.debug('Creating new connection for pool.');

    return await openConnection();
  }

  /// Runs [body] in a zone that is not bound to a connection of this pool,
  /// so that [useConnection] inside [body] takes a new connection even when
  /// called while another connection is in use by the calling zone.
  R runDetached<R>(R Function() body) {
    return runZoned(body, zoneValues: {'$_adapterId/connection': null});
  }

  /// Provides a connection from the connection pool.
  Future<TResult> useConnection<TResult>(
    Future<TResult> Function(TConnection) delegate, {
    Duration? timeout,
  }) async {
    if (Zone.current['$_adapterId/connection'] is TConnection) {
      return await delegate(Zone.current['$_adapterId/connection']);
    }

    final connection = await onPoolTake(
      () => _pool.take(timeout: timeout ?? read(poolTimeout)),
    );

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
}
