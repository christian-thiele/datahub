import 'package:datahub/api.dart';
import 'package:datahub/auth.dart';
import 'package:datahub/scaffold.dart';
import 'package:datahub/config.dart';

import 'oidc_configuration.dart';

class OidcSession implements Session {
  @override
  String get debugName => 'oidc-session';

  final String identityProvider;
  final String clientId;
  final Jwt authenticationToken;

  OidcSession({
    required this.identityProvider,
    required this.clientId,
    required this.authenticationToken,
  });
}

class OidcAuthMiddleware extends AuthenticationMiddleware {
  final Config<String> identityProvider;
  final Config<String> audience;
  final Config<String> clientId;
  final Config<String?> clientSecret;

  OidcConfiguration? configuration;

  OidcAuthMiddleware({
    this.identityProvider = const Config('oidcAuth.identityProvider'),
    this.audience = const Config('oidcAuth.audience'),
    this.clientId = const Config('oidcAuth.clientId'),
    this.clientSecret = const Config('oidcAuth.clientSecret'),
    super.matcher,
    required super.routes,
    super.catchRequests = false,
    super.requireSession = true,
  });

  @override
  Future<OidcSession?> authenticate(ApiRequest request) async {
    final idp = identityProvider.read();
    final aud = audience.read();

    final auth = Jwt.fromRequest(request.headers);
    if (auth != null) {
      await auth.verify(audience: aud, issuer: idp);
      return OidcSession(
        identityProvider: idp,
        clientId: clientId.read(),
        authenticationToken: auth,
      );
    } else {
      return null;
    }
  }
}
