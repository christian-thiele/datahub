import 'dart:async';

import 'package:boost/boost.dart';
import 'package:datahub/datahub.dart';

class MemoryRepositoryService<T extends DataObject<T>> implements Service {
  final DataBean<T> bean;
  final List<T>? initialData;

  const MemoryRepositoryService({required this.bean, this.initialData});

  @override
  ServiceInstance<Service> createInstance() =>
      _MemoryRepositoryServiceInstance<T>();
}

class _MemoryRepositoryServiceInstance<T extends DataObject<T>>
    extends ServiceInstance<MemoryRepositoryService<T>>
    implements DataRepository<T> {
  @override
  DataBean<T> get bean => service.bean;
  late final Map<dynamic, T> _map;
  int _idSeq = 0;

  @override
  Future<void> initialize() async {
    await super.initialize();
    if (service.bean.requireIdField.type.isExact<int>()) {
      _map = <int, T>{};
    } else {
      _map = <String, T>{};
    }

    if (service.initialData != null) {
      for (final entry in service.initialData!) {
        await create(entry);
      }
    }
  }

  @override
  Future<T> create(T element) async {
    dynamic id;
    if (service.bean.requireIdField.hasMetaOfType<Id>((id) => id.auto)) {
      if (service.bean.requireIdField is DataField<dynamic, int>) {
        id = ++_idSeq;
      } else if (service.bean.requireIdField is DataField<dynamic, String>) {
        id = uuid();
      } else {
        throw ApiError('Invalid ID-Field type.');
      }
    } else {
      id = bean.requireIdField.valueOf(element);
    }

    if (_map.containsKey(id)) {
      throw ApiException('Duplicate id in MemoryRepository.');
    }

    _map[id] = service.bean.fromValues({
      for (final field in service.bean.fields)
        field.name: field.valueOf(element),
      service.bean.requireIdField.name: id,
    });

    return _map[id]!;
  }

  @override
  Future<int> deleteAll({required Filter filter}) async {
    final lengthBefore = _map.length;
    _map.removeWhere((key, data) => evaluateFilter(data, filter));
    return lengthBefore - _map.length;
  }

  @override
  Future<bool> deleteById(id) async {
    return _map.remove(_alignIdType(id)) != null;
  }

  @override
  Future<List<T>> readAll({
    Filter filter = Filter.empty,
    Sort sort = Sort.empty,
    int? offset,
    int? limit,
  }) async {
    final sorted = _map.values.toList();
    if (sort case ExpressionSort(expression: final DataField sortField)) {
      sorted.sortBy((e) => sortField.valueOf(e) as Comparable);
    }

    return sorted
        .where((e) => evaluateFilter(e, filter))
        .skip(offset ?? 0)
        .take(limit ?? _map.length)
        .toList();
  }

  @override
  Future<T?> readById(id) async {
    return _map[_alignIdType(id)];
  }

  @override
  Future<int> updateAll({
    required Filter filter,
    required Map<DataField<T, dynamic>, dynamic> values,
  }) async {
    var count = 0;
    for (final key in _map.keys.toList()) {
      final data = _map[key]!;
      if (evaluateFilter(data, filter)) {
        _map[key] = bean.fromValues({
          for (final field in bean.fields) field.name: field.valueOf(data),
          for (final (field, value) in values.tuples) field.name: value,
        });
        count++;
      }
    }
    return count;
  }

  @override
  Future<bool> updateById(T element) async {
    final id = bean.requireIdField.valueOf(element);
    if (_map.containsKey(id)) {
      _map[id] = element;
      return true;
    } else {
      return false;
    }
  }

  bool evaluateFilter(T data, Filter filter) => filter.matches(data);

  @override
  Future<R> atomic<R>(Future<R> Function() delegate) async {
    return await delegate();
  }

  @override
  Future<int> count({Filter filter = Filter.empty}) async {
    final all = await readAll(filter: filter);
    return all.length;
  }

  dynamic _alignIdType(dynamic id) {
    if (bean.requireIdField.type.isExact<int>()) {
      return switch (id) {
        int() => id,
        _ => int.tryParse(id.toString()) ?? (throw ApiException('Invalid id.')),
      };
    } else {
      return id.toString();
    }
  }
}
