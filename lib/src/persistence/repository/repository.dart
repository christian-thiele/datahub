import 'package:datahub/ioc.dart';
import 'package:datahub/persistence.dart';

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

  Repository(super.path);

  @override
  Future<void> initialize() async {
    _adapter = await initializeAdapter();
  }

  Future<DatabaseAdapter> initializeAdapter() async =>
      resolve<DatabaseAdapter>();

  /// Executes [delegate] inside of a database transaction.
  ///
  /// If [transaction] is called from inside of another [transaction]'s delegate,
  /// the parent transaction / database context will be forwarded so
  /// methods using [transaction] can be combined into larger transactions.
  Future<T> transaction<T>(
      Future<T> Function(DatabaseContext context) delegate) async {
    return await _adapter.useConnection((connection) async {
      return await connection.runTransaction(delegate);
    });
  }
}
