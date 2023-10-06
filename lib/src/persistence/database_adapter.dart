import 'dart:async';
import 'dart:io';

import 'package:datahub/ioc.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/services.dart';
import 'package:datahub/utils.dart';

/// Abstract class for connecting to a database.
/// TODO more docs
abstract class DatabaseAdapter<TConnection extends DatabaseConnection>
    extends BaseService {
  static const _backoffDuration = Duration(seconds: 3);

  final _adapterId = randomHexId(5);
  final DataSchema schema;
  final _pool = Pool<TConnection>();

  late final targetPoolSize = config<int?>('poolSize') ?? 3;

  int get poolSize => _pool.total;

  int get poolAvailable => _pool.available;

  DatabaseAdapter(super.path, this.schema);

  Future<TConnection> openConnection();

  @override
  Future<void> initialize() async {
    for (var i = 0; i < targetPoolSize; i++) {
      _pool.give(await openConnection());
    }
  }

  Future<TConnection> _create() async {
    resolve<LogService?>()?.debug(
      'Creating new connection for pool.',
      sender: 'DataHub',
    );

    return _pool.giveReserved(await openConnection());
  }

  Future<TConnection> _take(Duration? timeout) async {
    if (_pool.total < targetPoolSize) {
      return await _create();
    } else {
      final connection = await _pool.take(timeout: timeout);
      if (connection.isOpen) {
        return connection;
      } else {
        _pool.remove(connection);
        return await _create();
      }
    }
  }

  /// Provides a connection from the connection pool.
  Future<TResult> useConnection<TResult>(
      Future<TResult> Function(TConnection) delegate,
      {Duration? timeout}) async {
    if (Zone.current['$_adapterId/connection'] is TConnection) {
      return await delegate(Zone.current['$_adapterId/connection']);
    }

    final connection = await _take(timeout);

    try {
      return await runZoned(() async {
        try {
          return await delegate(connection);
        } finally {
          if (connection.isOpen) {
            _pool.give(connection);
          } else {
            _pool.remove(connection);
          }
        }
      }, zoneValues: {
        '$_adapterId/connection': connection,
      });
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
