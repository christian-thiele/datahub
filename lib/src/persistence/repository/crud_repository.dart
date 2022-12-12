import 'dart:async';

import 'package:datahub/persistence.dart';

/// [Repository] implementation for basic CRUD operations.
///
/// Every operation implemented in [CRUDRepository] is executed inside its
/// own transaction. When creating methods that are composed of existing
/// operations you may want to execute them inside a single transaction.
/// To do so, wrap the calls that are supposed to be executed inside a single
/// transaction with another [transaction] call.
///
/// Example:
/// ```dart
/// Future<void> composedAction() async {
///   await transaction((context) {
///     final entry = await first(...);
///     await update(entry.copyWith(...));
///   });
/// }
/// ```
abstract class CRUDRepository<TDao extends PrimaryKeyDao<TDao, TPrimaryKey>,
    TPrimaryKey> extends Repository {
  final PrimaryKeyDataBean<TDao, TPrimaryKey> bean;

  CRUDRepository(super.config, this.bean);

  /// Returns the object with primary key [id] or null
  /// if [id] does not exist.
  Future<TDao?> findById(TPrimaryKey id) async {
    return await transaction((context) async {
      return await context.queryId(bean, id);
    });
  }

  /// Checks whether or not the id exists.
  Future<bool> exists(TPrimaryKey id) async {
    return await transaction((context) async {
      return await context.idExists(bean, id);
    });
  }

  /// Checks if there are any entries that match the filter.
  Future<bool> any({
    Filter filter = Filter.empty,
  }) async {
    return await transaction(
      (context) async {
        return await context.any(bean, filter: filter);
      },
    );
  }

  /// Returns the first entry of the query.
  Future<TDao?> first({
    Filter filter = Filter.empty,
    List<QuerySelect> distinct = const <QuerySelect>[],
    Sort sort = Sort.empty,
    int offset = 0,
  }) async {
    return await transaction(
      (context) async => await context.first(
        bean,
        filter: filter,
        distinct: distinct,
        sort: sort,
        offset: offset,
      ),
    );
  }

  /// Returns all entries that match the [filter].
  Future<List<TDao>> getAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
  }) async =>
      await transaction(
        (context) async {
          return await context.query(
            bean,
            filter: filter,
            sort: sort,
          );
        },
      );

  /// Returns the count of all entries matching the [filter].
  Future<int> count({Filter filter = Filter.empty}) async {
    return await transaction(
      (context) async => await context.count(
        bean,
        filter: filter,
      ),
    );
  }

  Future<TPrimaryKey> create(TDao object) async => await transaction(
        (context) async => await context.insert<TDao>(object),
      );

  Future<void> delete(TDao object) async => await transaction(
        (context) async => await context.delete(object),
      );

  Future<void> deleteById(TPrimaryKey id) async => await transaction(
      (context) async => await context.deleteId<TPrimaryKey>(bean, id));

  Future<void> deleteAll({
    Filter filter = Filter.empty,
  }) async =>
      await transaction(
          (context) async => await context.deleteWhere(bean, filter));

  Future<void> update(TDao object) async =>
      await transaction((context) async => await context.update(object));

  /// Query, modify and update an entry in a single transaction.
  ///
  /// The entry with primary key [id] will be selected and passed through
  /// [mutator]. The object that is returned by mutator is then updated
  /// on the database.
  ///
  /// It is not allowed to change the primary key inside of [mutator].
  /// An exception will be thrown otherwise.
  Future<TDao> mutate(
      TPrimaryKey id, FutureOr<TDao> Function(TDao) mutator) async {
    return await transaction(
      (context) async {
        final object = await context.queryId(bean, id);
        if (object != null) {
          final updated = await mutator(object);
          if (updated.getPrimaryKey() != id) {
            throw PersistenceException('Mutator modified primary key.');
          }
          await context.update(updated);
          return updated;
        } else {
          throw PersistenceException('Object with id "$id" not found.');
        }
      },
    );
  }
}
