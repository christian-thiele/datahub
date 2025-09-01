// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract class _Person with DataObject<Person> {
  const _Person();
  static final $id = DataField<Person, int>(name: 'id', valueOf: (p) => p.id);

  static final $firstName =
      DataField<Person, String>(name: 'firstName', valueOf: (p) => p.firstName);

  static final $lastName =
      DataField<Person, String>(name: 'lastName', valueOf: (p) => p.lastName);

  static final $birthday = DataField<Person, DateTime?>(
      name: 'birthday', valueOf: (p) => p.birthday);

  static final DataBean<Person> bean = DataBean<Person>(
    name: 'Person',
    fields: List<DataField<Person, dynamic>>.unmodifiable([
      $id,
      $firstName,
      $lastName,
      $birthday,
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
  }) {
    final $data = this as Person;
    return Person(
      id: id ?? $data.id,
      firstName: firstName ?? $data.firstName,
      lastName: lastName ?? $data.lastName,
      birthday: nullBirthday ? null : (birthday ?? $data.birthday),
    );
  }

  static Person fromValues(Map<String, dynamic> data) {
    return Person(
      id: data['id'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      birthday: data['birthday'],
    );
  }

  static Person fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Person, data.runtimeType, name);
    }
    final $codec = const JsonDataCodec();
    return Person(
      id: $codec.decodeInt(data['id'], name: DataCodec.childName(name, 'id')),
      firstName: $codec.decodeString(data['firstName'],
          name: DataCodec.childName(name, 'firstName')),
      lastName: $codec.decodeString(data['lastName'],
          name: DataCodec.childName(name, 'lastName')),
      birthday: $codec.decodeNullable(data['birthday'], $codec.decodeDateTime,
          name: DataCodec.childName(name, 'birthday')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $codec = const JsonDataCodec();
    final $data = this as Person;
    return {
      'id': $codec.encodeInt($data.id),
      'firstName': $codec.encodeString($data.firstName),
      'lastName': $codec.encodeString($data.lastName),
      'birthday': $codec.encodeNullable($data.birthday, $codec.encodeDateTime),
    }..removeWhere((k, v) => v == null);
  }
}
