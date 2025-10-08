import 'package:datahub/datahub.dart';

part 'oidc_response.g.dart';

@Data(defaultNamingConvention: NamingConvention.lowerSnakeCase)
class OidcResponse extends $OidcResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String? scope;
  final String? refreshToken;
  final String? idToken;

  const OidcResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.scope,
    this.refreshToken,
    this.idToken,
  });
}
