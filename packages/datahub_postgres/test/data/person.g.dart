// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Person with DataObject<Person> {
  const $Person();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Person, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $firstName = DataField<Person, String>(
    name: 'firstName',
    valueOf: (p) => p.firstName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $lastName = DataField<Person, String>(
    name: 'lastName',
    valueOf: (p) => p.lastName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $birthday = DataField<Person, DateTime?>(
    name: 'birthday',
    valueOf: (p) => p.birthday,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $isSpecial = DataField<Person, bool>(
    name: 'isSpecial',
    valueOf: (p) => p.isSpecial,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final DataBean<Person> bean = DataBean<Person>(
    name: 'Person',
    fields: List<DataField<Person, dynamic>>.unmodifiable([
      $id,
      $firstName,
      $lastName,
      $birthday,
      $isSpecial,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Person, dynamic>> get $$fields => bean.fields;
  Person copyWith({
    int? id,
    String? firstName,
    String? lastName,
    DateTime? birthday,
    bool nullBirthday = false,
    bool? isSpecial,
  }) {
    final $data = this as Person;
    return Person(
      id: id ?? $data.id,
      firstName: firstName ?? $data.firstName,
      lastName: lastName ?? $data.lastName,
      birthday: nullBirthday ? null : (birthday ?? $data.birthday),
      isSpecial: isSpecial ?? $data.isSpecial,
    );
  }

  static Person fromValues(Map<String, dynamic> data) {
    return Person(
      id: data['id'] ?? 0,
      firstName: data['firstName'],
      lastName: data['lastName'],
      birthday: data['birthday'],
      isSpecial: data['isSpecial'],
    );
  }

  static Person fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Person, data.runtimeType, name);
    }
    return Person(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      firstName: $firstName.fromJson(
        data['firstName'],
        name: DataCodec.childName(name, 'firstName'),
      ),
      lastName: $lastName.fromJson(
        data['lastName'],
        name: DataCodec.childName(name, 'lastName'),
      ),
      birthday: $birthday.fromJson(
        data['birthday'],
        name: DataCodec.childName(name, 'birthday'),
      ),
      isSpecial: $isSpecial.fromJson(
        data['isSpecial'],
        name: DataCodec.childName(name, 'isSpecial'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Person;
    return {
      'id': $id.toJson($$data.id),
      'firstName': $firstName.toJson($$data.firstName),
      'lastName': $lastName.toJson($$data.lastName),
      'birthday': $birthday.toJson($$data.birthday),
      'isSpecial': $isSpecial.toJson($$data.isSpecial),
    }..removeWhere((k, v) => v == null);
  }
}
