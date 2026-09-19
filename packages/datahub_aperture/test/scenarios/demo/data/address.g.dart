// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Address with DataObject<Address> {
  const $Address();
  static const $$codec = JsonDataCodec();
  static final $recipient = DataField<Address, String>(
    name: 'recipient',
    valueOf: (p) => p.recipient,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $attention = DataField<Address, String?>(
    name: 'attention',
    valueOf: (p) => p.attention,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [const Meta(name: 'Attn.')],
  );

  static final $street = DataField<Address, String>(
    name: 'street',
    valueOf: (p) => p.street,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $postalCode = DataField<Address, String>(
    name: 'postalCode',
    valueOf: (p) => p.postalCode,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Meta(name: 'Postal code')],
  );

  static final $city = DataField<Address, String>(
    name: 'city',
    valueOf: (p) => p.city,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $country = DataField<Address, String>(
    name: 'country',
    valueOf: (p) => p.country,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    constraints: [const RegExpConstraint<String?>(expression: '^[A-Z]{2}\$')],
  );

  static final DataBean<Address> bean = DataBean<Address>(
    name: 'Address',
    fields: List<DataField<Address, dynamic>>.unmodifiable([
      $recipient,
      $attention,
      $street,
      $postalCode,
      $city,
      $country,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Address, dynamic>> get $$fields => bean.fields;
  Address copyWith({
    String? recipient,
    String? attention,
    bool nullAttention = false,
    String? street,
    String? postalCode,
    String? city,
    String? country,
  }) {
    final $data = this as Address;
    return Address(
      recipient: recipient ?? $data.recipient,
      attention: nullAttention ? null : (attention ?? $data.attention),
      street: street ?? $data.street,
      postalCode: postalCode ?? $data.postalCode,
      city: city ?? $data.city,
      country: country ?? $data.country,
    );
  }

  static Address fromValues(Map<String, dynamic> data) {
    return Address(
      recipient: data['recipient'],
      attention: data['attention'],
      street: data['street'],
      postalCode: data['postalCode'],
      city: data['city'],
      country: data['country'],
    );
  }

  static Address fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Address, data.runtimeType, name);
    }
    return Address(
      recipient: $recipient.fromJson(
        data['recipient'],
        name: DataCodec.childName(name, 'recipient'),
      ),
      attention: $attention.fromJson(
        data['attention'],
        name: DataCodec.childName(name, 'attention'),
      ),
      street: $street.fromJson(
        data['street'],
        name: DataCodec.childName(name, 'street'),
      ),
      postalCode: $postalCode.fromJson(
        data['postalCode'],
        name: DataCodec.childName(name, 'postalCode'),
      ),
      city: $city.fromJson(
        data['city'],
        name: DataCodec.childName(name, 'city'),
      ),
      country: $country.fromJson(
        data['country'],
        name: DataCodec.childName(name, 'country'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Address;
    return {
      'recipient': $recipient.toJson($$data.recipient),
      'attention': $attention.toJson($$data.attention),
      'street': $street.toJson($$data.street),
      'postalCode': $postalCode.toJson($$data.postalCode),
      'city': $city.toJson($$data.city),
      'country': $country.toJson($$data.country),
    }..removeWhere((k, v) => v == null);
  }
}
