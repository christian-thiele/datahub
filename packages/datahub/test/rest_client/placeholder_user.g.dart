// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placeholder_user.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $PlaceholderUser with DataObject<PlaceholderUser> {
  const $PlaceholderUser();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<PlaceholderUser, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $name = DataField<PlaceholderUser, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<PlaceholderUser> bean = DataBean<PlaceholderUser>(
    name: 'PlaceholderUser',
    fields: List<DataField<PlaceholderUser, dynamic>>.unmodifiable([
      $id,
      $name,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<PlaceholderUser, dynamic>> get $$fields => bean.fields;
  PlaceholderUser copyWith({String? id, String? name}) {
    final $data = this as PlaceholderUser;
    return PlaceholderUser(id: id ?? $data.id, name: name ?? $data.name);
  }

  static PlaceholderUser fromValues(Map<String, dynamic> data) {
    return PlaceholderUser(id: data['id'], name: data['name']);
  }

  static PlaceholderUser fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        PlaceholderUser,
        data.runtimeType,
        name,
      );
    }
    return PlaceholderUser(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as PlaceholderUser;
    return {'id': $id.toJson($$data.id), 'name': $name.toJson($$data.name)}
      ..removeWhere((k, v) => v == null);
  }
}
