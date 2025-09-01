// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placeholder_user.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _PlaceholderUser with DataObject<PlaceholderUser> {
  const _PlaceholderUser();
  static final $id = DataField<PlaceholderUser, String>(
    name: 'id',
    valueOf: (p) => p.id,
  );

  static final $name = DataField<PlaceholderUser, String>(
    name: 'name',
    valueOf: (p) => p.name,
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
  PlaceholderUser copyWith({
    String? id,
    String? name,
  }) {
    final $data = this as PlaceholderUser;
    return PlaceholderUser(
      id: id ?? $data.id,
      name: name ?? $data.name,
    );
  }

  static PlaceholderUser fromValues(Map<String, dynamic> data) {
    return PlaceholderUser(
      id: data['id'],
      name: data['name'],
    );
  }

  static PlaceholderUser fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
          PlaceholderUser, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return PlaceholderUser(
      id: $codec.decodeString(data['id'],
          name: DataCodec.childName(name, 'id')),
      name: $codec.decodeString(data['name'],
          name: DataCodec.childName(name, 'name')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as PlaceholderUser;
    return {
      'id': $codec.encodeString($data.id),
      'name': $codec.encodeString($data.name),
    }..removeWhere((k, v) => v == null);
  }
}
