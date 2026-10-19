import 'package:datahub/datahub.dart';
import 'package:datahub_postgres/data.dart';
import 'package:datahub_postgres/services.dart';

/// Standalone DataRepository providing direct access to the postgres data.
///
/// When access control or different behavior is required, use [PostgresqlDataRepository]
/// as mixin for a [ServiceInstance] to override methods.
class const PostgresqlDataRepositoryService<TData extends DataObject<TData>>({
  required final DataBean<TData> bean,
  final Find<Postgresql> postgresql = const Find(),
  final Config<String> schemaName = const Config(
    'schemaName',
    defaultValue: 'public',
  ),
  final Config<String?> relationName = const Config('relationName'),
}) implements Service {
  @override
  ServiceInstance<PostgresqlDataRepositoryService> createInstance() =>
      _PostgresqlDataRepositoryServiceInstance<TData>();
}

class _PostgresqlDataRepositoryServiceInstance<
  TData extends DataObject<TData>
>()
    extends ServiceInstance<PostgresqlDataRepositoryService<TData>>
    with
        PostgresqlDataRepository<
          PostgresqlDataRepositoryService<TData>,
          TData
        > {
  @override
  Find<Postgresql> get postgresql => service.postgresql;

  @override
  Config<String> get schemaName => service.schemaName;

  @override
  Config<String?> get relationName => service.relationName;

  @override
  DataBean<TData> get bean => service.bean;
}
