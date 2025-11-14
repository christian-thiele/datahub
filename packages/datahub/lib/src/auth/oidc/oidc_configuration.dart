import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';

part 'oidc_configuration.g.dart';

@Data(defaultNamingConvention: NamingConvention.lowerSnakeCase)
class OidcConfiguration extends $OidcConfiguration {
  final String issuer;
  final String jwksUri;

  final String authorizationEndpoint;
  final String tokenEndpoint;
  final String? userinfoEndpoint;
  final String? introspectionEndpoint;
  final String? registrationEndpoint;
  final String? endSessionEndpoint;
  final String? revocationEndpoint;
  final String? deviceAuthorizationEndpoint;
  final String? backchannelAuthenticationEndpoint;
  final String? pushedAuthorizationRequestEndpoint;

  final bool claimsParameterSupported;
  final bool requestParameterSupported;
  final bool requestUriParameterSupported;

  final bool requireRequestUriRegistration;
  final bool tlsClientCertificateBoundAccessTokens;
  final bool frontchannelLogoutSupported;
  final bool frontchannelLogoutSessionSupported;
  final bool backchannelLogoutSupported;
  final bool backchannelLogoutSessionSupported;
  final bool authorizationResponseIssParameterSupported;
  final bool requirePushedAuthorizationRequests;
  final List<String>? grantTypesSupported;
  final List<String>? acrValuesSupported;
  final List<String> subjectTypesSupported;
  final List<String> idTokenSigningAlgValuesSupported;
  final List<String>? idTokenEncryptionAlgValuesSupported;
  final List<String>? idTokenEncryptionEncValuesSupported;
  final List<String>? userinfoSigningAlgValuesSupported;
  final List<String>? userinfoEncryptionAlgValuesSupported;
  final List<String>? userinfoEncryptionEncValuesSupported;
  final List<String>? requestObjectSigningAlgValuesSupported;
  final List<String>? requestObjectEncryptionAlgValuesSupported;
  final List<String>? requestObjectEncryptionEncValuesSupported;
  final List<String> responseTypesSupported;
  final List<String>? responseModesSupported;
  final List<String>? tokenEndpointAuthMethodsSupported;
  final List<String>? tokenEndpointAuthSigningAlgValuesSupported;
  final List<String>? introspectionEndpointAuthMethodsSupported;
  final List<String>? introspectionEndpointAuthSigningAlgValuesSupported;
  final List<String>? authorizationSigningAlgValuesSupported;
  final List<String>? authorizationEncryptionAlgValuesSupported;
  final List<String>? authorizationEncryptionEncValuesSupported;
  final List<String>? claimsSupported;
  final List<String>? claimTypesSupported;
  final List<String>? scopesSupported;
  final List<String>? codeChallengeMethodsSupported;
  final List<String>? revocationEndpointAuthMethodsSupported;
  final List<String>? revocationEndpointAuthSigningAlgValuesSupported;
  final List<String>? backchannelTokenDeliveryModesSupported;
  final List<String>? backchannelAuthenticationRequestSigningAlgValuesSupported;
  final Map<String, String>? mtlsEndpointAliases;

  const OidcConfiguration({
    required this.issuer,
    required this.jwksUri,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    this.userinfoEndpoint,
    this.introspectionEndpoint,
    this.registrationEndpoint,
    this.endSessionEndpoint,
    this.revocationEndpoint,
    this.deviceAuthorizationEndpoint,
    this.backchannelAuthenticationEndpoint,
    this.pushedAuthorizationRequestEndpoint,
    this.claimsParameterSupported = false,
    this.requestParameterSupported = false,
    this.requestUriParameterSupported = false,
    this.requireRequestUriRegistration = false,
    this.tlsClientCertificateBoundAccessTokens = false,
    this.frontchannelLogoutSupported = false,
    this.frontchannelLogoutSessionSupported = false,
    this.backchannelLogoutSupported = false,
    this.backchannelLogoutSessionSupported = false,
    this.authorizationResponseIssParameterSupported = false,
    this.requirePushedAuthorizationRequests = false,
    this.grantTypesSupported,
    this.acrValuesSupported,
    required this.responseTypesSupported,
    required this.subjectTypesSupported,
    required this.idTokenSigningAlgValuesSupported,
    this.idTokenEncryptionAlgValuesSupported,
    this.idTokenEncryptionEncValuesSupported,
    this.userinfoSigningAlgValuesSupported,
    this.userinfoEncryptionAlgValuesSupported,
    this.userinfoEncryptionEncValuesSupported,
    this.requestObjectSigningAlgValuesSupported,
    this.requestObjectEncryptionAlgValuesSupported,
    this.requestObjectEncryptionEncValuesSupported,
    this.responseModesSupported,
    this.tokenEndpointAuthMethodsSupported,
    this.tokenEndpointAuthSigningAlgValuesSupported,
    this.introspectionEndpointAuthMethodsSupported,
    this.introspectionEndpointAuthSigningAlgValuesSupported,
    this.authorizationSigningAlgValuesSupported,
    this.authorizationEncryptionAlgValuesSupported,
    this.authorizationEncryptionEncValuesSupported,
    this.claimsSupported,
    this.claimTypesSupported,
    this.scopesSupported,
    this.codeChallengeMethodsSupported,
    this.revocationEndpointAuthMethodsSupported,
    this.revocationEndpointAuthSigningAlgValuesSupported,
    this.backchannelTokenDeliveryModesSupported,
    this.backchannelAuthenticationRequestSigningAlgValuesSupported,
    this.mtlsEndpointAliases,
  });
}
