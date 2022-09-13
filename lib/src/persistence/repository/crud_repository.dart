import 'dart:async';

import 'package:datahub/persistence.dart';

/// [Repository] implementation for basic CRUD operations.
///
/// Every operation implemented in [CRUDRepository] is executed inside its
/// own transaction. When creating methods that are composed of existing
/// operations, make sure to provide the parent-context to every method to
/// allow them to use the existing transaction.
abstract class CRUDRepository<TDao extends PrimaryKeyDao<TDao, TPrimaryKey>,
    TPrimaryKey> extends Repository {
  final PrimaryKeyDataBean<TDao, TPrimaryKey> bean;

  CRUDRepository(super.config, this.bean);

  /// Returns the object with primary key [id] or null
  /// if [id] does not exist.
  ///
  /// Use [context] to provide a parent context when used to compose
  /// larger operations.
  Future<TDao?> findById(
    TPrimaryKey id, {
    DatabaseContext? context,
  }) async {
    return await transactionOr(
      (context) async {
        return await context.queryId(bean, id);
      },
      context,
    );
  }

  /// Checks whether or not the id exists.
  ///
  /// Use [context] to provide a parent context when used to compose
  /// larger operations.
  Future<bool> exists(
    TPrimaryKey id, {
    DatabaseContext? context,
  }) async {
    return await transactionOr(
      (context) async {
        return await context.idExists(bean, id);
      },
      context,
    );
  }

  /// Checks if there are any entries that match the filter.
  ///
  /// Use [context] to provide a parent context when used to compose
  /// larger operations.
  Future<bool> any({
    Filter filter = Filter.empty,
    DatabaseContext? context,
  }) async {
    return await transactionOr(
      (context) async {
        return await context.any(bean, filter: filter);
      },
      context,
    );
  }

  /// Returns the first entry of the query.
  ///
  /// Use [context] to provide a parent context when used to compose
  /// larger operations.
  Future<TDao?> first({
    Filter filter = Filter.empty,
    List<QuerySelect> distinct = const <QuerySelect>[],
    Sort sort = Sort.empty,
    int offset = 0,
    DatabaseContext? context,
  }) async {
    return await transactionOr(
      (context) async => await context.first(
        bean,
        filter: filter,
        distinct: distinct,
        sort: sort,
        offset: offset,
      ),
      context,
    );
  }

  /// Returns all entries that match the [filter].
  ///
  /// Use [context] to provide a parent context when used to compose
  /// larger operations.
  Future<List<TDao>> getAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    DatabaseContext? context,
  }) async =>
      await transactionOr(
        (context) async {
          return await context.query(
            bean,
            filter: filter,
            sort: sort,
          );
        },
        context,
      );

  /// Returns the count of all entries matching the [filter].
  ///
  /// Use [context] to provide a parent context when used to compose
  /// larger operations.
  Future<int> count({
    Filter filter = Filter.empty,
    DatabaseContext? context,
  }) async {
    return await transactionOr(
      (context) async => await context.count(
        bean,
        filter: filter,
      ),
      context,
    );
  }

  Future<TPrimaryKey> create(
    TDao object, {
    DatabaseContext? context,
  }) async =>
      await transactionOr(
        (context) async => await context.insert<TDao>(object),
        context,
      );

  Future<void> delete(
    TDao object, {
    DatabaseContext? context,
  }) async =>
      await transactionOr(
        (context) async => await context.delete(object),
        context,
      );

  Future<void> deleteById(
    TPrimaryKey id, {
    DatabaseContext? context,
  }) async =>
      await transactionOr(
        (context) async => await context.deleteId<TPrimaryKey>(bean, id),
        context,
      );

  Future<void> deleteAll({
    Filter filter = Filter.empty,
    DatabaseContext? context,
  }) async =>
      await transactionOr(
          (context) async => await context.deleteWhere(bean, filter), context);

  Future<void> update(
    TDao object, {
    DatabaseContext? context,
  }) async =>
      await transactionOr(
          (context) async => await context.update(object), context);

  /// Query, modify and update an entry in a single transaction.
  ///
  /// The entry with primary key [id] will be selected and passed through
  /// [mutator]. The object that is returned by mutator is then updated
  /// on the database.
  ///
  /// It is not allowed to change the primary key inside of [mutator].
  /// An exception will be thrown otherwise.
  Future<TDao> mutate(
    TPrimaryKey id,
    FutureOr<TDao> Function(TDao) mutator, {
    DatabaseContext? context,
  }) async {
    return await transactionOr(
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
      context,
    );
  }

  /// This method allows the above methods to be composed into larger
  /// transactions while using the parent transaction if provided.
  Future<T> transactionOr<T>(
    Future<T> Function(DatabaseContext context) delegate,
    DatabaseContext? context,
  ) async {
    if (context != null) {
      return await delegate(context);
    } else {
      return await transaction(delegate);
    }
  }
}
