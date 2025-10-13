import 'package:datahub/data.dart';

import 'revision_data.dart';

abstract interface class RevisableRepository<T extends DataObject> {
  DataBean<T> get bean;

  Future<RevisionData<T>?> getData(dynamic id, {String? revisionId});

  Future<List<RevisionData<T>>> getRevisions(
    dynamic id, {
    int? offset,
    int? limit,
  });

  Future<List<RevisionData<T>>> getAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
  });

  Future<RevisionData<T>> createRevision(
    T data, {
    required DateTime? live,
    required String by,
    required int type,
  });
}
