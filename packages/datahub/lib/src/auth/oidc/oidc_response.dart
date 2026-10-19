import 'package:datahub/datahub.dart';

part 'oidc_response.g.dart';

@Data(defaultNamingConvention: NamingConvention.lowerSnakeCase)
class const OidcResponse({
  required final String accessToken,
  required final String tokenType,
  required final int expiresIn,
  final String? scope,
  final String? refreshToken,
  final String? idToken,
}) extends $OidcResponse;
