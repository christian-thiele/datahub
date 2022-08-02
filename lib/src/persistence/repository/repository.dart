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
/// See also:
///   [CRUDRepository]
abstract class Repository extends BaseService {
  late final DatabaseAdapter _adapter;
  late final DatabaseConnection _connection;

  Repository(super.config);

  @override
  Future<void> initialize() async {
    _adapter = await initializeAdapter();
    _connection = await _adapter.openConnection();
  }

  Future<DatabaseAdapter> initializeAdapter();

  @override
  Future<void> shutdown() async {
    await _connection.close();
  }

  Future<T> transaction<T>(
      Future<T> Function(DatabaseContext context) delegate) async {
    return await _connection.runTransaction(delegate);
  }
}
