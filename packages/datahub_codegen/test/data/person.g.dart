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

  static final $phone =
      DataField<Person, List<String>>(name: 'phone', valueOf: (p) => p.phone);

  static final $email =
      DataField<Person, List<String>>(name: 'email', valueOf: (p) => p.email);

  static final $birthday = DataField<Person, DateTime?>(
      name: 'birthday', valueOf: (p) => p.birthday);

  static final $isBlocked =
      DataField<Person, bool>(name: 'isBlocked', valueOf: (p) => p.isBlocked);

  static final $picture =
      DataField<Person, Uint8List>(name: 'picture', valueOf: (p) => p.picture);

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
      id: data['id'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      phone: data['phone'],
      email: data['email'],
      birthday: data['birthday'],
      isBlocked: data['isBlocked'],
      picture: data['picture'],
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
      phone: $codec.decodeList<String>(data['phone'], $codec.decodeString,
          name: DataCodec.childName(name, 'phone')),
      email: $codec.decodeList<String>(data['email'], $codec.decodeString,
          name: DataCodec.childName(name, 'email')),
      birthday: $codec.decodeNullable(data['birthday'], $codec.decodeDateTime,
          name: DataCodec.childName(name, 'birthday')),
      isBlocked: $codec.decodeBool(data['isBlocked'],
          name: DataCodec.childName(name, 'isBlocked')),
      picture: $codec.decodeUint8List(data['picture'],
          name: DataCodec.childName(name, 'picture')),
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
      'phone': $codec.encodeList<String>($data.phone, $codec.encodeString),
      'email': $codec.encodeList<String>($data.email, $codec.encodeString),
      'birthday': $codec.encodeNullable($data.birthday, $codec.encodeDateTime),
      'isBlocked': $codec.encodeBool($data.isBlocked),
      'picture': $codec.encodeUint8List($data.picture),
    }..removeWhere((k, v) => v == null);
  }
}
