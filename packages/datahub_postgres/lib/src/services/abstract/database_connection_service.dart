import 'dart:async';
import 'dart:io';

import 'package:datahub/ioc.dart';
import 'package:datahub/services.dart';
import 'package:datahub/utils.dart';

import 'database_connection.dart';

/// Abstract class for connecting to a database.
/// TODO more docs
/// TODO docs config vars
abstract class DatabaseConnectionService<TConnection extends DatabaseConnection>
    extends BaseService {
  final _adapterId = randomHexId(5);

  late final _pool = Pool<TConnection>(
    targetPoolSize,
    _create,
    maxLifetime: Duration(seconds: maxConnectionLifetime),
    checkIsLive: (c) => c.isOpen,
    onChange: _updateMetrics,
    onRemoveItem: (c) => c.close(),
  );

  late final targetPoolSize = config<int?>('poolSize') ?? 3;
  late final maxConnectionLifetime =
      config<int?>('maxConnectionLifetime') ?? 3600;
  late final connectionPoolTimeout =
      config<int?>('connectionPoolTimeout') ?? 60;
  late final enableMetrics = config<bool?>('enableMetrics') ?? true;
  late final metricPrefix = config<String?>('metricPrefix') ?? 'database';

  int get poolSize => _pool.total;

  int get poolAvailable => _pool.available;

  late final GaugeMetric? _poolTargetMetric;
  late final GaugeMetric? _poolTotalMetric;
  late final GaugeMetric? _poolAvailableMetric;

  DatabaseConnectionService(super.path);

  Future<TConnection> openConnection();

  @override
  Future<void> initialize() async {
    final instrumentation = resolve<TelemetryService?>();
    if (enableMetrics && instrumentation != null) {
      _poolTargetMetric = instrumentation.gauge(
        '${metricPrefix}_pool_size_target',
      );
      _poolTotalMetric = instrumentation.gauge(
        '${metricPrefix}_pool_size_total',
      );
      _poolAvailableMetric = instrumentation.gauge(
        '${metricPrefix}_pool_size_available',
      );
    } else {
      _poolTargetMetric = null;
      _poolTotalMetric = null;
      _poolAvailableMetric = null;
    }

    await _pool.fill();
  }

  Future<TConnection> _create() async {
    resolve<LogService?>()?.debug(
      'Creating new connection for pool.',
      sender: 'DataHub',
    );

    return await openConnection();
  }

  /// Provides a connection from the connection pool.
  Future<TResult> useConnection<TResult>(
      Future<TResult> Function(TConnection) delegate,
      {Duration? timeout}) async {
    if (Zone.current['$_adapterId/connection'] is TConnection) {
      return await delegate(Zone.current['$_adapterId/connection']);
    }

    final connection = await _pool.take(
        timeout: timeout ?? Duration(seconds: connectionPoolTimeout));

    final completer = Completer<_Box<TResult>>();
    runZonedGuarded(
      () async {
        try {
          completer.complete(_Box<TResult>.value(await delegate(connection)));
        } on SocketException catch (e, stack) {
          resolve<LogService?>()?.warn(
            'Socket exception in database connection.',
            error: e,
            trace: stack,
          );

          try {
            await connection.close();
          } catch (e, stack) {
            resolve<LogService?>()?.warn(
              'Could not close connection.',
              error: e,
              trace: stack,
              sender: 'DataHub',
            );
          }

          rethrow;
        } finally {
          _pool.give(connection);
        }
      },
      (error, stack) {
        if (!completer.isCompleted) {
          completer.complete(_Box<TResult>.error(error, stack));
        } else {
          resolve<LogService?>()?.warn(
            'Unhandled error in DatabaseAdapter.',
            error: error,
            trace: stack,
          );
        }
      },
      zoneValues: {
        '$_adapterId/connection': connection,
      },
    );

    return (await completer.future).value;
  }

  void _updateMetrics() {
    _poolTargetMetric?.set(_pool.targetSize);
    _poolTotalMetric?.set(_pool.total);
    _poolAvailableMetric?.set(_pool.available);
  }
}

class _Box<T> {
  final dynamic error;
  final StackTrace? stack;
  final T? _value;

  _Box.error(this.error, this.stack) : _value = null;

  _Box.value(this._value)
      : error = null,
        stack = null;

  Future<T> get value {
    if (error != null) {
      return Future<T>.error(error, stack);
    } else {
      return Future<T>.value(_value);
    }
  }
}
