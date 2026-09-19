// GENERATED CODE - DO NOT MODIFY BY HAND

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
    meta: [const Id(auto: true)],
  );

  static final $title = DataField<Contact, String?>(
    name: 'title',
    valueOf: (p) => p.title,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    meta: [const Meta(description: 'Academic title, e.g. Dr. or Prof.')],
    constraints: [const MaxLengthConstraint<String?>(length: 20)],
  );

  static final $firstName = DataField<Contact, String>(
    name: 'firstName',
    valueOf: (p) => p.firstName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [
      const MinLengthConstraint<String?>(length: 1),
      const MaxLengthConstraint<String?>(length: 50),
    ],
  );

  static final $lastName = DataField<Contact, String>(
    name: 'lastName',
    valueOf: (p) => p.lastName,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const ApertureField(isDisplayField: true)],
    constraints: [
      const MinLengthConstraint<String?>(length: 1),
      const MaxLengthConstraint<String?>(length: 50),
    ],
  );

  static final $position = DataField<Contact, String>(
    name: 'position',
    valueOf: (p) => p.position,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [
      const ApertureField(isDisplayField: true),
      const Meta(name: 'Job title'),
    ],
  );

  static final $email = DataField<Contact, String>(
    name: 'email',
    valueOf: (p) => p.email,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Meta(name: 'E-mail')],
    constraints: [
      const RegExpConstraint<String?>(
        expression: '^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+\$',
      ),
    ],
  );

  static final $phone = DataField<Contact, String>(
    name: 'phone',
    valueOf: (p) => p.phone,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
    constraints: [
      const RegExpConstraint<String?>(expression: '^\\+[\\d ]{7,20}\$'),
    ],
  );

  static final $mobile = DataField<Contact, String?>(
    name: 'mobile',
    valueOf: (p) => p.mobile,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
    constraints: [
      const RegExpConstraint<String?>(expression: '^\\+[\\d ]{7,20}\$'),
    ],
  );

  static final $clientId = DataField<Contact, int>(
    name: 'clientId',
    valueOf: (p) => p.clientId,
    fromJson: (value, {String? name}) => $$codec.decodeInt(value, name: name),
    toJson: (value) => $$codec.encodeInt(value),
    meta: [
      const Meta(name: 'Client'),
      const RelationId<Client>(),
    ],
  );

  static final $type = DataField<Contact, ContactType>(
    name: 'type',
    valueOf: (p) => p.type,
    fromJson: (value, {String? name}) => $$codec.decodeEnum(
      (value ?? ContactType.employee),
      ContactType.values,
      name: name,
    ),
    toJson: (value) => $$codec.encodeEnum(value),
    meta: [const Meta(name: 'Role')],
    constraints: [EnumConstraint(values: ContactType.values)],
  );

  static final $primaryContact = DataField<Contact, bool>(
    name: 'primaryContact',
    valueOf: (p) => p.primaryContact,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
    meta: [
      const Meta(
        name: 'Primary contact',
        description: 'Main point of contact for this client.',
      ),
    ],
  );

  static final $language = DataField<Contact, String>(
    name: 'language',
    valueOf: (p) => p.language,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString((value ?? 'en'), name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Meta(description: 'Preferred language (ISO 639-1).')],
    constraints: [const RegExpConstraint<String?>(expression: '^[a-z]{2}\$')],
  );

  static final $birthday = DataField<Contact, DateTime?>(
    name: 'birthday',
    valueOf: (p) => p.birthday,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
  );

  static final $lastContactedAt = DataField<Contact, DateTime?>(
    name: 'lastContactedAt',
    valueOf: (p) => p.lastContactedAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeDateTime, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeDateTime),
    meta: [const Meta(name: 'Last contacted')],
  );

  static final $newsletterOptIn = DataField<Contact, bool>(
    name: 'newsletterOptIn',
    valueOf: (p) => p.newsletterOptIn,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
    meta: [const Meta(name: 'Newsletter opt-in')],
  );

  static final DataBean<Contact> bean = DataBean<Contact>(
    name: 'Contact',
    fields: List<DataField<Contact, dynamic>>.unmodifiable([
      $id,
      $title,
      $firstName,
      $lastName,
      $position,
      $email,
      $phone,
      $mobile,
      $clientId,
      $type,
      $primaryContact,
      $language,
      $birthday,
      $lastContactedAt,
      $newsletterOptIn,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
    meta: [
      const Meta(namePlural: 'Contacts', icon: 57738),
      const ApertureMeta(titleTemplate: '{{ firstName }} {{ lastName }}'),
      const ApertureRelation<SupportTicket>(),
    ],
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Contact, dynamic>> get $$fields => bean.fields;
  Contact copyWith({
    int? id,
    String? title,
    bool nullTitle = false,
    String? firstName,
    String? lastName,
    String? position,
    String? email,
    String? phone,
    String? mobile,
    bool nullMobile = false,
    int? clientId,
    ContactType? type,
    bool? primaryContact,
    String? language,
    DateTime? birthday,
    bool nullBirthday = false,
    DateTime? lastContactedAt,
    bool nullLastContactedAt = false,
    bool? newsletterOptIn,
  }) {
    final $data = this as Contact;
    return Contact(
      id: id ?? $data.id,
      title: nullTitle ? null : (title ?? $data.title),
      firstName: firstName ?? $data.firstName,
      lastName: lastName ?? $data.lastName,
      position: position ?? $data.position,
      email: email ?? $data.email,
      phone: phone ?? $data.phone,
      mobile: nullMobile ? null : (mobile ?? $data.mobile),
      clientId: clientId ?? $data.clientId,
      type: type ?? $data.type,
      primaryContact: primaryContact ?? $data.primaryContact,
      language: language ?? $data.language,
      birthday: nullBirthday ? null : (birthday ?? $data.birthday),
      lastContactedAt: nullLastContactedAt
          ? null
          : (lastContactedAt ?? $data.lastContactedAt),
      newsletterOptIn: newsletterOptIn ?? $data.newsletterOptIn,
    );
  }

  static Contact fromValues(Map<String, dynamic> data) {
    return Contact(
      id: data['id'] ?? 0,
      title: data['title'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      position: data['position'],
      email: data['email'],
      phone: data['phone'],
      mobile: data['mobile'],
      clientId: data['clientId'],
      type: data['type'] ?? ContactType.employee,
      primaryContact: data['primaryContact'] ?? false,
      language: data['language'] ?? 'en',
      birthday: data['birthday'],
      lastContactedAt: data['lastContactedAt'],
      newsletterOptIn: data['newsletterOptIn'] ?? false,
    );
  }

  static Contact fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Contact, data.runtimeType, name);
    }
    return Contact(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      title: $title.fromJson(
        data['title'],
        name: DataCodec.childName(name, 'title'),
      ),
      firstName: $firstName.fromJson(
        data['firstName'],
        name: DataCodec.childName(name, 'firstName'),
      ),
      lastName: $lastName.fromJson(
        data['lastName'],
        name: DataCodec.childName(name, 'lastName'),
      ),
      position: $position.fromJson(
        data['position'],
        name: DataCodec.childName(name, 'position'),
      ),
      email: $email.fromJson(
        data['email'],
        name: DataCodec.childName(name, 'email'),
      ),
      phone: $phone.fromJson(
        data['phone'],
        name: DataCodec.childName(name, 'phone'),
      ),
      mobile: $mobile.fromJson(
        data['mobile'],
        name: DataCodec.childName(name, 'mobile'),
      ),
      clientId: $clientId.fromJson(
        data['clientId'],
        name: DataCodec.childName(name, 'clientId'),
      ),
      type: $type.fromJson(
        data['type'],
        name: DataCodec.childName(name, 'type'),
      ),
      primaryContact: $primaryContact.fromJson(
        data['primaryContact'],
        name: DataCodec.childName(name, 'primaryContact'),
      ),
      language: $language.fromJson(
        data['language'],
        name: DataCodec.childName(name, 'language'),
      ),
      birthday: $birthday.fromJson(
        data['birthday'],
        name: DataCodec.childName(name, 'birthday'),
      ),
      lastContactedAt: $lastContactedAt.fromJson(
        data['lastContactedAt'],
        name: DataCodec.childName(name, 'lastContactedAt'),
      ),
      newsletterOptIn: $newsletterOptIn.fromJson(
        data['newsletterOptIn'],
        name: DataCodec.childName(name, 'newsletterOptIn'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Contact;
    return {
      'id': $id.toJson($$data.id),
      'title': $title.toJson($$data.title),
      'firstName': $firstName.toJson($$data.firstName),
      'lastName': $lastName.toJson($$data.lastName),
      'position': $position.toJson($$data.position),
      'email': $email.toJson($$data.email),
      'phone': $phone.toJson($$data.phone),
      'mobile': $mobile.toJson($$data.mobile),
      'clientId': $clientId.toJson($$data.clientId),
      'type': $type.toJson($$data.type),
      'primaryContact': $primaryContact.toJson($$data.primaryContact),
      'language': $language.toJson($$data.language),
      'birthday': $birthday.toJson($$data.birthday),
      'lastContactedAt': $lastContactedAt.toJson($$data.lastContactedAt),
      'newsletterOptIn': $newsletterOptIn.toJson($$data.newsletterOptIn),
    }..removeWhere((k, v) => v == null);
  }
}
