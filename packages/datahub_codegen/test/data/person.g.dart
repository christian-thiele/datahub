// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************
mixin _Person implements DataObject<Person> {
  int get id;

  String get firstName;

  String get lastName;

  List<String> get phone;

  List<String> get email;

  DateTime? get birthday;

  bool get isBlocked;

  Uint8List get picture;
}

class $Person with _Person, DataObject<Person> implements Person {
  @override
  final int id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final List<String> phone;
  @override
  final List<String> email;
  @override
  final DateTime? birthday;
  @override
  final bool isBlocked;
  @override
  final Uint8List picture;

  const $Person({
    this.id = 0,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.birthday,
    required this.isBlocked,
    required this.picture,
  });

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

  static final _name = 'Person';
  static final _fields = List<DataField<Person, dynamic>>.unmodifiable([
    $id,
    $firstName,
    $lastName,
    $phone,
    $email,
    $birthday,
    $isBlocked,
    $picture,
  ]);

  @override
  String get $$name => _name;

  @override
  List<DataField<Person, dynamic>> get $$fields => _fields;

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
    return Person(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthday: nullBirthday ? null : (birthday ?? this.birthday),
      isBlocked: isBlocked ?? this.isBlocked,
      picture: picture ?? this.picture,
    );
  }

  factory $Person.fromJson(Map<String, dynamic> data) {
    final codec = const JsonDataCodec();
    return $Person(
      id: codec.decodeInt(data['id'], name: 'id'),
      firstName: codec.decodeString(data['firstName'], name: 'firstName'),
      lastName: codec.decodeString(data['lastName'], name: 'lastName'),
      phone: codec.decodeList<String>(data['phone'], codec.decodeString,
          name: 'phone'),
      email: codec.decodeList<String>(data['email'], codec.decodeString,
          name: 'email'),
      birthday: codec.decodeNullable(data['birthday'], codec.decodeDateTime,
          name: 'birthday'),
      isBlocked: codec.decodeBool(data['isBlocked'], name: 'isBlocked'),
      picture: codec.decodeUint8List(data['picture'], name: 'picture'),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final codec = const JsonDataCodec();
    return {
      'id': codec.encodeInt(id),
      'firstName': codec.encodeString(firstName),
      'lastName': codec.encodeString(lastName),
      'phone': codec.encodeList<String>(phone, codec.encodeString),
      'email': codec.encodeList<String>(email, codec.encodeString),
      'birthday': codec.encodeNullable(birthday, codec.encodeDateTime),
      'isBlocked': codec.encodeBool(isBlocked),
      'picture': codec.encodeUint8List(picture),
    }..removeWhere((k, v) => v == null);
  }
}
