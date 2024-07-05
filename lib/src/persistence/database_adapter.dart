import 'dart:async';
import 'dart:io';

import 'package:datahub/ioc.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/services.dart';
import 'package:datahub/utils.dart';

/// Abstract class for connecting to a database.
/// TODO more docs
/// TODO docs config vars
abstract class DatabaseAdapter<TConnection extends DatabaseConnection>
    extends BaseService {
  final _adapterId = randomHexId(5);
  final DataSchema schema;

  late final _pool = Pool<TConnection>(
    targetPoolSize,
    _create,
    maxLifetime: Duration(seconds: maxConnectionLifetime),
    checkIsLive: (c) => c.isOpen,
  );

  late final targetPoolSize = config<int?>('poolSize') ?? 3;
  late final maxConnectionLifetime =
      config<int?>('maxConnectionLifetime') ?? 3600;
  late final connectionPoolTimeout =
      config<int?>('connectionPoolTimeout') ?? 60;

  int get poolSize => _pool.total;

  int get poolAvailable => _pool.available;

  DatabaseAdapter(super.path, this.schema);

  Future<TConnection> openConnection();

  @override
  Future<void> initialize() async {
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
    await runZonedGuarded(
      () async {
        try {
          completer.complete(_Box<TResult>.value(await delegate(connection)));
        } finally {
          if (connection.isOpen) {
            _pool.give(connection);
          } else {
            _pool.remove(connection);
          }
        }
      },
      (error, stack) {
        if (!completer.isCompleted) {
          completer.complete(_Box<TResult>.error(error, stack));
        } else {}
      },
      zoneValues: {
        '$_adapterId/connection': connection,
      },
    );
    try {
      return (await completer.future).value;
    } on SocketException catch (e, stack) {
      resolve<LogService?>()?.warn(
        'Socket exception in postgres connection.',
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

      _pool.remove(connection);

      rethrow;
    }
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
