import 'package:datahub/ioc.dart';

import 'data_object.dart';
import 'data_bean.dart';
import 'filter.dart';
import 'sort.dart';

abstract interface class DataRepository<T extends DataObject<T>>
    extends BaseService {
  DataBean<T> get bean;

  Future<T?> get(dynamic id);

  Future<List<T>> getAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
  });

  Future<T> create(T element);

  Future<T> update(dynamic id, T element);

  Future<void> delete(dynamic id);
}
