// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'path_item_object.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $PathItemObject with DataObject<PathItemObject> {
  const $PathItemObject();
  static const $$codec = JsonDataCodec();
  static final $get = DataField<PathItemObject, OperationObject?>(
    name: 'get',
    valueOf: (p) => p.get,
    dataBean: () => $OperationObject.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      $OperationObject.bean.fromJson,
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final $put = DataField<PathItemObject, OperationObject?>(
    name: 'put',
    valueOf: (p) => p.put,
    dataBean: () => $OperationObject.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      $OperationObject.bean.fromJson,
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final $post = DataField<PathItemObject, OperationObject?>(
    name: 'post',
    valueOf: (p) => p.post,
    dataBean: () => $OperationObject.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      $OperationObject.bean.fromJson,
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final $delete = DataField<PathItemObject, OperationObject?>(
    name: 'delete',
    valueOf: (p) => p.delete,
    dataBean: () => $OperationObject.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      $OperationObject.bean.fromJson,
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final $options = DataField<PathItemObject, OperationObject?>(
    name: 'options',
    valueOf: (p) => p.options,
    dataBean: () => $OperationObject.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      $OperationObject.bean.fromJson,
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final $head = DataField<PathItemObject, OperationObject?>(
    name: 'head',
    valueOf: (p) => p.head,
    dataBean: () => $OperationObject.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      $OperationObject.bean.fromJson,
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final $patch = DataField<PathItemObject, OperationObject?>(
    name: 'patch',
    valueOf: (p) => p.patch,
    dataBean: () => $OperationObject.bean,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      $OperationObject.bean.fromJson,
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final DataBean<PathItemObject> bean = DataBean<PathItemObject>(
    name: 'PathItemObject',
    fields: List<DataField<PathItemObject, dynamic>>.unmodifiable([
      $get,
      $put,
      $post,
      $delete,
      $options,
      $head,
      $patch,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<PathItemObject, dynamic>> get $$fields => bean.fields;
  PathItemObject copyWith({
    OperationObject? get,
    bool nullGet = false,
    OperationObject? put,
    bool nullPut = false,
    OperationObject? post,
    bool nullPost = false,
    OperationObject? delete,
    bool nullDelete = false,
    OperationObject? options,
    bool nullOptions = false,
    OperationObject? head,
    bool nullHead = false,
    OperationObject? patch,
    bool nullPatch = false,
  }) {
    final $data = this as PathItemObject;
    return PathItemObject(
      get: nullGet ? null : (get ?? $data.get),
      put: nullPut ? null : (put ?? $data.put),
      post: nullPost ? null : (post ?? $data.post),
      delete: nullDelete ? null : (delete ?? $data.delete),
      options: nullOptions ? null : (options ?? $data.options),
      head: nullHead ? null : (head ?? $data.head),
      patch: nullPatch ? null : (patch ?? $data.patch),
    );
  }

  static PathItemObject fromValues(Map<String, dynamic> data) {
    return PathItemObject(
      get: data['get'],
      put: data['put'],
      post: data['post'],
      delete: data['delete'],
      options: data['options'],
      head: data['head'],
      patch: data['patch'],
    );
  }

  static PathItemObject fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(PathItemObject, data.runtimeType, name);
    }
    return PathItemObject(
      get: $get.fromJson(data['get'], name: DataCodec.childName(name, 'get')),
      put: $put.fromJson(data['put'], name: DataCodec.childName(name, 'put')),
      post: $post.fromJson(
        data['post'],
        name: DataCodec.childName(name, 'post'),
      ),
      delete: $delete.fromJson(
        data['delete'],
        name: DataCodec.childName(name, 'delete'),
      ),
      options: $options.fromJson(
        data['options'],
        name: DataCodec.childName(name, 'options'),
      ),
      head: $head.fromJson(
        data['head'],
        name: DataCodec.childName(name, 'head'),
      ),
      patch: $patch.fromJson(
        data['patch'],
        name: DataCodec.childName(name, 'patch'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as PathItemObject;
    return {
      'get': $get.toJson($$data.get),
      'put': $put.toJson($$data.put),
      'post': $post.toJson($$data.post),
      'delete': $delete.toJson($$data.delete),
      'options': $options.toJson($$data.options),
      'head': $head.toJson($$data.head),
      'patch': $patch.toJson($$data.patch),
    }..removeWhere((k, v) => v == null);
  }
}
