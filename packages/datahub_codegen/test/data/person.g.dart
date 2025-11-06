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

  static final $phone = DataField<Person, List<String>>(
    name: 'phone',
    valueOf: (p) => p.phone,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $email = DataField<Person, List<String>>(
    name: 'email',
    valueOf: (p) => p.email,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $birthday = DataField<Person, DateTime?>(
    name: 'birthday',
    valueOf: (p) => p.birthday,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $isBlocked = DataField<Person, bool>(
    name: 'isBlocked',
    valueOf: (p) => p.isBlocked,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $picture = DataField<Person, Uint8List>(
    name: 'picture',
    valueOf: (p) => p.picture,
    fromJson: (value, {String? name}) =>
        $$codec.decodeUint8List(value, name: name),
    toJson: (value) => $$codec.encodeUint8List(value),
  );

  static final DataBean<Person> bean = DataBean<Person>(
    name: 'Person',
    fields: List<DataField<Person, dynamic>>.unmodifiable([
      $id,
      $firstName,
      $lastName,
      $phone,
      $email,
      $birthday,
      $isBlocked,
      $picture,
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
    List<String>? phone,
    List<String>? email,
    DateTime? birthday,
    bool nullBirthday = false,
    bool? isBlocked,
    Uint8List? picture,
  }) {
    final $data = this as Person;
    return Person(
      id: id ?? $data.id,
      firstName: firstName ?? $data.firstName,
      lastName: lastName ?? $data.lastName,
      phone: phone ?? $data.phone,
      email: email ?? $data.email,
      birthday: nullBirthday ? null : (birthday ?? $data.birthday),
      isBlocked: isBlocked ?? $data.isBlocked,
      picture: picture ?? $data.picture,
    );
  }

  static Person fromValues(Map<String, dynamic> data) {
    return Person(
      id: data['id'] ?? 0,
      firstName: data['firstName'],
      lastName: data['lastName'],
      phone: data['phone']?.cast<String>().toList(growable: false),
      email: data['email']?.cast<String>().toList(growable: false),
      birthday: data['birthday'],
      isBlocked: data['isBlocked'],
      picture: data['picture'],
    );
  }

  static Person fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Person, data.runtimeType, name);
    }
    return Person(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      firstName: $firstName.fromJson(data['firstName'],
          name: DataCodec.childName(name, 'firstName')),
      lastName: $lastName.fromJson(data['lastName'],
          name: DataCodec.childName(name, 'lastName')),
      phone: $phone.fromJson(data['phone'],
          name: DataCodec.childName(name, 'phone')),
      email: $email.fromJson(data['email'],
          name: DataCodec.childName(name, 'email')),
      birthday: $birthday.fromJson(data['birthday'],
          name: DataCodec.childName(name, 'birthday')),
      isBlocked: $isBlocked.fromJson(data['isBlocked'],
          name: DataCodec.childName(name, 'isBlocked')),
      picture: $picture.fromJson(data['picture'],
          name: DataCodec.childName(name, 'picture')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Person;
    return {
      'id': $id.toJson($$data.id),
      'firstName': $firstName.toJson($$data.firstName),
      'lastName': $lastName.toJson($$data.lastName),
      'phone': $phone.toJson($$data.phone),
      'email': $email.toJson($$data.email),
      'birthday': $birthday.toJson($$data.birthday),
      'isBlocked': $isBlocked.toJson($$data.isBlocked),
      'picture': $picture.toJson($$data.picture),
    }..removeWhere((k, v) => v == null);
  }
}
