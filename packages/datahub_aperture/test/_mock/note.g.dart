// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Note with DataObject<Note> {
  const $Note();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Note, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    defaultValue: 0,
    meta: [const Id(auto: true)],
  );

  static final $title = DataField<Note, String>(
    name: 'title',
    valueOf: (p) => p.title,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true)],
  );

  static final $body = DataField<Note, String>(
    name: 'body',
    valueOf: (p) => p.body,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $secret = DataField<Note, String>(
    name: 'secret',
    valueOf: (p) => p.secret,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(allowSearch: false)],
  );

  static final $priority = DataField<Note, int>(
    name: 'priority',
    valueOf: (p) => p.priority,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $created = DataField<Note, DateTime>(
    name: 'created',
    valueOf: (p) => p.created,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final DataBean<Note> bean = DataBean<Note>(
    name: 'Note',
    fields: List<DataField<Note, dynamic>>.unmodifiable([
      $id,
      $title,
      $body,
      $secret,
      $priority,
      $created,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [const Meta(icon: 58441)],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Note, dynamic>> get $$fields => bean.fields;
  Note copyWith({
    int? id,
    String? title,
    String? body,
    String? secret,
    int? priority,
    DateTime? created,
  }) {
    final $data = this as Note;
    return Note(
      id: id ?? $data.id,
      title: title ?? $data.title,
      body: body ?? $data.body,
      secret: secret ?? $data.secret,
      priority: priority ?? $data.priority,
      created: created ?? $data.created,
    );
  }

  static Note fromValues(Map<String, dynamic> data) {
    return Note(
      id: data['id'] ?? 0,
      title: data['title'],
      body: data['body'],
      secret: data['secret'],
      priority: data['priority'],
      created: data['created'],
    );
  }

  static Note fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Note, data.runtimeType, name);
    }
    return Note(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      title: $title.fromJson(
        data['title'],
        name: DataCodec.childName(name, 'title'),
      ),
      body: $body.fromJson(
        data['body'],
        name: DataCodec.childName(name, 'body'),
      ),
      secret: $secret.fromJson(
        data['secret'],
        name: DataCodec.childName(name, 'secret'),
      ),
      priority: $priority.fromJson(
        data['priority'],
        name: DataCodec.childName(name, 'priority'),
      ),
      created: $created.fromJson(
        data['created'],
        name: DataCodec.childName(name, 'created'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Note;
    return {
      'id': $id.toJson($$data.id),
      'title': $title.toJson($$data.title),
      'body': $body.toJson($$data.body),
      'secret': $secret.toJson($$data.secret),
      'priority': $priority.toJson($$data.priority),
      'created': $created.toJson($$data.created),
    }..removeWhere((k, v) => v == null);
  }
}
