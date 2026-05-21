// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'oidc_configuration.dart';

// **************************************************************************
// Generator: DataBuilder
// **************************************************************************

abstract interface class $OidcConfiguration with DataObject<OidcConfiguration> {
  const $OidcConfiguration();
  static const $$codec = JsonDataCodec();
  static final $issuer = DataField<OidcConfiguration, String>(
    name: 'issuer',
    valueOf: (p) => p.issuer,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $jwksUri = DataField<OidcConfiguration, String>(
    name: 'jwksUri',
    valueOf: (p) => p.jwksUri,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $authorizationEndpoint = DataField<OidcConfiguration, String>(
    name: 'authorizationEndpoint',
    valueOf: (p) => p.authorizationEndpoint,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $tokenEndpoint = DataField<OidcConfiguration, String>(
    name: 'tokenEndpoint',
    valueOf: (p) => p.tokenEndpoint,
    fromJson: (value, {String? name}) =>
        $$codec.decodeString(value, name: name),
    toJson: (value) => $$codec.encodeString(value),
  );

  static final $userinfoEndpoint = DataField<OidcConfiguration, String?>(
    name: 'userinfoEndpoint',
    valueOf: (p) => p.userinfoEndpoint,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $introspectionEndpoint = DataField<OidcConfiguration, String?>(
    name: 'introspectionEndpoint',
    valueOf: (p) => p.introspectionEndpoint,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $registrationEndpoint = DataField<OidcConfiguration, String?>(
    name: 'registrationEndpoint',
    valueOf: (p) => p.registrationEndpoint,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $endSessionEndpoint = DataField<OidcConfiguration, String?>(
    name: 'endSessionEndpoint',
    valueOf: (p) => p.endSessionEndpoint,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $revocationEndpoint = DataField<OidcConfiguration, String?>(
    name: 'revocationEndpoint',
    valueOf: (p) => p.revocationEndpoint,
    fromJson: (value, {String? name}) =>
        $$codec.decodeNullable(value, $$codec.decodeString, name: name),
    toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
  );

  static final $deviceAuthorizationEndpoint =
      DataField<OidcConfiguration, String?>(
        name: 'deviceAuthorizationEndpoint',
        valueOf: (p) => p.deviceAuthorizationEndpoint,
        fromJson: (value, {String? name}) =>
            $$codec.decodeNullable(value, $$codec.decodeString, name: name),
        toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
      );

  static final $backchannelAuthenticationEndpoint =
      DataField<OidcConfiguration, String?>(
        name: 'backchannelAuthenticationEndpoint',
        valueOf: (p) => p.backchannelAuthenticationEndpoint,
        fromJson: (value, {String? name}) =>
            $$codec.decodeNullable(value, $$codec.decodeString, name: name),
        toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
      );

  static final $pushedAuthorizationRequestEndpoint =
      DataField<OidcConfiguration, String?>(
        name: 'pushedAuthorizationRequestEndpoint',
        valueOf: (p) => p.pushedAuthorizationRequestEndpoint,
        fromJson: (value, {String? name}) =>
            $$codec.decodeNullable(value, $$codec.decodeString, name: name),
        toJson: (value) => $$codec.encodeNullable(value, $$codec.encodeString),
      );

  static final $claimsParameterSupported = DataField<OidcConfiguration, bool>(
    name: 'claimsParameterSupported',
    valueOf: (p) => p.claimsParameterSupported,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $requestParameterSupported = DataField<OidcConfiguration, bool>(
    name: 'requestParameterSupported',
    valueOf: (p) => p.requestParameterSupported,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $requestUriParameterSupported =
      DataField<OidcConfiguration, bool>(
        name: 'requestUriParameterSupported',
        valueOf: (p) => p.requestUriParameterSupported,
        fromJson: (value, {String? name}) =>
            $$codec.decodeBool((value ?? false), name: name),
        toJson: (value) => $$codec.encodeBool(value),
      );

  static final $requireRequestUriRegistration =
      DataField<OidcConfiguration, bool>(
        name: 'requireRequestUriRegistration',
        valueOf: (p) => p.requireRequestUriRegistration,
        fromJson: (value, {String? name}) =>
            $$codec.decodeBool((value ?? false), name: name),
        toJson: (value) => $$codec.encodeBool(value),
      );

  static final $tlsClientCertificateBoundAccessTokens =
      DataField<OidcConfiguration, bool>(
        name: 'tlsClientCertificateBoundAccessTokens',
        valueOf: (p) => p.tlsClientCertificateBoundAccessTokens,
        fromJson: (value, {String? name}) =>
            $$codec.decodeBool((value ?? false), name: name),
        toJson: (value) => $$codec.encodeBool(value),
      );

  static final $frontchannelLogoutSupported =
      DataField<OidcConfiguration, bool>(
        name: 'frontchannelLogoutSupported',
        valueOf: (p) => p.frontchannelLogoutSupported,
        fromJson: (value, {String? name}) =>
            $$codec.decodeBool((value ?? false), name: name),
        toJson: (value) => $$codec.encodeBool(value),
      );

  static final $frontchannelLogoutSessionSupported =
      DataField<OidcConfiguration, bool>(
        name: 'frontchannelLogoutSessionSupported',
        valueOf: (p) => p.frontchannelLogoutSessionSupported,
        fromJson: (value, {String? name}) =>
            $$codec.decodeBool((value ?? false), name: name),
        toJson: (value) => $$codec.encodeBool(value),
      );

  static final $backchannelLogoutSupported = DataField<OidcConfiguration, bool>(
    name: 'backchannelLogoutSupported',
    valueOf: (p) => p.backchannelLogoutSupported,
    fromJson: (value, {String? name}) =>
        $$codec.decodeBool((value ?? false), name: name),
    toJson: (value) => $$codec.encodeBool(value),
  );

  static final $backchannelLogoutSessionSupported =
      DataField<OidcConfiguration, bool>(
        name: 'backchannelLogoutSessionSupported',
        valueOf: (p) => p.backchannelLogoutSessionSupported,
        fromJson: (value, {String? name}) =>
            $$codec.decodeBool((value ?? false), name: name),
        toJson: (value) => $$codec.encodeBool(value),
      );

  static final $authorizationResponseIssParameterSupported =
      DataField<OidcConfiguration, bool>(
        name: 'authorizationResponseIssParameterSupported',
        valueOf: (p) => p.authorizationResponseIssParameterSupported,
        fromJson: (value, {String? name}) =>
            $$codec.decodeBool((value ?? false), name: name),
        toJson: (value) => $$codec.encodeBool(value),
      );

  static final $requirePushedAuthorizationRequests =
      DataField<OidcConfiguration, bool>(
        name: 'requirePushedAuthorizationRequests',
        valueOf: (p) => p.requirePushedAuthorizationRequests,
        fromJson: (value, {String? name}) =>
            $$codec.decodeBool((value ?? false), name: name),
        toJson: (value) => $$codec.encodeBool(value),
      );

  static final $grantTypesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'grantTypesSupported',
        valueOf: (p) => p.grantTypesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $acrValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'acrValuesSupported',
        valueOf: (p) => p.acrValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $responseTypesSupported =
      DataField<OidcConfiguration, List<String>>(
        name: 'responseTypesSupported',
        valueOf: (p) => p.responseTypesSupported,
        fromJson: (value, {String? name}) =>
            $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
        toJson: (value) =>
            $$codec.encodeList<String>(value, $$codec.encodeString),
      );

  static final $subjectTypesSupported =
      DataField<OidcConfiguration, List<String>>(
        name: 'subjectTypesSupported',
        valueOf: (p) => p.subjectTypesSupported,
        fromJson: (value, {String? name}) =>
            $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
        toJson: (value) =>
            $$codec.encodeList<String>(value, $$codec.encodeString),
      );

  static final $idTokenSigningAlgValuesSupported =
      DataField<OidcConfiguration, List<String>>(
        name: 'idTokenSigningAlgValuesSupported',
        valueOf: (p) => p.idTokenSigningAlgValuesSupported,
        fromJson: (value, {String? name}) =>
            $$codec.decodeList<String>(value, $$codec.decodeString, name: name),
        toJson: (value) =>
            $$codec.encodeList<String>(value, $$codec.encodeString),
      );

  static final $idTokenEncryptionAlgValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'idTokenEncryptionAlgValuesSupported',
        valueOf: (p) => p.idTokenEncryptionAlgValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $idTokenEncryptionEncValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'idTokenEncryptionEncValuesSupported',
        valueOf: (p) => p.idTokenEncryptionEncValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $userinfoSigningAlgValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'userinfoSigningAlgValuesSupported',
        valueOf: (p) => p.userinfoSigningAlgValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $userinfoEncryptionAlgValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'userinfoEncryptionAlgValuesSupported',
        valueOf: (p) => p.userinfoEncryptionAlgValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $userinfoEncryptionEncValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'userinfoEncryptionEncValuesSupported',
        valueOf: (p) => p.userinfoEncryptionEncValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $requestObjectSigningAlgValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'requestObjectSigningAlgValuesSupported',
        valueOf: (p) => p.requestObjectSigningAlgValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $requestObjectEncryptionAlgValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'requestObjectEncryptionAlgValuesSupported',
        valueOf: (p) => p.requestObjectEncryptionAlgValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $requestObjectEncryptionEncValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'requestObjectEncryptionEncValuesSupported',
        valueOf: (p) => p.requestObjectEncryptionEncValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $responseModesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'responseModesSupported',
        valueOf: (p) => p.responseModesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $tokenEndpointAuthMethodsSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'tokenEndpointAuthMethodsSupported',
        valueOf: (p) => p.tokenEndpointAuthMethodsSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $tokenEndpointAuthSigningAlgValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'tokenEndpointAuthSigningAlgValuesSupported',
        valueOf: (p) => p.tokenEndpointAuthSigningAlgValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $introspectionEndpointAuthMethodsSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'introspectionEndpointAuthMethodsSupported',
        valueOf: (p) => p.introspectionEndpointAuthMethodsSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $introspectionEndpointAuthSigningAlgValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'introspectionEndpointAuthSigningAlgValuesSupported',
        valueOf: (p) => p.introspectionEndpointAuthSigningAlgValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $authorizationSigningAlgValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'authorizationSigningAlgValuesSupported',
        valueOf: (p) => p.authorizationSigningAlgValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $authorizationEncryptionAlgValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'authorizationEncryptionAlgValuesSupported',
        valueOf: (p) => p.authorizationEncryptionAlgValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $authorizationEncryptionEncValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'authorizationEncryptionEncValuesSupported',
        valueOf: (p) => p.authorizationEncryptionEncValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $claimsSupported = DataField<OidcConfiguration, List<String>?>(
    name: 'claimsSupported',
    valueOf: (p) => p.claimsSupported,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      (v, {String? name}) =>
          $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(
      value,
      (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
    ),
  );

  static final $claimTypesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'claimTypesSupported',
        valueOf: (p) => p.claimTypesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $scopesSupported = DataField<OidcConfiguration, List<String>?>(
    name: 'scopesSupported',
    valueOf: (p) => p.scopesSupported,
    fromJson: (value, {String? name}) => $$codec.decodeNullable(
      value,
      (v, {String? name}) =>
          $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
      name: name,
    ),
    toJson: (value) => $$codec.encodeNullable(
      value,
      (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
    ),
  );

  static final $codeChallengeMethodsSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'codeChallengeMethodsSupported',
        valueOf: (p) => p.codeChallengeMethodsSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $revocationEndpointAuthMethodsSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'revocationEndpointAuthMethodsSupported',
        valueOf: (p) => p.revocationEndpointAuthMethodsSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $revocationEndpointAuthSigningAlgValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'revocationEndpointAuthSigningAlgValuesSupported',
        valueOf: (p) => p.revocationEndpointAuthSigningAlgValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $backchannelTokenDeliveryModesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'backchannelTokenDeliveryModesSupported',
        valueOf: (p) => p.backchannelTokenDeliveryModesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $backchannelAuthenticationRequestSigningAlgValuesSupported =
      DataField<OidcConfiguration, List<String>?>(
        name: 'backchannelAuthenticationRequestSigningAlgValuesSupported',
        valueOf: (p) =>
            p.backchannelAuthenticationRequestSigningAlgValuesSupported,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeList<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeList<String>(v, $$codec.encodeString),
        ),
      );

  static final $mtlsEndpointAliases =
      DataField<OidcConfiguration, Map<String, String>?>(
        name: 'mtlsEndpointAliases',
        valueOf: (p) => p.mtlsEndpointAliases,
        fromJson: (value, {String? name}) => $$codec.decodeNullable(
          value,
          (v, {String? name}) =>
              $$codec.decodeMap<String>(v, $$codec.decodeString, name: name),
          name: name,
        ),
        toJson: (value) => $$codec.encodeNullable(
          value,
          (v) => $$codec.encodeMap<String>(v, $$codec.encodeString),
        ),
      );

  static final DataBean<OidcConfiguration> bean = DataBean<OidcConfiguration>(
    name: 'OidcConfiguration',
    fields: List<DataField<OidcConfiguration, dynamic>>.unmodifiable([
      $issuer,
      $jwksUri,
      $authorizationEndpoint,
      $tokenEndpoint,
      $userinfoEndpoint,
      $introspectionEndpoint,
      $registrationEndpoint,
      $endSessionEndpoint,
      $revocationEndpoint,
      $deviceAuthorizationEndpoint,
      $backchannelAuthenticationEndpoint,
      $pushedAuthorizationRequestEndpoint,
      $claimsParameterSupported,
      $requestParameterSupported,
      $requestUriParameterSupported,
      $requireRequestUriRegistration,
      $tlsClientCertificateBoundAccessTokens,
      $frontchannelLogoutSupported,
      $frontchannelLogoutSessionSupported,
      $backchannelLogoutSupported,
      $backchannelLogoutSessionSupported,
      $authorizationResponseIssParameterSupported,
      $requirePushedAuthorizationRequests,
      $grantTypesSupported,
      $acrValuesSupported,
      $responseTypesSupported,
      $subjectTypesSupported,
      $idTokenSigningAlgValuesSupported,
      $idTokenEncryptionAlgValuesSupported,
      $idTokenEncryptionEncValuesSupported,
      $userinfoSigningAlgValuesSupported,
      $userinfoEncryptionAlgValuesSupported,
      $userinfoEncryptionEncValuesSupported,
      $requestObjectSigningAlgValuesSupported,
      $requestObjectEncryptionAlgValuesSupported,
      $requestObjectEncryptionEncValuesSupported,
      $responseModesSupported,
      $tokenEndpointAuthMethodsSupported,
      $tokenEndpointAuthSigningAlgValuesSupported,
      $introspectionEndpointAuthMethodsSupported,
      $introspectionEndpointAuthSigningAlgValuesSupported,
      $authorizationSigningAlgValuesSupported,
      $authorizationEncryptionAlgValuesSupported,
      $authorizationEncryptionEncValuesSupported,
      $claimsSupported,
      $claimTypesSupported,
      $scopesSupported,
      $codeChallengeMethodsSupported,
      $revocationEndpointAuthMethodsSupported,
      $revocationEndpointAuthSigningAlgValuesSupported,
      $backchannelTokenDeliveryModesSupported,
      $backchannelAuthenticationRequestSigningAlgValuesSupported,
      $mtlsEndpointAliases,
    ]),
    fromValues: fromValues,
    fromJson: fromJson,
  );

  @override
  String get $$name => bean.name;
  @override
  List<DataField<OidcConfiguration, dynamic>> get $$fields => bean.fields;
  OidcConfiguration copyWith({
    String? issuer,
    String? jwksUri,
    String? authorizationEndpoint,
    String? tokenEndpoint,
    String? userinfoEndpoint,
    bool nullUserinfoEndpoint = false,
    String? introspectionEndpoint,
    bool nullIntrospectionEndpoint = false,
    String? registrationEndpoint,
    bool nullRegistrationEndpoint = false,
    String? endSessionEndpoint,
    bool nullEndSessionEndpoint = false,
    String? revocationEndpoint,
    bool nullRevocationEndpoint = false,
    String? deviceAuthorizationEndpoint,
    bool nullDeviceAuthorizationEndpoint = false,
    String? backchannelAuthenticationEndpoint,
    bool nullBackchannelAuthenticationEndpoint = false,
    String? pushedAuthorizationRequestEndpoint,
    bool nullPushedAuthorizationRequestEndpoint = false,
    bool? claimsParameterSupported,
    bool? requestParameterSupported,
    bool? requestUriParameterSupported,
    bool? requireRequestUriRegistration,
    bool? tlsClientCertificateBoundAccessTokens,
    bool? frontchannelLogoutSupported,
    bool? frontchannelLogoutSessionSupported,
    bool? backchannelLogoutSupported,
    bool? backchannelLogoutSessionSupported,
    bool? authorizationResponseIssParameterSupported,
    bool? requirePushedAuthorizationRequests,
    List<String>? grantTypesSupported,
    bool nullGrantTypesSupported = false,
    List<String>? acrValuesSupported,
    bool nullAcrValuesSupported = false,
    List<String>? responseTypesSupported,
    List<String>? subjectTypesSupported,
    List<String>? idTokenSigningAlgValuesSupported,
    List<String>? idTokenEncryptionAlgValuesSupported,
    bool nullIdTokenEncryptionAlgValuesSupported = false,
    List<String>? idTokenEncryptionEncValuesSupported,
    bool nullIdTokenEncryptionEncValuesSupported = false,
    List<String>? userinfoSigningAlgValuesSupported,
    bool nullUserinfoSigningAlgValuesSupported = false,
    List<String>? userinfoEncryptionAlgValuesSupported,
    bool nullUserinfoEncryptionAlgValuesSupported = false,
    List<String>? userinfoEncryptionEncValuesSupported,
    bool nullUserinfoEncryptionEncValuesSupported = false,
    List<String>? requestObjectSigningAlgValuesSupported,
    bool nullRequestObjectSigningAlgValuesSupported = false,
    List<String>? requestObjectEncryptionAlgValuesSupported,
    bool nullRequestObjectEncryptionAlgValuesSupported = false,
    List<String>? requestObjectEncryptionEncValuesSupported,
    bool nullRequestObjectEncryptionEncValuesSupported = false,
    List<String>? responseModesSupported,
    bool nullResponseModesSupported = false,
    List<String>? tokenEndpointAuthMethodsSupported,
    bool nullTokenEndpointAuthMethodsSupported = false,
    List<String>? tokenEndpointAuthSigningAlgValuesSupported,
    bool nullTokenEndpointAuthSigningAlgValuesSupported = false,
    List<String>? introspectionEndpointAuthMethodsSupported,
    bool nullIntrospectionEndpointAuthMethodsSupported = false,
    List<String>? introspectionEndpointAuthSigningAlgValuesSupported,
    bool nullIntrospectionEndpointAuthSigningAlgValuesSupported = false,
    List<String>? authorizationSigningAlgValuesSupported,
    bool nullAuthorizationSigningAlgValuesSupported = false,
    List<String>? authorizationEncryptionAlgValuesSupported,
    bool nullAuthorizationEncryptionAlgValuesSupported = false,
    List<String>? authorizationEncryptionEncValuesSupported,
    bool nullAuthorizationEncryptionEncValuesSupported = false,
    List<String>? claimsSupported,
    bool nullClaimsSupported = false,
    List<String>? claimTypesSupported,
    bool nullClaimTypesSupported = false,
    List<String>? scopesSupported,
    bool nullScopesSupported = false,
    List<String>? codeChallengeMethodsSupported,
    bool nullCodeChallengeMethodsSupported = false,
    List<String>? revocationEndpointAuthMethodsSupported,
    bool nullRevocationEndpointAuthMethodsSupported = false,
    List<String>? revocationEndpointAuthSigningAlgValuesSupported,
    bool nullRevocationEndpointAuthSigningAlgValuesSupported = false,
    List<String>? backchannelTokenDeliveryModesSupported,
    bool nullBackchannelTokenDeliveryModesSupported = false,
    List<String>? backchannelAuthenticationRequestSigningAlgValuesSupported,
    bool nullBackchannelAuthenticationRequestSigningAlgValuesSupported = false,
    Map<String, String>? mtlsEndpointAliases,
    bool nullMtlsEndpointAliases = false,
  }) {
    final $data = this as OidcConfiguration;
    return OidcConfiguration(
      issuer: issuer ?? $data.issuer,
      jwksUri: jwksUri ?? $data.jwksUri,
      authorizationEndpoint:
          authorizationEndpoint ?? $data.authorizationEndpoint,
      tokenEndpoint: tokenEndpoint ?? $data.tokenEndpoint,
      userinfoEndpoint: nullUserinfoEndpoint
          ? null
          : (userinfoEndpoint ?? $data.userinfoEndpoint),
      introspectionEndpoint: nullIntrospectionEndpoint
          ? null
          : (introspectionEndpoint ?? $data.introspectionEndpoint),
      registrationEndpoint: nullRegistrationEndpoint
          ? null
          : (registrationEndpoint ?? $data.registrationEndpoint),
      endSessionEndpoint: nullEndSessionEndpoint
          ? null
          : (endSessionEndpoint ?? $data.endSessionEndpoint),
      revocationEndpoint: nullRevocationEndpoint
          ? null
          : (revocationEndpoint ?? $data.revocationEndpoint),
      deviceAuthorizationEndpoint: nullDeviceAuthorizationEndpoint
          ? null
          : (deviceAuthorizationEndpoint ?? $data.deviceAuthorizationEndpoint),
      backchannelAuthenticationEndpoint: nullBackchannelAuthenticationEndpoint
          ? null
          : (backchannelAuthenticationEndpoint ??
                $data.backchannelAuthenticationEndpoint),
      pushedAuthorizationRequestEndpoint: nullPushedAuthorizationRequestEndpoint
          ? null
          : (pushedAuthorizationRequestEndpoint ??
                $data.pushedAuthorizationRequestEndpoint),
      claimsParameterSupported:
          claimsParameterSupported ?? $data.claimsParameterSupported,
      requestParameterSupported:
          requestParameterSupported ?? $data.requestParameterSupported,
      requestUriParameterSupported:
          requestUriParameterSupported ?? $data.requestUriParameterSupported,
      requireRequestUriRegistration:
          requireRequestUriRegistration ?? $data.requireRequestUriRegistration,
      tlsClientCertificateBoundAccessTokens:
          tlsClientCertificateBoundAccessTokens ??
          $data.tlsClientCertificateBoundAccessTokens,
      frontchannelLogoutSupported:
          frontchannelLogoutSupported ?? $data.frontchannelLogoutSupported,
      frontchannelLogoutSessionSupported:
          frontchannelLogoutSessionSupported ??
          $data.frontchannelLogoutSessionSupported,
      backchannelLogoutSupported:
          backchannelLogoutSupported ?? $data.backchannelLogoutSupported,
      backchannelLogoutSessionSupported:
          backchannelLogoutSessionSupported ??
          $data.backchannelLogoutSessionSupported,
      authorizationResponseIssParameterSupported:
          authorizationResponseIssParameterSupported ??
          $data.authorizationResponseIssParameterSupported,
      requirePushedAuthorizationRequests:
          requirePushedAuthorizationRequests ??
          $data.requirePushedAuthorizationRequests,
      grantTypesSupported: nullGrantTypesSupported
          ? null
          : (grantTypesSupported ?? $data.grantTypesSupported),
      acrValuesSupported: nullAcrValuesSupported
          ? null
          : (acrValuesSupported ?? $data.acrValuesSupported),
      responseTypesSupported:
          responseTypesSupported ?? $data.responseTypesSupported,
      subjectTypesSupported:
          subjectTypesSupported ?? $data.subjectTypesSupported,
      idTokenSigningAlgValuesSupported:
          idTokenSigningAlgValuesSupported ??
          $data.idTokenSigningAlgValuesSupported,
      idTokenEncryptionAlgValuesSupported:
          nullIdTokenEncryptionAlgValuesSupported
          ? null
          : (idTokenEncryptionAlgValuesSupported ??
                $data.idTokenEncryptionAlgValuesSupported),
      idTokenEncryptionEncValuesSupported:
          nullIdTokenEncryptionEncValuesSupported
          ? null
          : (idTokenEncryptionEncValuesSupported ??
                $data.idTokenEncryptionEncValuesSupported),
      userinfoSigningAlgValuesSupported: nullUserinfoSigningAlgValuesSupported
          ? null
          : (userinfoSigningAlgValuesSupported ??
                $data.userinfoSigningAlgValuesSupported),
      userinfoEncryptionAlgValuesSupported:
          nullUserinfoEncryptionAlgValuesSupported
          ? null
          : (userinfoEncryptionAlgValuesSupported ??
                $data.userinfoEncryptionAlgValuesSupported),
      userinfoEncryptionEncValuesSupported:
          nullUserinfoEncryptionEncValuesSupported
          ? null
          : (userinfoEncryptionEncValuesSupported ??
                $data.userinfoEncryptionEncValuesSupported),
      requestObjectSigningAlgValuesSupported:
          nullRequestObjectSigningAlgValuesSupported
          ? null
          : (requestObjectSigningAlgValuesSupported ??
                $data.requestObjectSigningAlgValuesSupported),
      requestObjectEncryptionAlgValuesSupported:
          nullRequestObjectEncryptionAlgValuesSupported
          ? null
          : (requestObjectEncryptionAlgValuesSupported ??
                $data.requestObjectEncryptionAlgValuesSupported),
      requestObjectEncryptionEncValuesSupported:
          nullRequestObjectEncryptionEncValuesSupported
          ? null
          : (requestObjectEncryptionEncValuesSupported ??
                $data.requestObjectEncryptionEncValuesSupported),
      responseModesSupported: nullResponseModesSupported
          ? null
          : (responseModesSupported ?? $data.responseModesSupported),
      tokenEndpointAuthMethodsSupported: nullTokenEndpointAuthMethodsSupported
          ? null
          : (tokenEndpointAuthMethodsSupported ??
                $data.tokenEndpointAuthMethodsSupported),
      tokenEndpointAuthSigningAlgValuesSupported:
          nullTokenEndpointAuthSigningAlgValuesSupported
          ? null
          : (tokenEndpointAuthSigningAlgValuesSupported ??
                $data.tokenEndpointAuthSigningAlgValuesSupported),
      introspectionEndpointAuthMethodsSupported:
          nullIntrospectionEndpointAuthMethodsSupported
          ? null
          : (introspectionEndpointAuthMethodsSupported ??
                $data.introspectionEndpointAuthMethodsSupported),
      introspectionEndpointAuthSigningAlgValuesSupported:
          nullIntrospectionEndpointAuthSigningAlgValuesSupported
          ? null
          : (introspectionEndpointAuthSigningAlgValuesSupported ??
                $data.introspectionEndpointAuthSigningAlgValuesSupported),
      authorizationSigningAlgValuesSupported:
          nullAuthorizationSigningAlgValuesSupported
          ? null
          : (authorizationSigningAlgValuesSupported ??
                $data.authorizationSigningAlgValuesSupported),
      authorizationEncryptionAlgValuesSupported:
          nullAuthorizationEncryptionAlgValuesSupported
          ? null
          : (authorizationEncryptionAlgValuesSupported ??
                $data.authorizationEncryptionAlgValuesSupported),
      authorizationEncryptionEncValuesSupported:
          nullAuthorizationEncryptionEncValuesSupported
          ? null
          : (authorizationEncryptionEncValuesSupported ??
                $data.authorizationEncryptionEncValuesSupported),
      claimsSupported: nullClaimsSupported
          ? null
          : (claimsSupported ?? $data.claimsSupported),
      claimTypesSupported: nullClaimTypesSupported
          ? null
          : (claimTypesSupported ?? $data.claimTypesSupported),
      scopesSupported: nullScopesSupported
          ? null
          : (scopesSupported ?? $data.scopesSupported),
      codeChallengeMethodsSupported: nullCodeChallengeMethodsSupported
          ? null
          : (codeChallengeMethodsSupported ??
                $data.codeChallengeMethodsSupported),
      revocationEndpointAuthMethodsSupported:
          nullRevocationEndpointAuthMethodsSupported
          ? null
          : (revocationEndpointAuthMethodsSupported ??
                $data.revocationEndpointAuthMethodsSupported),
      revocationEndpointAuthSigningAlgValuesSupported:
          nullRevocationEndpointAuthSigningAlgValuesSupported
          ? null
          : (revocationEndpointAuthSigningAlgValuesSupported ??
                $data.revocationEndpointAuthSigningAlgValuesSupported),
      backchannelTokenDeliveryModesSupported:
          nullBackchannelTokenDeliveryModesSupported
          ? null
          : (backchannelTokenDeliveryModesSupported ??
                $data.backchannelTokenDeliveryModesSupported),
      backchannelAuthenticationRequestSigningAlgValuesSupported:
          nullBackchannelAuthenticationRequestSigningAlgValuesSupported
          ? null
          : (backchannelAuthenticationRequestSigningAlgValuesSupported ??
                $data
                    .backchannelAuthenticationRequestSigningAlgValuesSupported),
      mtlsEndpointAliases: nullMtlsEndpointAliases
          ? null
          : (mtlsEndpointAliases ?? $data.mtlsEndpointAliases),
    );
  }

  static OidcConfiguration fromValues(Map<String, dynamic> data) {
    return OidcConfiguration(
      issuer: data['issuer'],
      jwksUri: data['jwksUri'],
      authorizationEndpoint: data['authorizationEndpoint'],
      tokenEndpoint: data['tokenEndpoint'],
      userinfoEndpoint: data['userinfoEndpoint'],
      introspectionEndpoint: data['introspectionEndpoint'],
      registrationEndpoint: data['registrationEndpoint'],
      endSessionEndpoint: data['endSessionEndpoint'],
      revocationEndpoint: data['revocationEndpoint'],
      deviceAuthorizationEndpoint: data['deviceAuthorizationEndpoint'],
      backchannelAuthenticationEndpoint:
          data['backchannelAuthenticationEndpoint'],
      pushedAuthorizationRequestEndpoint:
          data['pushedAuthorizationRequestEndpoint'],
      claimsParameterSupported: data['claimsParameterSupported'] ?? false,
      requestParameterSupported: data['requestParameterSupported'] ?? false,
      requestUriParameterSupported:
          data['requestUriParameterSupported'] ?? false,
      requireRequestUriRegistration:
          data['requireRequestUriRegistration'] ?? false,
      tlsClientCertificateBoundAccessTokens:
          data['tlsClientCertificateBoundAccessTokens'] ?? false,
      frontchannelLogoutSupported: data['frontchannelLogoutSupported'] ?? false,
      frontchannelLogoutSessionSupported:
          data['frontchannelLogoutSessionSupported'] ?? false,
      backchannelLogoutSupported: data['backchannelLogoutSupported'] ?? false,
      backchannelLogoutSessionSupported:
          data['backchannelLogoutSessionSupported'] ?? false,
      authorizationResponseIssParameterSupported:
          data['authorizationResponseIssParameterSupported'] ?? false,
      requirePushedAuthorizationRequests:
          data['requirePushedAuthorizationRequests'] ?? false,
      grantTypesSupported: data['grantTypesSupported']?.cast<String>().toList(
        growable: false,
      ),
      acrValuesSupported: data['acrValuesSupported']?.cast<String>().toList(
        growable: false,
      ),
      responseTypesSupported: data['responseTypesSupported']
          ?.cast<String>()
          .toList(growable: false),
      subjectTypesSupported: data['subjectTypesSupported']
          ?.cast<String>()
          .toList(growable: false),
      idTokenSigningAlgValuesSupported: data['idTokenSigningAlgValuesSupported']
          ?.cast<String>()
          .toList(growable: false),
      idTokenEncryptionAlgValuesSupported:
          data['idTokenEncryptionAlgValuesSupported']?.cast<String>().toList(
            growable: false,
          ),
      idTokenEncryptionEncValuesSupported:
          data['idTokenEncryptionEncValuesSupported']?.cast<String>().toList(
            growable: false,
          ),
      userinfoSigningAlgValuesSupported:
          data['userinfoSigningAlgValuesSupported']?.cast<String>().toList(
            growable: false,
          ),
      userinfoEncryptionAlgValuesSupported:
          data['userinfoEncryptionAlgValuesSupported']?.cast<String>().toList(
            growable: false,
          ),
      userinfoEncryptionEncValuesSupported:
          data['userinfoEncryptionEncValuesSupported']?.cast<String>().toList(
            growable: false,
          ),
      requestObjectSigningAlgValuesSupported:
          data['requestObjectSigningAlgValuesSupported']?.cast<String>().toList(
            growable: false,
          ),
      requestObjectEncryptionAlgValuesSupported:
          data['requestObjectEncryptionAlgValuesSupported']
              ?.cast<String>()
              .toList(growable: false),
      requestObjectEncryptionEncValuesSupported:
          data['requestObjectEncryptionEncValuesSupported']
              ?.cast<String>()
              .toList(growable: false),
      responseModesSupported: data['responseModesSupported']
          ?.cast<String>()
          .toList(growable: false),
      tokenEndpointAuthMethodsSupported:
          data['tokenEndpointAuthMethodsSupported']?.cast<String>().toList(
            growable: false,
          ),
      tokenEndpointAuthSigningAlgValuesSupported:
          data['tokenEndpointAuthSigningAlgValuesSupported']
              ?.cast<String>()
              .toList(growable: false),
      introspectionEndpointAuthMethodsSupported:
          data['introspectionEndpointAuthMethodsSupported']
              ?.cast<String>()
              .toList(growable: false),
      introspectionEndpointAuthSigningAlgValuesSupported:
          data['introspectionEndpointAuthSigningAlgValuesSupported']
              ?.cast<String>()
              .toList(growable: false),
      authorizationSigningAlgValuesSupported:
          data['authorizationSigningAlgValuesSupported']?.cast<String>().toList(
            growable: false,
          ),
      authorizationEncryptionAlgValuesSupported:
          data['authorizationEncryptionAlgValuesSupported']
              ?.cast<String>()
              .toList(growable: false),
      authorizationEncryptionEncValuesSupported:
          data['authorizationEncryptionEncValuesSupported']
              ?.cast<String>()
              .toList(growable: false),
      claimsSupported: data['claimsSupported']?.cast<String>().toList(
        growable: false,
      ),
      claimTypesSupported: data['claimTypesSupported']?.cast<String>().toList(
        growable: false,
      ),
      scopesSupported: data['scopesSupported']?.cast<String>().toList(
        growable: false,
      ),
      codeChallengeMethodsSupported: data['codeChallengeMethodsSupported']
          ?.cast<String>()
          .toList(growable: false),
      revocationEndpointAuthMethodsSupported:
          data['revocationEndpointAuthMethodsSupported']?.cast<String>().toList(
            growable: false,
          ),
      revocationEndpointAuthSigningAlgValuesSupported:
          data['revocationEndpointAuthSigningAlgValuesSupported']
              ?.cast<String>()
              .toList(growable: false),
      backchannelTokenDeliveryModesSupported:
          data['backchannelTokenDeliveryModesSupported']?.cast<String>().toList(
            growable: false,
          ),
      backchannelAuthenticationRequestSigningAlgValuesSupported:
          data['backchannelAuthenticationRequestSigningAlgValuesSupported']
              ?.cast<String>()
              .toList(growable: false),
      mtlsEndpointAliases: data['mtlsEndpointAliases'],
    );
  }

  static OidcConfiguration fromJson(dynamic data, {String? name}) {
    if (data is! Map<String, dynamic>) {
      throw CodecException.typeMismatch(
        OidcConfiguration,
        data.runtimeType,
        name,
      );
    }
    return OidcConfiguration(
      issuer: $issuer.fromJson(
        data['issuer'],
        name: DataCodec.childName(name, 'issuer'),
      ),
      jwksUri: $jwksUri.fromJson(
        data['jwks_uri'],
        name: DataCodec.childName(name, 'jwks_uri'),
      ),
      authorizationEndpoint: $authorizationEndpoint.fromJson(
        data['authorization_endpoint'],
        name: DataCodec.childName(name, 'authorization_endpoint'),
      ),
      tokenEndpoint: $tokenEndpoint.fromJson(
        data['token_endpoint'],
        name: DataCodec.childName(name, 'token_endpoint'),
      ),
      userinfoEndpoint: $userinfoEndpoint.fromJson(
        data['userinfo_endpoint'],
        name: DataCodec.childName(name, 'userinfo_endpoint'),
      ),
      introspectionEndpoint: $introspectionEndpoint.fromJson(
        data['introspection_endpoint'],
        name: DataCodec.childName(name, 'introspection_endpoint'),
      ),
      registrationEndpoint: $registrationEndpoint.fromJson(
        data['registration_endpoint'],
        name: DataCodec.childName(name, 'registration_endpoint'),
      ),
      endSessionEndpoint: $endSessionEndpoint.fromJson(
        data['end_session_endpoint'],
        name: DataCodec.childName(name, 'end_session_endpoint'),
      ),
      revocationEndpoint: $revocationEndpoint.fromJson(
        data['revocation_endpoint'],
        name: DataCodec.childName(name, 'revocation_endpoint'),
      ),
      deviceAuthorizationEndpoint: $deviceAuthorizationEndpoint.fromJson(
        data['device_authorization_endpoint'],
        name: DataCodec.childName(name, 'device_authorization_endpoint'),
      ),
      backchannelAuthenticationEndpoint: $backchannelAuthenticationEndpoint
          .fromJson(
            data['backchannel_authentication_endpoint'],
            name: DataCodec.childName(
              name,
              'backchannel_authentication_endpoint',
            ),
          ),
      pushedAuthorizationRequestEndpoint: $pushedAuthorizationRequestEndpoint
          .fromJson(
            data['pushed_authorization_request_endpoint'],
            name: DataCodec.childName(
              name,
              'pushed_authorization_request_endpoint',
            ),
          ),
      claimsParameterSupported: $claimsParameterSupported.fromJson(
        data['claims_parameter_supported'],
        name: DataCodec.childName(name, 'claims_parameter_supported'),
      ),
      requestParameterSupported: $requestParameterSupported.fromJson(
        data['request_parameter_supported'],
        name: DataCodec.childName(name, 'request_parameter_supported'),
      ),
      requestUriParameterSupported: $requestUriParameterSupported.fromJson(
        data['request_uri_parameter_supported'],
        name: DataCodec.childName(name, 'request_uri_parameter_supported'),
      ),
      requireRequestUriRegistration: $requireRequestUriRegistration.fromJson(
        data['require_request_uri_registration'],
        name: DataCodec.childName(name, 'require_request_uri_registration'),
      ),
      tlsClientCertificateBoundAccessTokens:
          $tlsClientCertificateBoundAccessTokens.fromJson(
            data['tls_client_certificate_bound_access_tokens'],
            name: DataCodec.childName(
              name,
              'tls_client_certificate_bound_access_tokens',
            ),
          ),
      frontchannelLogoutSupported: $frontchannelLogoutSupported.fromJson(
        data['frontchannel_logout_supported'],
        name: DataCodec.childName(name, 'frontchannel_logout_supported'),
      ),
      frontchannelLogoutSessionSupported: $frontchannelLogoutSessionSupported
          .fromJson(
            data['frontchannel_logout_session_supported'],
            name: DataCodec.childName(
              name,
              'frontchannel_logout_session_supported',
            ),
          ),
      backchannelLogoutSupported: $backchannelLogoutSupported.fromJson(
        data['backchannel_logout_supported'],
        name: DataCodec.childName(name, 'backchannel_logout_supported'),
      ),
      backchannelLogoutSessionSupported: $backchannelLogoutSessionSupported
          .fromJson(
            data['backchannel_logout_session_supported'],
            name: DataCodec.childName(
              name,
              'backchannel_logout_session_supported',
            ),
          ),
      authorizationResponseIssParameterSupported:
          $authorizationResponseIssParameterSupported.fromJson(
            data['authorization_response_iss_parameter_supported'],
            name: DataCodec.childName(
              name,
              'authorization_response_iss_parameter_supported',
            ),
          ),
      requirePushedAuthorizationRequests: $requirePushedAuthorizationRequests
          .fromJson(
            data['require_pushed_authorization_requests'],
            name: DataCodec.childName(
              name,
              'require_pushed_authorization_requests',
            ),
          ),
      grantTypesSupported: $grantTypesSupported.fromJson(
        data['grant_types_supported'],
        name: DataCodec.childName(name, 'grant_types_supported'),
      ),
      acrValuesSupported: $acrValuesSupported.fromJson(
        data['acr_values_supported'],
        name: DataCodec.childName(name, 'acr_values_supported'),
      ),
      responseTypesSupported: $responseTypesSupported.fromJson(
        data['response_types_supported'],
        name: DataCodec.childName(name, 'response_types_supported'),
      ),
      subjectTypesSupported: $subjectTypesSupported.fromJson(
        data['subject_types_supported'],
        name: DataCodec.childName(name, 'subject_types_supported'),
      ),
      idTokenSigningAlgValuesSupported: $idTokenSigningAlgValuesSupported
          .fromJson(
            data['id_token_signing_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'id_token_signing_alg_values_supported',
            ),
          ),
      idTokenEncryptionAlgValuesSupported: $idTokenEncryptionAlgValuesSupported
          .fromJson(
            data['id_token_encryption_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'id_token_encryption_alg_values_supported',
            ),
          ),
      idTokenEncryptionEncValuesSupported: $idTokenEncryptionEncValuesSupported
          .fromJson(
            data['id_token_encryption_enc_values_supported'],
            name: DataCodec.childName(
              name,
              'id_token_encryption_enc_values_supported',
            ),
          ),
      userinfoSigningAlgValuesSupported: $userinfoSigningAlgValuesSupported
          .fromJson(
            data['userinfo_signing_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'userinfo_signing_alg_values_supported',
            ),
          ),
      userinfoEncryptionAlgValuesSupported:
          $userinfoEncryptionAlgValuesSupported.fromJson(
            data['userinfo_encryption_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'userinfo_encryption_alg_values_supported',
            ),
          ),
      userinfoEncryptionEncValuesSupported:
          $userinfoEncryptionEncValuesSupported.fromJson(
            data['userinfo_encryption_enc_values_supported'],
            name: DataCodec.childName(
              name,
              'userinfo_encryption_enc_values_supported',
            ),
          ),
      requestObjectSigningAlgValuesSupported:
          $requestObjectSigningAlgValuesSupported.fromJson(
            data['request_object_signing_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'request_object_signing_alg_values_supported',
            ),
          ),
      requestObjectEncryptionAlgValuesSupported:
          $requestObjectEncryptionAlgValuesSupported.fromJson(
            data['request_object_encryption_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'request_object_encryption_alg_values_supported',
            ),
          ),
      requestObjectEncryptionEncValuesSupported:
          $requestObjectEncryptionEncValuesSupported.fromJson(
            data['request_object_encryption_enc_values_supported'],
            name: DataCodec.childName(
              name,
              'request_object_encryption_enc_values_supported',
            ),
          ),
      responseModesSupported: $responseModesSupported.fromJson(
        data['response_modes_supported'],
        name: DataCodec.childName(name, 'response_modes_supported'),
      ),
      tokenEndpointAuthMethodsSupported: $tokenEndpointAuthMethodsSupported
          .fromJson(
            data['token_endpoint_auth_methods_supported'],
            name: DataCodec.childName(
              name,
              'token_endpoint_auth_methods_supported',
            ),
          ),
      tokenEndpointAuthSigningAlgValuesSupported:
          $tokenEndpointAuthSigningAlgValuesSupported.fromJson(
            data['token_endpoint_auth_signing_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'token_endpoint_auth_signing_alg_values_supported',
            ),
          ),
      introspectionEndpointAuthMethodsSupported:
          $introspectionEndpointAuthMethodsSupported.fromJson(
            data['introspection_endpoint_auth_methods_supported'],
            name: DataCodec.childName(
              name,
              'introspection_endpoint_auth_methods_supported',
            ),
          ),
      introspectionEndpointAuthSigningAlgValuesSupported:
          $introspectionEndpointAuthSigningAlgValuesSupported.fromJson(
            data['introspection_endpoint_auth_signing_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'introspection_endpoint_auth_signing_alg_values_supported',
            ),
          ),
      authorizationSigningAlgValuesSupported:
          $authorizationSigningAlgValuesSupported.fromJson(
            data['authorization_signing_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'authorization_signing_alg_values_supported',
            ),
          ),
      authorizationEncryptionAlgValuesSupported:
          $authorizationEncryptionAlgValuesSupported.fromJson(
            data['authorization_encryption_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'authorization_encryption_alg_values_supported',
            ),
          ),
      authorizationEncryptionEncValuesSupported:
          $authorizationEncryptionEncValuesSupported.fromJson(
            data['authorization_encryption_enc_values_supported'],
            name: DataCodec.childName(
              name,
              'authorization_encryption_enc_values_supported',
            ),
          ),
      claimsSupported: $claimsSupported.fromJson(
        data['claims_supported'],
        name: DataCodec.childName(name, 'claims_supported'),
      ),
      claimTypesSupported: $claimTypesSupported.fromJson(
        data['claim_types_supported'],
        name: DataCodec.childName(name, 'claim_types_supported'),
      ),
      scopesSupported: $scopesSupported.fromJson(
        data['scopes_supported'],
        name: DataCodec.childName(name, 'scopes_supported'),
      ),
      codeChallengeMethodsSupported: $codeChallengeMethodsSupported.fromJson(
        data['code_challenge_methods_supported'],
        name: DataCodec.childName(name, 'code_challenge_methods_supported'),
      ),
      revocationEndpointAuthMethodsSupported:
          $revocationEndpointAuthMethodsSupported.fromJson(
            data['revocation_endpoint_auth_methods_supported'],
            name: DataCodec.childName(
              name,
              'revocation_endpoint_auth_methods_supported',
            ),
          ),
      revocationEndpointAuthSigningAlgValuesSupported:
          $revocationEndpointAuthSigningAlgValuesSupported.fromJson(
            data['revocation_endpoint_auth_signing_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'revocation_endpoint_auth_signing_alg_values_supported',
            ),
          ),
      backchannelTokenDeliveryModesSupported:
          $backchannelTokenDeliveryModesSupported.fromJson(
            data['backchannel_token_delivery_modes_supported'],
            name: DataCodec.childName(
              name,
              'backchannel_token_delivery_modes_supported',
            ),
          ),
      backchannelAuthenticationRequestSigningAlgValuesSupported:
          $backchannelAuthenticationRequestSigningAlgValuesSupported.fromJson(
            data['backchannel_authentication_request_signing_alg_values_supported'],
            name: DataCodec.childName(
              name,
              'backchannel_authentication_request_signing_alg_values_supported',
            ),
          ),
      mtlsEndpointAliases: $mtlsEndpointAliases.fromJson(
        data['mtls_endpoint_aliases'],
        name: DataCodec.childName(name, 'mtls_endpoint_aliases'),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final $$data = this as OidcConfiguration;
    return {
      'issuer': $issuer.toJson($$data.issuer),
      'jwks_uri': $jwksUri.toJson($$data.jwksUri),
      'authorization_endpoint': $authorizationEndpoint.toJson(
        $$data.authorizationEndpoint,
      ),
      'token_endpoint': $tokenEndpoint.toJson($$data.tokenEndpoint),
      'userinfo_endpoint': $userinfoEndpoint.toJson($$data.userinfoEndpoint),
      'introspection_endpoint': $introspectionEndpoint.toJson(
        $$data.introspectionEndpoint,
      ),
      'registration_endpoint': $registrationEndpoint.toJson(
        $$data.registrationEndpoint,
      ),
      'end_session_endpoint': $endSessionEndpoint.toJson(
        $$data.endSessionEndpoint,
      ),
      'revocation_endpoint': $revocationEndpoint.toJson(
        $$data.revocationEndpoint,
      ),
      'device_authorization_endpoint': $deviceAuthorizationEndpoint.toJson(
        $$data.deviceAuthorizationEndpoint,
      ),
      'backchannel_authentication_endpoint': $backchannelAuthenticationEndpoint
          .toJson($$data.backchannelAuthenticationEndpoint),
      'pushed_authorization_request_endpoint':
          $pushedAuthorizationRequestEndpoint.toJson(
            $$data.pushedAuthorizationRequestEndpoint,
          ),
      'claims_parameter_supported': $claimsParameterSupported.toJson(
        $$data.claimsParameterSupported,
      ),
      'request_parameter_supported': $requestParameterSupported.toJson(
        $$data.requestParameterSupported,
      ),
      'request_uri_parameter_supported': $requestUriParameterSupported.toJson(
        $$data.requestUriParameterSupported,
      ),
      'require_request_uri_registration': $requireRequestUriRegistration.toJson(
        $$data.requireRequestUriRegistration,
      ),
      'tls_client_certificate_bound_access_tokens':
          $tlsClientCertificateBoundAccessTokens.toJson(
            $$data.tlsClientCertificateBoundAccessTokens,
          ),
      'frontchannel_logout_supported': $frontchannelLogoutSupported.toJson(
        $$data.frontchannelLogoutSupported,
      ),
      'frontchannel_logout_session_supported':
          $frontchannelLogoutSessionSupported.toJson(
            $$data.frontchannelLogoutSessionSupported,
          ),
      'backchannel_logout_supported': $backchannelLogoutSupported.toJson(
        $$data.backchannelLogoutSupported,
      ),
      'backchannel_logout_session_supported': $backchannelLogoutSessionSupported
          .toJson($$data.backchannelLogoutSessionSupported),
      'authorization_response_iss_parameter_supported':
          $authorizationResponseIssParameterSupported.toJson(
            $$data.authorizationResponseIssParameterSupported,
          ),
      'require_pushed_authorization_requests':
          $requirePushedAuthorizationRequests.toJson(
            $$data.requirePushedAuthorizationRequests,
          ),
      'grant_types_supported': $grantTypesSupported.toJson(
        $$data.grantTypesSupported,
      ),
      'acr_values_supported': $acrValuesSupported.toJson(
        $$data.acrValuesSupported,
      ),
      'response_types_supported': $responseTypesSupported.toJson(
        $$data.responseTypesSupported,
      ),
      'subject_types_supported': $subjectTypesSupported.toJson(
        $$data.subjectTypesSupported,
      ),
      'id_token_signing_alg_values_supported': $idTokenSigningAlgValuesSupported
          .toJson($$data.idTokenSigningAlgValuesSupported),
      'id_token_encryption_alg_values_supported':
          $idTokenEncryptionAlgValuesSupported.toJson(
            $$data.idTokenEncryptionAlgValuesSupported,
          ),
      'id_token_encryption_enc_values_supported':
          $idTokenEncryptionEncValuesSupported.toJson(
            $$data.idTokenEncryptionEncValuesSupported,
          ),
      'userinfo_signing_alg_values_supported':
          $userinfoSigningAlgValuesSupported.toJson(
            $$data.userinfoSigningAlgValuesSupported,
          ),
      'userinfo_encryption_alg_values_supported':
          $userinfoEncryptionAlgValuesSupported.toJson(
            $$data.userinfoEncryptionAlgValuesSupported,
          ),
      'userinfo_encryption_enc_values_supported':
          $userinfoEncryptionEncValuesSupported.toJson(
            $$data.userinfoEncryptionEncValuesSupported,
          ),
      'request_object_signing_alg_values_supported':
          $requestObjectSigningAlgValuesSupported.toJson(
            $$data.requestObjectSigningAlgValuesSupported,
          ),
      'request_object_encryption_alg_values_supported':
          $requestObjectEncryptionAlgValuesSupported.toJson(
            $$data.requestObjectEncryptionAlgValuesSupported,
          ),
      'request_object_encryption_enc_values_supported':
          $requestObjectEncryptionEncValuesSupported.toJson(
            $$data.requestObjectEncryptionEncValuesSupported,
          ),
      'response_modes_supported': $responseModesSupported.toJson(
        $$data.responseModesSupported,
      ),
      'token_endpoint_auth_methods_supported':
          $tokenEndpointAuthMethodsSupported.toJson(
            $$data.tokenEndpointAuthMethodsSupported,
          ),
      'token_endpoint_auth_signing_alg_values_supported':
          $tokenEndpointAuthSigningAlgValuesSupported.toJson(
            $$data.tokenEndpointAuthSigningAlgValuesSupported,
          ),
      'introspection_endpoint_auth_methods_supported':
          $introspectionEndpointAuthMethodsSupported.toJson(
            $$data.introspectionEndpointAuthMethodsSupported,
          ),
      'introspection_endpoint_auth_signing_alg_values_supported':
          $introspectionEndpointAuthSigningAlgValuesSupported.toJson(
            $$data.introspectionEndpointAuthSigningAlgValuesSupported,
          ),
      'authorization_signing_alg_values_supported':
          $authorizationSigningAlgValuesSupported.toJson(
            $$data.authorizationSigningAlgValuesSupported,
          ),
      'authorization_encryption_alg_values_supported':
          $authorizationEncryptionAlgValuesSupported.toJson(
            $$data.authorizationEncryptionAlgValuesSupported,
          ),
      'authorization_encryption_enc_values_supported':
          $authorizationEncryptionEncValuesSupported.toJson(
            $$data.authorizationEncryptionEncValuesSupported,
          ),
      'claims_supported': $claimsSupported.toJson($$data.claimsSupported),
      'claim_types_supported': $claimTypesSupported.toJson(
        $$data.claimTypesSupported,
      ),
      'scopes_supported': $scopesSupported.toJson($$data.scopesSupported),
      'code_challenge_methods_supported': $codeChallengeMethodsSupported.toJson(
        $$data.codeChallengeMethodsSupported,
      ),
      'revocation_endpoint_auth_methods_supported':
          $revocationEndpointAuthMethodsSupported.toJson(
            $$data.revocationEndpointAuthMethodsSupported,
          ),
      'revocation_endpoint_auth_signing_alg_values_supported':
          $revocationEndpointAuthSigningAlgValuesSupported.toJson(
            $$data.revocationEndpointAuthSigningAlgValuesSupported,
          ),
      'backchannel_token_delivery_modes_supported':
          $backchannelTokenDeliveryModesSupported.toJson(
            $$data.backchannelTokenDeliveryModesSupported,
          ),
      'backchannel_authentication_request_signing_alg_values_supported':
          $backchannelAuthenticationRequestSigningAlgValuesSupported.toJson(
            $$data.backchannelAuthenticationRequestSigningAlgValuesSupported,
          ),
      'mtls_endpoint_aliases': $mtlsEndpointAliases.toJson(
        $$data.mtlsEndpointAliases,
      ),
    }..removeWhere((k, v) => v == null);
  }
}
