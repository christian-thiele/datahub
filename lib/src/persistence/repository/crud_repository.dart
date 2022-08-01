import 'package:datahub/persistence.dart';
import 'package:datahub/src/persistence/repository/repository.dart';

/// [Repository] implementation for basic CRUD operations.
///
/// Every operation implemented in [CRUDRepository] is executed inside an
/// own transaction. Therefore it is considered bad-practice to add
/// methods to a repository that are composed from methods implemented
/// by this class.
abstract class CRUDRepository<TDao extends PKBaseDao<TDao, TPrimaryKey>,
    TPrimaryKey> extends Repository {
  final PKDaoDataBean<TDao, TPrimaryKey> bean;

  CRUDRepository(super.config, this.bean);

  Future<TDao?> findById(TPrimaryKey id) async {
    return await transaction((context) async {
      return await context.queryId(bean, id);
    });
  }

  Future<List<TDao>> getAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
  }) async =>
      await transaction((context) async {
        return await context.query(
          bean,
          filter: filter,
          sort: sort,
        );
      });

  Future<TPrimaryKey> create(TDao object) async =>
      await transaction((context) async => await context.insert<TDao>(object));

  Future<void> delete(TDao object) async =>
      await transaction((context) async => await context.delete(object));

  Future<void> deleteById(TPrimaryKey id) async => await transaction(
      (context) async => await context.deleteId<TPrimaryKey>(bean, id));

  Future<void> deleteAll({Filter filter = Filter.empty}) async =>
      await transaction(
          (context) async => await context.deleteWhere(bean, filter));

  Future<void> update(TDao object) async =>
      await transaction((context) async => await context.update(object));
}
