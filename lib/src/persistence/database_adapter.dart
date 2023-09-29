import 'dart:io';

import 'package:datahub/ioc.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/services.dart';
import 'package:datahub/utils.dart';

/// Abstract class for connecting to a database.
/// TODO more docs
abstract class DatabaseAdapter<TConnection extends DatabaseConnection>
    extends BaseService {
  final DataSchema schema;
  final _pool = Pool<TConnection>();

  late final poolSize = config<int?>('poolSize') ?? 3;
  int get poolAvailable => _pool.available;

  DatabaseAdapter(super.path, this.schema);

  Future<TConnection> openConnection();

  @override
  Future<void> initialize() async {
    for (var i = 0; i < poolSize; i++) {
      _pool.give(await openConnection());
    }
  }

  /// Provides a connection from the connection pool.
  Future<TResult> useConnection<TResult>(
      Future<TResult> Function(TConnection) delegate,
      {Duration? timeout}) async {
    final connection = await _pool.take(timeout: timeout);
    try {
      return await delegate(connection);
    } on SocketException catch (e, stack) {
      resolve<LogService?>()?.error(
        'SocketException while using database connection.',
        error: e,
        trace: stack,
        sender: 'DataHub',
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

      resolve<LogService?>()?.debug(
        'Creating new connection for pool.',
        sender: 'DataHub',
      );

      _pool.give(await openConnection());

      rethrow;
    } finally {
      _pool.give(connection);
    }
  }
}
