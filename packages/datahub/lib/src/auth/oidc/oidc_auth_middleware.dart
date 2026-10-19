import 'package:datahub/api.dart';
import 'package:datahub/auth.dart';
import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';

class OidcSession({
  required final String identityProvider,
  required final String clientId,
  required final Jwt authenticationToken,
}) implements Session {
  @override
  String get debugName => 'oidc-session';

  @override
  String get identity =>
      authenticationToken.sub ??
      (throw ApiRequestException.unauthorized(
        'Invalid authentication token (missing subject).',
      ));
}

class OidcAuthMiddleware({
  final Config<String> identityProvider = const Config(
    'oidcAuth.identityProvider',
  ),
  final Config<String> audience = const Config('oidcAuth.audience'),
  final Config<String> clientId = const Config('oidcAuth.clientId'),
  final Config<String?> clientSecret = const Config('oidcAuth.clientSecret'),
  super.matcher,
  required super.routes,
  super.catchRequests = false,
  super.requireSession = true,
}) extends AuthenticationMiddleware {
  OidcConfiguration? configuration;

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
