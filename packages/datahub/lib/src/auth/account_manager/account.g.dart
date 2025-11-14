// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $Account with DataObject<Account> {
  const $Account();
  static const $$codec = JsonDataCodec();
  static final $id = DataField<Account, String>(
    name: 'id',
    valueOf: (p) => p.id,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString((value ?? ''), name: name),
    toJson: (value) => $$codec.encodeString(value),
    meta: [const Id(auto: true)],
  );

  static final $email = DataField<Account, String>(
    name: 'email',
    valueOf: (p) => p.email,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $password = DataField<Account, String?>(
    name: 'password',
    valueOf: (p) => p.password,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $allowSignIn = DataField<Account, bool>(
    name: 'allowSignIn',
    valueOf: (p) => p.allowSignIn,
    fromJson: (value, {String? name}) => $$codec.decodeBool(value, name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $createdAt = DataField<Account, DateTime>(
    name: 'createdAt',
    valueOf: (p) => p.createdAt,
    fromJson: (value, {String? name}) =>
        $$codec.decodeDateTime(value, name: name),
    toJson: (value) => $$codec.encodeDateTime(value),
  );

  static final DataBean<Account> bean = DataBean<Account>(
    name: 'Account',
    fields: List<DataField<Account, dynamic>>.unmodifiable([
      $id,
      $email,
      $password,
      $allowSignIn,
      $createdAt,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<Account, dynamic>> get $$fields => bean.fields;
  Account copyWith({
    String? id,
    String? email,
    String? password,
    bool nullPassword = false,
    bool? allowSignIn,
    DateTime? createdAt,
  }) {
    final $data = this as Account;
    return Account(
      id: id ?? $data.id,
      email: email ?? $data.email,
      password: nullPassword ? null : (password ?? $data.password),
      allowSignIn: allowSignIn ?? $data.allowSignIn,
      createdAt: createdAt ?? $data.createdAt,
    );
  }

  static Account fromValues(Map<String, dynamic> data) {
    return Account(
      id: data['id'] ?? '',
      email: data['email'],
      password: data['password'],
      allowSignIn: data['allowSignIn'],
      createdAt: data['createdAt'],
    );
  }

  static Account fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(Account, data.runtimeType, name);
    }
    return Account(
      id: $id.fromJson(data['id'], name: DataCodec.childName(name, 'id')),
      email: $email.fromJson(
        data['email'],
        name: DataCodec.childName(name, 'email'),
      ),
      password: $password.fromJson(
        data['password'],
        name: DataCodec.childName(name, 'password'),
      ),
      allowSignIn: $allowSignIn.fromJson(
        data['allowSignIn'],
        name: DataCodec.childName(name, 'allowSignIn'),
      ),
      createdAt: $createdAt.fromJson(
        data['createdAt'],
        name: DataCodec.childName(name, 'createdAt'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as Account;
    return {
      'id': $id.toJson($$data.id),
      'email': $email.toJson($$data.email),
      'password': $password.toJson($$data.password),
      'allowSignIn': $allowSignIn.toJson($$data.allowSignIn),
      'createdAt': $createdAt.toJson($$data.createdAt),
    }..removeWhere((k, v) => v == null);
  }
}
