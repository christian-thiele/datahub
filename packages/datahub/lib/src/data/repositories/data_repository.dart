import '../data_bean.dart';
import '../data_field.dart';
import '../data_object.dart';
import '../filter.dart';
import '../sort.dart';

/// An interface for [Component]s providing CRUD functionality for a
/// [DataObject].
abstract class DataRepository<T extends DataObject> {
  DataBean<T> get bean;

  /// Creates a new element.
  ///
  /// Returns the element like it is persisted. The return value may differ
  /// from [element] for example when fields are auto-generated in a database.
  Future<T> create(T element);

  /// Find and read an element by its [DataBean.idField] value.
  ///
  /// Returns the element or null if no element with the given id exists.
  ///
  /// Must throw a [MissingIdFieldError] when the [DataObject] does not provide
  /// an ID-field.
  Future<T?> readById(dynamic id);

  /// Read all elements respecting [filter], [sort], [offset] and [limit] values.
  Future<List<T>> readAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
  });

  /// Returns the count of all elements that match [filter].
  Future<int> count({Filter filter = Filter.empty});

  /// Find and update an element by its [DataBean.idField] value.
  ///
  /// Returns true if the element was found and updated, false otherwise.
  ///
  /// Must throw a [MissingIdFieldError] when the [DataObject] does not provide
  /// an ID-field.
  Future<bool> updateById(T element);

  /// Updates the given [values] of all elements matching the [filter].
  ///
  /// Returns the affected element count.
  Future<int> updateAll({
    required Filter filter,
    required Map<DataField<T, dynamic>, dynamic> values,
  });

  /// Find and delete an element by its [DataBean.idField] value.
  ///
  /// Returns true if the element was found and deleted, false otherwise.
  ///
  /// Must throw a [MissingIdFieldError] when the [DataObject] does not provide
  /// an ID-field.
  Future<bool> deleteById(dynamic id);

  /// Deletes all elements matching the [filter].
  ///
  /// Returns the affected element count.
  Future<int> deleteAll({required Filter filter});

  /// Runs all calls to this repository from inside [delegate] inside an
  /// atomic transaction.
  Future<R> atomic<R>(Future<R> Function() delegate);
}

extension DataRepositoryExtension<T extends DataObject> on DataRepository<T> {
  Future<T?> first({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int offset = 0,
  }) async {
    final results = await readAll(
      filter: filter,
      sort: sort,
      offset: offset,
      limit: 1,
    );

    return results.firstOrNull;
  }
}
