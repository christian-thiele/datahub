// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aperture_bootstrap.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $ApertureBootstrap with DataObject<ApertureBootstrap> {
  const $ApertureBootstrap();
  static const $$codec = JsonDataCodec();
  static final $title = DataField<ApertureBootstrap, String>(
    name: 'title',
    valueOf: (p) => p.title,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $theme = DataField<ApertureBootstrap, ApertureTheme>(
    name: 'theme',
    valueOf: (p) => p.theme,
    dataBean: () => $ApertureTheme.bean,
    fromJson: (value, {String? name}) =>
        $ApertureTheme.bean.fromJson(value, name: name),
    toJson: (value) => value.toJson(),
  );

  static final $environment = DataField<ApertureBootstrap, Environment>(
    name: 'environment',
    valueOf: (p) => p.environment,
    fromJson: (value, {String? name}) =>
        $$codec.decodeEnum(value, Environment.values, name: name),
    toJson: (value) => $$codec.encodeEnum(value),
    constraints: [EnumConstraint(values: Environment.values)],
  );

  static final $baseUrl = DataField<ApertureBootstrap, String>(
    name: 'baseUrl',
    valueOf: (p) => p.baseUrl,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $oidcIssuer = DataField<ApertureBootstrap, String>(
    name: 'oidcIssuer',
    valueOf: (p) => p.oidcIssuer,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $oidcScopes = DataField<ApertureBootstrap, List<String>>(
    name: 'oidcScopes',
    valueOf: (p) => p.oidcScopes,
    fromJson: (value, {String? name}) =>
        $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeList<String>(value, $$codec.encodeString),
  );

  static final $oidcClientId = DataField<ApertureBootstrap, String?>(
    name: 'oidcClientId',
    valueOf: (p) => p.oidcClientId,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $oidcClientSecret = DataField<ApertureBootstrap, String?>(
    name: 'oidcClientSecret',
    valueOf: (p) => p.oidcClientSecret,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final DataBean<ApertureBootstrap> bean = DataBean<ApertureBootstrap>(
    name: 'ApertureBootstrap',
    fields: List<DataField<ApertureBootstrap, dynamic>>.unmodifiable([
      $title,
      $theme,
      $environment,
      $baseUrl,
      $oidcIssuer,
      $oidcScopes,
      $oidcClientId,
      $oidcClientSecret,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<ApertureBootstrap, dynamic>> get $$fields => bean.fields;
  ApertureBootstrap copyWith({
    String? title,
    ApertureTheme? theme,
    Environment? environment,
    String? baseUrl,
    String? oidcIssuer,
    List<String>? oidcScopes,
    String? oidcClientId,
    bool nullOidcClientId = false,
    String? oidcClientSecret,
    bool nullOidcClientSecret = false,
  }) {
    final $data = this as ApertureBootstrap;
    return ApertureBootstrap(
      title: title ?? $data.title,
      theme: theme ?? $data.theme,
      environment: environment ?? $data.environment,
      baseUrl: baseUrl ?? $data.baseUrl,
      oidcIssuer: oidcIssuer ?? $data.oidcIssuer,
      oidcScopes: oidcScopes ?? $data.oidcScopes,
      oidcClientId: nullOidcClientId
          ? null
          : (oidcClientId ?? $data.oidcClientId),
      oidcClientSecret: nullOidcClientSecret
          ? null
          : (oidcClientSecret ?? $data.oidcClientSecret),
    );
  }

  static ApertureBootstrap fromValues(Map<String, dynamic> data) {
    return ApertureBootstrap(
      title: data['title'],
      theme: data['theme'],
      environment: data['environment'],
      baseUrl: data['baseUrl'],
      oidcIssuer: data['oidcIssuer'],
      oidcScopes: data['oidcScopes']?.cast<String>().toList(growable: false),
      oidcClientId: data['oidcClientId'],
      oidcClientSecret: data['oidcClientSecret'],
    );
  }

  static ApertureBootstrap fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        ApertureBootstrap,
        data.runtimeType,
        name,
      );
    }
    return ApertureBootstrap(
      title: $title.fromJson(
        data['title'],
        name: DataCodec.childName(name, 'title'),
      ),
      theme: $theme.fromJson(
        data['theme'],
        name: DataCodec.childName(name, 'theme'),
      ),
      environment: $environment.fromJson(
        data['environment'],
        name: DataCodec.childName(name, 'environment'),
      ),
      baseUrl: $baseUrl.fromJson(
        data['baseUrl'],
        name: DataCodec.childName(name, 'baseUrl'),
      ),
      oidcIssuer: $oidcIssuer.fromJson(
        data['oidcIssuer'],
        name: DataCodec.childName(name, 'oidcIssuer'),
      ),
      oidcScopes: $oidcScopes.fromJson(
        data['oidcScopes'],
        name: DataCodec.childName(name, 'oidcScopes'),
      ),
      oidcClientId: $oidcClientId.fromJson(
        data['oidcClientId'],
        name: DataCodec.childName(name, 'oidcClientId'),
      ),
      oidcClientSecret: $oidcClientSecret.fromJson(
        data['oidcClientSecret'],
        name: DataCodec.childName(name, 'oidcClientSecret'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as ApertureBootstrap;
    return {
      'title': $title.toJson($$data.title),
      'theme': $theme.toJson($$data.theme),
      'environment': $environment.toJson($$data.environment),
      'baseUrl': $baseUrl.toJson($$data.baseUrl),
      'oidcIssuer': $oidcIssuer.toJson($$data.oidcIssuer),
      'oidcScopes': $oidcScopes.toJson($$data.oidcScopes),
      'oidcClientId': $oidcClientId.toJson($$data.oidcClientId),
      'oidcClientSecret': $oidcClientSecret.toJson($$data.oidcClientSecret),
    }..removeWhere((k, v) => v == null);
  }
}
