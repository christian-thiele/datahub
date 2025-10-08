import 'package:datahub/data.dart';
import 'package:datahub/utils.dart';

part 'oidc_configuration.g.dart';

@Data(defaultNamingConvention: NamingConvention.lowerSnakeCase)
class OidcConfiguration extends $OidcConfiguration {
  final String issuer;
  final String jwksUri;

  final String authorizationEndpoint;
  final String tokenEndpoint;
  final String introspectionEndpoint;
  final String registrationEndpoint;
  final String revocationEndpoint;
  final String deviceAuthorizationEndpoint;
  final String backchannelAuthenticationEndpoint;
  final String pushedAuthorizationRequestEndpoint;

  final bool claimsParameterSupported;
  final bool requestParameterSupported;
  final bool requestUriParameterSupported;

  final bool requireRequestUriRegistration;
  final bool tlsClientCertificateBoundAccessTokens;
  final bool backchannelLogoutSupported;
  final bool backchannelLogoutSessionSupported;
  final bool authorizationResponseIssParameterSupported;
  final bool requirePushedAuthorizationRequests;
  final List<String> grantTypesSupported;
  final List<String> acrValuesSupported;
  final List<String> responseTypesSupported;
  final List<String> subjectTypesSupported;
  final List<String> idTokenSigningAlgValuesSupported;
  final List<String> idTokenEncryptionAlgValuesSupported;
  final List<String> idTokenEncryptionEncValuesSupported;
  final List<String> userinfoSigningAlgValuesSupported;
  final List<String> userinfoEncryptionAlgValuesSupported;
  final List<String> userinfoEncryptionEncValuesSupported;
  final List<String> requestObjectSigningAlgValuesSupported;
  final List<String> requestObjectEncryptionAlgValuesSupported;
  final List<String> requestObjectEncryptionEncValuesSupported;
  final List<String> responseModesSupported;
  final List<String> tokenEndpointAuthMethodsSupported;
  final List<String> tokenEndpointAuthSigningAlgValuesSupported;
  final List<String> introspectionEndpointAuthMethodsSupported;
  final List<String> introspectionEndpointAuthSigningAlgValuesSupported;
  final List<String> authorizationSigningAlgValuesSupported;
  final List<String> authorizationEncryptionAlgValuesSupported;
  final List<String> authorizationEncryptionEncValuesSupported;
  final List<String> claimsSupported;
  final List<String> claimTypesSupported;
  final List<String> scopesSupported;
  final List<String> codeChallengeMethodsSupported;
  final List<String> revocationEndpointAuthMethodsSupported;
  final List<String> revocationEndpointAuthSigningAlgValuesSupported;
  final List<String> backchannelTokenDeliveryModesSupported;
  final List<String> backchannelAuthenticationRequestSigningAlgValuesSupported;
  final Map<String, String> mtlsEndpointAliases;

  const OidcConfiguration({
    required this.issuer,
    required this.jwksUri,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    required this.introspectionEndpoint,
    required this.registrationEndpoint,
    required this.revocationEndpoint,
    required this.deviceAuthorizationEndpoint,
    required this.backchannelAuthenticationEndpoint,
    required this.pushedAuthorizationRequestEndpoint,
    required this.claimsParameterSupported,
    required this.requestParameterSupported,
    required this.requestUriParameterSupported,
    required this.requireRequestUriRegistration,
    required this.tlsClientCertificateBoundAccessTokens,
    required this.backchannelLogoutSupported,
    required this.backchannelLogoutSessionSupported,
    required this.authorizationResponseIssParameterSupported,
    required this.requirePushedAuthorizationRequests,
    required this.grantTypesSupported,
    required this.acrValuesSupported,
    required this.responseTypesSupported,
    required this.subjectTypesSupported,
    required this.idTokenSigningAlgValuesSupported,
    required this.idTokenEncryptionAlgValuesSupported,
    required this.idTokenEncryptionEncValuesSupported,
    required this.userinfoSigningAlgValuesSupported,
    required this.userinfoEncryptionAlgValuesSupported,
    required this.userinfoEncryptionEncValuesSupported,
    required this.requestObjectSigningAlgValuesSupported,
    required this.requestObjectEncryptionAlgValuesSupported,
    required this.requestObjectEncryptionEncValuesSupported,
    required this.responseModesSupported,
    required this.tokenEndpointAuthMethodsSupported,
    required this.tokenEndpointAuthSigningAlgValuesSupported,
    required this.introspectionEndpointAuthMethodsSupported,
    required this.introspectionEndpointAuthSigningAlgValuesSupported,
    required this.authorizationSigningAlgValuesSupported,
    required this.authorizationEncryptionAlgValuesSupported,
    required this.authorizationEncryptionEncValuesSupported,
    required this.claimsSupported,
    required this.claimTypesSupported,
    required this.scopesSupported,
    required this.codeChallengeMethodsSupported,
    required this.revocationEndpointAuthMethodsSupported,
    required this.revocationEndpointAuthSigningAlgValuesSupported,
    required this.backchannelTokenDeliveryModesSupported,
    required this.backchannelAuthenticationRequestSigningAlgValuesSupported,
    required this.mtlsEndpointAliases,
  });
}
