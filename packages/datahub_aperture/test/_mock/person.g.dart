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
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [
      const MinLengthConstraint<String?>(length: 3),
      const MaxLengthConstraint<String?>(length: 30),
    ],
  );

  static final $lastName = DataField<Person, String>(
    name: 'lastName',
    valueOf: (p) => p.lastName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [const MinLengthConstraint<String?>(length: 3)],
  );

  static final $nicknames = DataField<Person, List<String>>(
    name: 'nicknames',
    valueOf: (p) => p.nicknames,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [
      const ElementConstraint<String?>(
        constraint: const RegExpConstraint<String?>(expression: '^[^\\s]*\$'),
      ),
    ],
  );

  static final $address = DataField<Person, String>(
    name: 'address',
    valueOf: (p) => p.address,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    constraints: [
      const RegExpConstraint<String?>(expression: '[\\w-.]+ \\d+\\w*'),
    ],
  );

  static final $homeLocation = DataField<Person, Geometry>(
    name: 'homeLocation',
    valueOf: (p) => p.homeLocation,
    fromJson: (value, {String? name}) =>
        $$codec.decodeGeometry(value, name: name),
    toJson: (value) => $$codec.encodeGeometry(value),
  );

  static final $parentId = DataField<Person, int?>(
    name: 'parentId',
    valueOf: (p) => p.parentId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [const RelationId<Person>()],
  );

  static final DataBean<Person> bean = DataBean<Person>(
    name: 'Person',
    fields: List<DataField<Person, dynamic>>.unmodifiable([
      $id,
      $firstName,
      $lastName,
      $nicknames,
      $address,
      $homeLocation,
      $parentId,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(icon: 58513),
      const ApertureRelation<Person>(),
      const ApertureMeta(titleTemplate: '{{ firstName }} {{ lastName }}'),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Person, dynamic>> get $$fields => bean.fields;
  Person copyWith({
    int? id,
    String? firstName,
    String? lastName,
    List<String>? nicknames,
    String? address,
    Geometry? homeLocation,
    int? parentId,
    bool nullParentId = false,
  }) {
    final $data = this as Person;
    return Person(
      id: id ?? $data.id,
      firstName: firstName ?? $data.firstName,
      lastName: lastName ?? $data.lastName,
      nicknames: nicknames ?? $data.nicknames,
      address: address ?? $data.address,
      homeLocation: homeLocation ?? $data.homeLocation,
      parentId: nullParentId ? null : (parentId ?? $data.parentId),
    );
  }

  static Person fromValues(Map<String, dynamic> data) {
    return Person(
      id: data['id'] ?? 0,
      firstName: data['firstName'],
      lastName: data['lastName'],
      nicknames: data['nicknames']?.cast<String>().toList(growable: false),
      address: data['address'],
      homeLocation: data['homeLocation'],
      parentId: data['parentId'],
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
      nicknames: $nicknames.fromJson(
        data['nicknames'],
        name: DataCodec.childName(name, 'nicknames'),
      ),
      address: $address.fromJson(
        data['address'],
        name: DataCodec.childName(name, 'address'),
      ),
      homeLocation: $homeLocation.fromJson(
        data['homeLocation'],
        name: DataCodec.childName(name, 'homeLocation'),
      ),
      parentId: $parentId.fromJson(
        data['parentId'],
        name: DataCodec.childName(name, 'parentId'),
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
      'nicknames': $nicknames.toJson($$data.nicknames),
      'address': $address.toJson($$data.address),
      'homeLocation': $homeLocation.toJson($$data.homeLocation),
      'parentId': $parentId.toJson($$data.parentId),
    }..removeWhere((k, v) => v == null);
  }
}
