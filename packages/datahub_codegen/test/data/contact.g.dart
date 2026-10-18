// GENERATED CODE - DO NOT MODIFY BY HAND
// @dart=3.13

part of 'contact.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Contact with DataObject<Contact> {
  const $Contact();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Contact, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id()],
  );

  static final $name = DataField<Contact, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $email = DataField<Contact, String>(
    name: 'email',
    valueOf: (p) => p.email,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    constraints: [const MinLengthConstraint<String?>(length: 3)],
  );

  static final $type = DataField<Contact, ContactType?>(
    name: 'type',
    valueOf: (p) => p.type,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      (v, {String? name}) =>
          $$codec.decodeEnum(v, ContactType.values, name: name),
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeEnum),
    constraints: [EnumConstraint(values: ContactType.values)],
  );

  static final $tags = DataField<Contact, List<String>>(
    name: 'tags',
    valueOf: (p) => p.tags,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $note = DataField<Contact, String>(
    name: 'note',
    valueOf: (p) => p._note,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final DataBean<Contact> bean = DataBean<Contact>(
    name: 'Contact',
    fields: List<DataField<Contact, dynamic>>.unmodifiable([
      $id,
      $name,
      $email,
      $type,
      $tags,
      $note,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Contact, dynamic>> get $$fields => bean.fields;
  Contact copyWith({
    int? id,
    String? name,
    String? email,
    ContactType? type,
    bool nullType = false,
    List<String>? tags,
    String? note,
  }) {
    final $data = this as Contact;
    return Contact(
      id: id ?? $data.id,
      name: name ?? $data.name,
      email: email ?? $data.email,
      type: nullType ? null : (type ?? $data.type),
      tags: tags ?? $data.tags,
      note: note ?? $data._note,
    );
  }

  static Contact fromValues(Map<String, dynamic> data) {
    return Contact(
      id: data['id'] ?? 0,
      name: data['name'],
      email: data['email'],
      type: data['type'],
      tags: data['tags']?.cast<String>().toList(growable: false) ?? const [],
      note: data['note'],
    );
  }

  static Contact fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Contact, data.runtimeType, name);
    }
    return Contact(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      name: $name.fromJson(
        data['display_name'],
        name: DataCodec.childName(name, 'display_name'),
      ),
      email: $email.fromJson(
        data['email'],
        name: DataCodec.childName(name, 'email'),
      ),
      type: $type.fromJson(
        data['type'],
        name: DataCodec.childName(name, 'type'),
      ),
      tags: $tags.fromJson(
        data['tags'],
        name: DataCodec.childName(name, 'tags'),
      ),
      note: $note.fromJson(
        data['note'],
        name: DataCodec.childName(name, 'note'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Contact;
    return {
      'id': $id.toJson($$data.id),
      'display_name': $name.toJson($$data.name),
      'email': $email.toJson($$data.email),
      'type': $type.toJson($$data.type),
      'tags': $tags.toJson($$data.tags),
      'note': $note.toJson($$data._note),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $Vector with DataObject<Vector> {
  const $Vector();
  static const $$codec = JsonDataCodec();
  static final $x = DataField<Vector, int>(
    name: 'x',
    valueOf: (p) => p.x,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $y = DataField<Vector, int>(
    name: 'y',
    valueOf: (p) => p.y,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
  );

  static final $z = DataField<Vector, int?>(
    name: 'z',
    valueOf: (p) => p.z,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final DataBean<Vector> bean = DataBean<Vector>(
    name: 'Vector',
    fields: List<DataField<Vector, dynamic>>.unmodifiable([$x, $y, $z]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Vector, dynamic>> get $$fields => bean.fields;
  Vector copyWith({int? x, int? y, int? z, bool nullZ = false}) {
    final $data = this as Vector;
    return Vector(x ?? $data.x, y ?? $data.y, nullZ ? null : (z ?? $data.z));
  }

  static Vector fromValues(Map<String, dynamic> data) {
    return Vector(data['x'], data['y'], data['z']);
  }

  static Vector fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Vector, data.runtimeType, name);
    }
    return Vector(
      $x.fromJson(data['x'], name: DataCodec.childName(name, 'x')),
      $y.fromJson(data['y'], name: DataCodec.childName(name, 'y')),
      $z.fromJson(data['z'], name: DataCodec.childName(name, 'z')),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Vector;
    return {
      'x': $x.toJson($$data.x),
      'y': $y.toJson($$data.y),
      'z': $z.toJson($$data.z),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $Address with DataObject<Address> {
  const $Address();
  static const $$codec = JsonDataCodec();
  static final $streetName = DataField<Address, String>(
    name: 'streetName',
    valueOf: (p) => p.streetName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $houseNumber = DataField<Address, int?>(
    name: 'houseNumber',
    valueOf: (p) => p.houseNumber,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
  );

  static final DataBean<Address> bean = DataBean<Address>(
    name: 'Address',
    fields: List<DataField<Address, dynamic>>.unmodifiable([
      $streetName,
      $houseNumber,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Address, dynamic>> get $$fields => bean.fields;
  Address copyWith({
    String? streetName,
    int? houseNumber,
    bool nullHouseNumber = false,
  }) {
    final $data = this as Address;
    return Address.create(
      streetName: streetName ?? $data.streetName,
      houseNumber: nullHouseNumber ? null : (houseNumber ?? $data.houseNumber),
    );
  }

  static Address fromValues(Map<String, dynamic> data) {
    return Address.create(
      streetName: data['streetName'],
      houseNumber: data['houseNumber'],
    );
  }

  static Address fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Address, data.runtimeType, name);
    }
    return Address.create(
      streetName: $streetName.fromJson(
        data['street_name'],
        name: DataCodec.childName(name, 'street_name'),
      ),
      houseNumber: $houseNumber.fromJson(
        data['house_number'],
        name: DataCodec.childName(name, 'house_number'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Address;
    return {
      'street_name': $streetName.toJson($$data.streetName),
      'house_number': $houseNumber.toJson($$data.houseNumber),
    }..removeWhere((k, v) => v == null);
  }
}
