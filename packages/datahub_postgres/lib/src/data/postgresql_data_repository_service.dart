import 'package:datahub/data.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub_postgres/data.dart';

/// Standalone DataRepository providing direct access to the postgres data.
///
/// When access control or different behavior is required, use [PostgresqlDataRepository]
/// as mixin for a [ServiceInstance] to override methods.
class PostgresqlDataRepositoryService<TData extends DataObject<TData>>
    implements Service {
  final DataBean<TData> bean;

  PostgresqlDataRepositoryService({required this.bean});

  @override
  ServiceInstance<PostgresqlDataRepositoryService> createInstance() =>
      _PostgresqlDataRepositoryServiceInstance<TData>();
}

class _PostgresqlDataRepositoryServiceInstance<TData extends DataObject<TData>>
    extends ServiceInstance<PostgresqlDataRepositoryService<TData>>
    with
        PostgresqlDataRepository<
          PostgresqlDataRepositoryService<TData>,
          TData
        > {
  @override
  DataBean<TData> get bean => service.bean;
}
