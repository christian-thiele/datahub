// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Client with DataObject<Client> {
  const $Client();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Client, int>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 0), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Id(auto: true)],
  );

  static final $customerNumber = DataField<Client, String>(
    name: 'customerNumber',
    valueOf: (p) => p.customerNumber,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const ApertureField(isDisplayField: true, readOnly: true),
      const Meta(name: 'Customer No.', description: 'Assigned on creation.'),
    ],
    constraints: [const RegExpConstraint<String?>(expression: '^C-\\d{5}\$')],
  );

  static final $name = DataField<Client, String>(
    name: 'name',
    valueOf: (p) => p.name,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [
      const MinLengthConstraint<String?>(length: 2),
      const MaxLengthConstraint<String?>(length: 80),
    ],
  );

  static final $legalName = DataField<Client, String>(
    name: 'legalName',
    valueOf: (p) => p.legalName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const Meta(
        name: 'Legal name',
        description: 'Registered company name as used on invoices.',
      ),
    ],
    constraints: [const MaxLengthConstraint<String?>(length: 160)],
  );

  static final $industry = DataField<Client, Industry>(
    name: 'industry',
    valueOf: (p) => p.industry,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, Industry.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [EnumConstraint(values: Industry.values)],
  );

  static final $tier = DataField<Client, ClientTier>(
    name: 'tier',
    valueOf: (p) => p.tier,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? ClientTier.bronze),
      ClientTier.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    meta: [
      const Meta(
        description: 'Commercial tier. Drives discounts and support SLAs.',
      ),
    ],
    constraints: [EnumConstraint(values: ClientTier.values)],
  );

  static final $website = DataField<Client, String>(
    name: 'website',
    valueOf: (p) => p.website,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    constraints: [
      const RegExpConstraint<String?>(
        expression: '^https://[\\w.-]+\\.[a-z]{2,}(/.*)?\$',
      ),
    ],
  );

  static final $email = DataField<Client, String>(
    name: 'email',
    valueOf: (p) => p.email,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const Meta(name: 'E-mail', description: 'General inbox, e.g. office@…'),
    ],
    constraints: [
      const RegExpConstraint<String?>(
        expression: '^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+\$',
      ),
    ],
  );

  static final $phone = DataField<Client, String>(
    name: 'phone',
    valueOf: (p) => p.phone,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    constraints: [
      const RegExpConstraint<String?>(expression: '^\\+[\\d ]{7,20}\$'),
    ],
  );

  static final $vatId = DataField<Client, String?>(
    name: 'vatId',
    valueOf: (p) => p.vatId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [const Meta(name: 'VAT ID')],
    constraints: [
      const RegExpConstraint<String?>(expression: '^[A-Z]{2}[A-Z0-9]{8,12}\$'),
    ],
  );

  static final $addressStreet = DataField<Client, String>(
    name: 'addressStreet',
    valueOf: (p) => p.addressStreet,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Meta(name: 'Street')],
  );

  static final $addressPostalCode = DataField<Client, String>(
    name: 'addressPostalCode',
    valueOf: (p) => p.addressPostalCode,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Meta(name: 'Postal code')],
    constraints: [const MaxLengthConstraint<String?>(length: 10)],
  );

  static final $addressCity = DataField<Client, String>(
    name: 'addressCity',
    valueOf: (p) => p.addressCity,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const ApertureField(isDisplayField: true),
      const Meta(name: 'City'),
    ],
  );

  static final $addressCountry = DataField<Client, String>(
    name: 'addressCountry',
    valueOf: (p) => p.addressCountry,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const Meta(
        name: 'Country',
        description: 'ISO 3166-1 alpha-2 country code.',
      ),
    ],
    constraints: [const RegExpConstraint<String?>(expression: '^[A-Z]{2}\$')],
  );

  static final $location = DataField<Client, Geometry>(
    name: 'location',
    valueOf: (p) => p.location,
    fromJson: (value, {String? name}) =>
        $$codec.decodeGeometry(value, name: name),
    toJson: (value) => $$codec.encodeGeometry(value),
    meta: [
      const ApertureField(
        allowFilter: false,
        allowSearch: false,
        allowSort: false,
      ),
      const Meta(description: 'Location of the head office.'),
    ],
  );

  static final $onboarded = DataField<Client, DateTime>(
    name: 'onboarded',
    valueOf: (p) => p.onboarded,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
    meta: [
      const ApertureField(isDisplayField: true),
      const Meta(name: 'Onboarded since'),
    ],
  );

  static final $employeeCount = DataField<Client, int?>(
    name: 'employeeCount',
    valueOf: (p) => p.employeeCount,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [const Meta(name: 'Employees')],
    constraints: [const RangeConstraint<num?>(min: 1, max: 1000000)],
  );

  static final $annualRevenue = DataField<Client, double?>(
    name: 'annualRevenue',
    valueOf: (p) => p.annualRevenue,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDouble, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDouble),
    meta: [
      const Meta(
        name: 'Annual revenue',
        description: 'In millions, client currency.',
      ),
    ],
    constraints: [const RangeConstraint<num?>(min: 0, max: 1000000)],
  );

  static final $paymentTermDays = DataField<Client, int>(
    name: 'paymentTermDays',
    valueOf: (p) => p.paymentTermDays,
    fromJson: (value, {String? name}) =>
        $$codec.decodeInt((value ?? 30), name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [const Meta(name: 'Payment terms (days)')],
    constraints: [const RangeConstraint<num?>(min: 0, max: 120)],
  );

  static final $currency = DataField<Client, String>(
    name: 'currency',
    valueOf: (p) => p.currency,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString((value ?? 'EUR'), name: name),
    toJson: (value) => $$codec.encodeString(value),
    constraints: [const RegExpConstraint<String?>(expression: '^[A-Z]{3}\$')],
  );

  static final $tags = DataField<Client, List<String>>(
    name: 'tags',
    valueOf: (p) => p.tags,
    fromJson: (value, {String? name}) => $$codec.decodeList<String>(
      (value ?? const []),
      $$codec.decodeString,
      name: name,
    ),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
    constraints: [
      const ElementConstraint<String?>(
        constraint: const RegExpConstraint<String?>(
          expression: '^[a-z0-9-]+\$',
        ),
      ),
    ],
  );

  static final $notes = DataField<Client, String?>(
    name: 'notes',
    valueOf: (p) => p.notes,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [const ApertureField(allowFilter: false, allowSort: false)],
    constraints: [const MaxLengthConstraint<String?>(length: 2000)],
  );

  static final $accountManagerId = DataField<Client, int?>(
    name: 'accountManagerId',
    valueOf: (p) => p.accountManagerId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeInt, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeInt),
    meta: [
      const Meta(name: 'Account manager'),
      const RelationId<Employee>(),
    ],
  );

  static final $active = DataField<Client, bool>(
    name: 'active',
    valueOf: (p) => p.active,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? true), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final DataBean<Client> bean = DataBean<Client>(
    name: 'Client',
    fields: List<DataField<Client, dynamic>>.unmodifiable([
      $id,
      $customerNumber,
      $name,
      $legalName,
      $industry,
      $tier,
      $website,
      $email,
      $phone,
      $vatId,
      $addressStreet,
      $addressPostalCode,
      $addressCity,
      $addressCountry,
      $location,
      $onboarded,
      $employeeCount,
      $annualRevenue,
      $paymentTermDays,
      $currency,
      $tags,
      $notes,
      $accountManagerId,
      $active,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(
        namePlural: 'Clients',
        description: 'Companies we work for, including prospects.',
        icon: 57627,
      ),
      const ApertureMeta(titleTemplate: '{{ name }}'),
      const ApertureRelation<Contact>(),
      const ApertureRelation<Project>(),
      const ApertureRelation<Product>(),
      const ApertureRelation<Invoice>(),
      const ApertureRelation<SupportTicket>(),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Client, dynamic>> get $$fields => bean.fields;
  Client copyWith({
    int? id,
    String? customerNumber,
    String? name,
    String? legalName,
    Industry? industry,
    ClientTier? tier,
    String? website,
    String? email,
    String? phone,
    String? vatId,
    bool nullVatId = false,
    String? addressStreet,
    String? addressPostalCode,
    String? addressCity,
    String? addressCountry,
    Geometry? location,
    DateTime? onboarded,
    int? employeeCount,
    bool nullEmployeeCount = false,
    double? annualRevenue,
    bool nullAnnualRevenue = false,
    int? paymentTermDays,
    String? currency,
    List<String>? tags,
    String? notes,
    bool nullNotes = false,
    int? accountManagerId,
    bool nullAccountManagerId = false,
    bool? active,
  }) {
    final $data = this as Client;
    return Client(
      id: id ?? $data.id,
      customerNumber: customerNumber ?? $data.customerNumber,
      name: name ?? $data.name,
      legalName: legalName ?? $data.legalName,
      industry: industry ?? $data.industry,
      tier: tier ?? $data.tier,
      website: website ?? $data.website,
      email: email ?? $data.email,
      phone: phone ?? $data.phone,
      vatId: nullVatId ? null : (vatId ?? $data.vatId),
      addressStreet: addressStreet ?? $data.addressStreet,
      addressPostalCode: addressPostalCode ?? $data.addressPostalCode,
      addressCity: addressCity ?? $data.addressCity,
      addressCountry: addressCountry ?? $data.addressCountry,
      location: location ?? $data.location,
      onboarded: onboarded ?? $data.onboarded,
      employeeCount: nullEmployeeCount
          ? null
          : (employeeCount ?? $data.employeeCount),
      annualRevenue: nullAnnualRevenue
          ? null
          : (annualRevenue ?? $data.annualRevenue),
      paymentTermDays: paymentTermDays ?? $data.paymentTermDays,
      currency: currency ?? $data.currency,
      tags: tags ?? $data.tags,
      notes: nullNotes ? null : (notes ?? $data.notes),
      accountManagerId: nullAccountManagerId
          ? null
          : (accountManagerId ?? $data.accountManagerId),
      active: active ?? $data.active,
    );
  }

  static Client fromValues(Map<String, dynamic> data) {
    return Client(
      id: data['id'] ?? 0,
      customerNumber: data['customerNumber'],
      name: data['name'],
      legalName: data['legalName'],
      industry: data['industry'],
      tier: data['tier'] ?? ClientTier.bronze,
      website: data['website'],
      email: data['email'],
      phone: data['phone'],
      vatId: data['vatId'],
      addressStreet: data['addressStreet'],
      addressPostalCode: data['addressPostalCode'],
      addressCity: data['addressCity'],
      addressCountry: data['addressCountry'],
      location: data['location'],
      onboarded: data['onboarded'],
      employeeCount: data['employeeCount'],
      annualRevenue: data['annualRevenue'],
      paymentTermDays: data['paymentTermDays'] ?? 30,
      currency: data['currency'] ?? 'EUR',
      tags: data['tags']?.cast<String>().toList(growable: false) ?? const [],
      notes: data['notes'],
      accountManagerId: data['accountManagerId'],
      active: data['active'] ?? true,
    );
  }

  static Client fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Client, data.runtimeType, name);
    }
    return Client(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      customerNumber: $customerNumber.fromJson(
        data['customerNumber'],
        name: DataCodec.childName(name, 'customerNumber'),
      ),
      name: $name.fromJson(
        data['name'],
        name: DataCodec.childName(name, 'name'),
      ),
      legalName: $legalName.fromJson(
        data['legalName'],
        name: DataCodec.childName(name, 'legalName'),
      ),
      industry: $industry.fromJson(
        data['industry'],
        name: DataCodec.childName(name, 'industry'),
      ),
      tier: $tier.fromJson(
        data['tier'],
        name: DataCodec.childName(name, 'tier'),
      ),
      website: $website.fromJson(
        data['website'],
        name: DataCodec.childName(name, 'website'),
      ),
      email: $email.fromJson(
        data['email'],
        name: DataCodec.childName(name, 'email'),
      ),
      phone: $phone.fromJson(
        data['phone'],
        name: DataCodec.childName(name, 'phone'),
      ),
      vatId: $vatId.fromJson(
        data['vatId'],
        name: DataCodec.childName(name, 'vatId'),
      ),
      addressStreet: $addressStreet.fromJson(
        data['addressStreet'],
        name: DataCodec.childName(name, 'addressStreet'),
      ),
      addressPostalCode: $addressPostalCode.fromJson(
        data['addressPostalCode'],
        name: DataCodec.childName(name, 'addressPostalCode'),
      ),
      addressCity: $addressCity.fromJson(
        data['addressCity'],
        name: DataCodec.childName(name, 'addressCity'),
      ),
      addressCountry: $addressCountry.fromJson(
        data['addressCountry'],
        name: DataCodec.childName(name, 'addressCountry'),
      ),
      location: $location.fromJson(
        data['location'],
        name: DataCodec.childName(name, 'location'),
      ),
      onboarded: $onboarded.fromJson(
        data['onboarded'],
        name: DataCodec.childName(name, 'onboarded'),
      ),
      employeeCount: $employeeCount.fromJson(
        data['employeeCount'],
        name: DataCodec.childName(name, 'employeeCount'),
      ),
      annualRevenue: $annualRevenue.fromJson(
        data['annualRevenue'],
        name: DataCodec.childName(name, 'annualRevenue'),
      ),
      paymentTermDays: $paymentTermDays.fromJson(
        data['paymentTermDays'],
        name: DataCodec.childName(name, 'paymentTermDays'),
      ),
      currency: $currency.fromJson(
        data['currency'],
        name: DataCodec.childName(name, 'currency'),
      ),
      tags: $tags.fromJson(
        data['tags'],
        name: DataCodec.childName(name, 'tags'),
      ),
      notes: $notes.fromJson(
        data['notes'],
        name: DataCodec.childName(name, 'notes'),
      ),
      accountManagerId: $accountManagerId.fromJson(
        data['accountManagerId'],
        name: DataCodec.childName(name, 'accountManagerId'),
      ),
      active: $active.fromJson(
        data['active'],
        name: DataCodec.childName(name, 'active'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Client;
    return {
      'id': $id.toJson($$data.id),
      'customerNumber': $customerNumber.toJson($$data.customerNumber),
      'name': $name.toJson($$data.name),
      'legalName': $legalName.toJson($$data.legalName),
      'industry': $industry.toJson($$data.industry),
      'tier': $tier.toJson($$data.tier),
      'website': $website.toJson($$data.website),
      'email': $email.toJson($$data.email),
      'phone': $phone.toJson($$data.phone),
      'vatId': $vatId.toJson($$data.vatId),
      'addressStreet': $addressStreet.toJson($$data.addressStreet),
      'addressPostalCode': $addressPostalCode.toJson($$data.addressPostalCode),
      'addressCity': $addressCity.toJson($$data.addressCity),
      'addressCountry': $addressCountry.toJson($$data.addressCountry),
      'location': $location.toJson($$data.location),
      'onboarded': $onboarded.toJson($$data.onboarded),
      'employeeCount': $employeeCount.toJson($$data.employeeCount),
      'annualRevenue': $annualRevenue.toJson($$data.annualRevenue),
      'paymentTermDays': $paymentTermDays.toJson($$data.paymentTermDays),
      'currency': $currency.toJson($$data.currency),
      'tags': $tags.toJson($$data.tags),
      'notes': $notes.toJson($$data.notes),
      'accountManagerId': $accountManagerId.toJson($$data.accountManagerId),
      'active': $active.toJson($$data.active),
    }..removeWhere((k, v) => v == null);
  }
}
