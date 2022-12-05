import 'dart:io';

import 'package:datahub/ioc.dart';
import 'package:datahub/persistence.dart';
import 'package:datahub/services.dart';

/// Base class for repository services.
///
/// Repositories are services that provide an abstract interface
/// for (preferably CRUD) operations on a data source.
///
/// This service initializes a DatabaseAdapter by calling
/// [initializeAdapter] which must be implemented by the inheriting class.
/// It opens a single connection and keeps it alive during it's life cycle.
///
/// Configuration values:
///   `ignoreMigration`: ignore schema migration while initializing (optional)
///
/// See also:
///   [CRUDRepository]
abstract class Repository extends BaseService {
  late final DatabaseAdapter _adapter;
  late DatabaseConnection _connection;

  Repository(super.config);

  @override
  Future<void> initialize() async {
    _adapter = await initializeAdapter();
    await _adapter.initializeSchema(
      ignoreMigration: config<bool?>('ignoreMigration') ?? false,
    );
    _connection = await _adapter.openConnection();
  }

  Future<DatabaseAdapter> initializeAdapter();

  @override
  Future<void> shutdown() async {
    await _connection.close();
  }

  Future<T> transaction<T>(
      Future<T> Function(DatabaseContext context) delegate) async {
    if (!_connection.isOpen) {
      _connection = await _adapter.openConnection();
    }
    try {
      return await _connection.runTransaction(delegate);
    } on SocketException catch (e, stack) {
      resolve<LogService?>()?.warn(
        'Socket exception in transaction. Retrying...',
        error: e,
        trace: stack,
      );

      try {
        await _connection.close();
      } catch (e, stack) {
        resolve<LogService?>()?.warn(
          'Could not close connection.',
          error: e,
          trace: stack,
        );
      }

      _connection = await _adapter.openConnection();
      return await _connection.runTransaction(delegate);
    }
  }
}
