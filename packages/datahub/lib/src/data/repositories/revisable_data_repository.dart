import 'data_repository.dart';
import 'revisable_inconsistency_exception.dart';
import 'revision_data.dart';
import '../data_field.dart';
import '../data_object.dart';
import '../filter.dart';
import '../sort.dart';

/// An interface with default DataRepository adapter for [Component]s providing
/// CRUD functionality for revisable [DataObject] collections.
mixin RevisableDataRepository<T extends DataObject> on DataRepository<T> {
  /// Find and read an element with [RevisionData] by its [DataBean.idField]
  /// value.
  ///
  /// Returns the element or null if no element with the given id exists.
  ///
  /// Must throw a [MissingIdFieldError] when the [DataObject] does not provide
  /// an ID-field.
  Future<RevisionData<T>?> revisableReadById(dynamic id, {int? version});

  /// Read all elements with [RevisionData] respecting [filter], [sort],
  /// [offset] and [limit] values.
  Future<List<RevisionData<T>>> revisableReadAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
  });

  /// Find an element by its [DataBean.idField] value and reads all revisions
  /// of the element respecting [offset] and [limit] values.
  ///
  /// Returns an empty list if no element with the given id exists.
  Future<List<RevisionData<T>>> readRevisionsById(
    dynamic id, {
    int? offset,
    int? limit,
  });

  /// Create a new element revision.
  ///
  /// Must throw RevisableInconsistencyException in the following cases:
  ///   - type == -1 and element does not exist
  ///   - type == 0 and element does not exist
  ///   - type == 1 and element does exist
  Future<RevisionData<T>> createRevision(
    T data, {
    DateTime? from,
    required int type,
  });

  @override
  Future<T> create(T element, {DateTime? from}) async {
    //TODO createRevision must check if exists already
    final revision = await createRevision(element, type: 1, from: from);
    return revision.data;
  }

  @override
  Future<T?> readById(dynamic id) async {
    final revision = await revisableReadById(id);
    return revision?.data;
  }

  @override
  Future<List<T>> readAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
  }) async {
    final result = await revisableReadAll(
      filter: filter,
      sort: sort,
      offset: offset,
      limit: limit,
    );
    return result.map((e) => e.data).toList();
  }

  @override
  Future<bool> updateById(T element, {DateTime? from}) async {
    try {
      await createRevision(element, type: 0, from: from);
      return true;
    } on RevisableInconsistencyException catch (_) {
      return false;
    }
  }

  @override
  Future<int> updateAll({
    required Filter filter,
    required Map<DataField<T, dynamic>, dynamic> values,
  }) async {
    throw UnimplementedError(
      'updateAll is not implemented for RevisableDataRepositoryMixin.',
    );
  }

  @override
  Future<bool> deleteById(dynamic id, {DateTime? from}) async {
    try {
      final element = await revisableReadById(id);
      if (element == null) {
        return false;
      }

      await createRevision(element.data, type: -1, from: from);
      return true;
    } on RevisableInconsistencyException catch (_) {
      return false;
    }
  }

  @override
  Future<int> deleteAll({required Filter filter}) async {
    throw UnimplementedError(
      'deleteAll is not implemented for RevisableDataRepositoryMixin.',
    );
  }
}
