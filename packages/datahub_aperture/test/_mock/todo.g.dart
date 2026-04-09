// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Todo with DataObject<Todo> {
  const $Todo();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Todo, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $title = DataField<Todo, String>(
    name: 'title',
    valueOf: (p) => p.title,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureDisplayField()],
    constraints: [
      const MinLengthConstraint<String?>(length: 1),
      const MaxLengthConstraint<String?>(length: 255),
    ],
  );

  static final $description = DataField<Todo, String>(
    name: 'description',
    valueOf: (p) => p.description,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $dueDate = DataField<Todo, DateTime?>(
    name: 'dueDate',
    valueOf: (p) => p.dueDate,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final DataBean<Todo> bean = DataBean<Todo>(
    name: 'Todo',
    fields: List<DataField<Todo, dynamic>>.unmodifiable([
      $id,
      $title,
      $description,
      $dueDate,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [const Meta(icon: 57691)],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Todo, dynamic>> get $$fields => bean.fields;
  Todo copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool nullDueDate = false,
  }) {
    final $data = this as Todo;
    return Todo(
      id: id ?? $data.id,
      title: title ?? $data.title,
      description: description ?? $data.description,
      dueDate: nullDueDate ? null : (dueDate ?? $data.dueDate),
    );
  }

  static Todo fromValues(Map<String, dynamic> data) {
    return Todo(
      id: data['id'] ?? 0,
      title: data['title'],
      description: data['description'],
      dueDate: data['dueDate'],
    );
  }

  static Todo fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Todo, data.runtimeType, name);
    }
    return Todo(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      title: $title.fromJson(
        data['title'],
        name: DataCodec.childName(name, 'title'),
      ),
      description: $description.fromJson(
        data['description'],
        name: DataCodec.childName(name, 'description'),
      ),
      dueDate: $dueDate.fromJson(
        data['dueDate'],
        name: DataCodec.childName(name, 'dueDate'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Todo;
    return {
      'id': $id.toJson($$data.id),
      'title': $title.toJson($$data.title),
      'description': $description.toJson($$data.description),
      'dueDate': $dueDate.toJson($$data.dueDate),
    }..removeWhere((k, v) => v == null);
  }
}
