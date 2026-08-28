// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Pet with DataObject<Pet> {
  const $Pet();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Pet, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $name = DataField<Pet, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    constraints: [
      const MinLengthConstraint<String?>(length: 3),
      const MaxLengthConstraint<String?>(length: 30),
    ],
  );

  static final $kind = DataField<Pet, PetKind>(
    name: 'kind',
    valueOf: (p) => p.kind,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, PetKind.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: PetKind.values)],
  );

  static final $age = DataField<Pet, int?>(
    name: 'age',
    valueOf: (p) => p.age,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [const Meta(description: 'Age in years.')],
    constraints: [const RangeConstraint<num?>(min: 0, max: 100)],
  );

  static final $vaccinated = DataField<Pet, bool>(
    name: 'vaccinated',
    valueOf: (p) => p.vaccinated,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $born = DataField<Pet, DateTime?>(
    name: 'born',
    valueOf: (p) => p.born,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $tags = DataField<Pet, List<String>>(
    name: 'tags',
    valueOf: (p) => p.tags,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
    constraints: [
      const ElementConstraint<String?, List<String?>>(
        constraint: const RegExpConstraint<String?>(expression: '^[a-z]+\$'),
      ),
    ],
  );

  static final $owner = DataField<Pet, Owner?>(
    name: 'owner',
    valueOf: (p) => p.owner,
    dataBean: () => $Owner.bean,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $Owner.bean.fromJson, name: name),
    toJson: (value) => $$codec.encodeNullable(value, (v) => v.toJson()),
  );

  static final DataBean<Pet> bean = DataBean<Pet>(
    name: 'Pet',
    fields: List<DataField<Pet, dynamic>>.unmodifiable([
      $id,
      $name,
      $kind,
      $age,
      $vaccinated,
      $born,
      $tags,
      $owner,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [const Meta(name: 'Pet', description: 'A pet in the store.')],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Pet, dynamic>> get $$fields => bean.fields;
  Pet copyWith({
    int? id,
    String? name,
    PetKind? kind,
    int? age,
    bool nullAge = false,
    bool? vaccinated,
    DateTime? born,
    bool nullBorn = false,
    List<String>? tags,
    Owner? owner,
    bool nullOwner = false,
  }) {
    final $data = this as Pet;
    return Pet(
      id: id ?? $data.id,
      name: name ?? $data.name,
      kind: kind ?? $data.kind,
      age: nullAge ? null : (age ?? $data.age),
      vaccinated: vaccinated ?? $data.vaccinated,
      born: nullBorn ? null : (born ?? $data.born),
      tags: tags ?? $data.tags,
      owner: nullOwner ? null : (owner ?? $data.owner),
    );
  }

  static Pet fromValues(Map<String, dynamic> data) {
    return Pet(
      id: data['id'] ?? 0,
      name: data['name'],
      kind: data['kind'],
      age: data['age'],
      vaccinated: data['vaccinated'],
      born: data['born'],
      tags: data['tags']?.cast<String>().toList(growable: false) ?? const [],
      owner: data['owner'],
    );
  }

  static Pet fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Pet, data.runtimeType, name);
    }
    return Pet(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      kind: $kind.fromJson(
        data['kind'],
        name: DataCodec.childName(name, 'kind'),
      ),
      age: $age.fromJson(data['age'], name: DataCodec.childName(name, 'age')),
      vaccinated: $vaccinated.fromJson(
        data['vaccinated'],
        name: DataCodec.childName(name, 'vaccinated'),
      ),
      born: $born.fromJson(
        data['born'],
        name: DataCodec.childName(name, 'born'),
      ),
      tags: $tags.fromJson(
        data['tags'],
        name: DataCodec.childName(name, 'tags'),
      ),
      owner: $owner.fromJson(
        data['owner'],
        name: DataCodec.childName(name, 'owner'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Pet;
    return {
      'id': $id.toJson($$data.id),
      'name': $name.toJson($$data.name),
      'kind': $kind.toJson($$data.kind),
      'age': $age.toJson($$data.age),
      'vaccinated': $vaccinated.toJson($$data.vaccinated),
      'born': $born.toJson($$data.born),
      'tags': $tags.toJson($$data.tags),
      'owner': $owner.toJson($$data.owner),
    }..removeWhere((k, v) => v == null);
  }
}

abstract interface class $Owner with DataObject<Owner> {
  const $Owner();
  static const $$codec = JsonDataCodec();
  static final $name = DataField<Owner, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $pets = DataField<Owner, List<Pet>>(
    name: 'pets',
    valueOf: (p) => p.pets,
    dataBean: () => $Pet.bean,
    fromJson: (value, {String? name}) => $$codec.decodeList<Pet>(
      (value ?? const []),
      $Pet.bean.fromJson,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<Pet>(value, (v) => v.toJson()),
  );

  static final DataBean<Owner> bean = DataBean<Owner>(
    name: 'Owner',
    fields: List<DataField<Owner, dynamic>>.unmodifiable([$name, $pets]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Owner, dynamic>> get $$fields => bean.fields;
  Owner copyWith({String? name, List<Pet>? pets}) {
    final $data = this as Owner;
    return Owner(name: name ?? $data.name, pets: pets ?? $data.pets);
  }

  static Owner fromValues(Map<String, dynamic> data) {
    return Owner(
      name: data['name'],
      pets: data['pets']?.cast<Pet>().toList(growable: false) ?? const [],
    );
  }

  static Owner fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Owner, data.runtimeType, name);
    }
    return Owner(
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      pets: $pets.fromJson(
        data['pets'],
        name: DataCodec.childName(name, 'pets'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Owner;
    return {
      'name': $name.toJson($$data.name),
      'pets': $pets.toJson($$data.pets),
    }..removeWhere((k, v) => v == null);
  }
}
