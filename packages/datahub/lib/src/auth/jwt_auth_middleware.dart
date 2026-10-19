import 'package:datahub/api.dart';
import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';

import 'authentication_middleware.dart';
import 'jwt/jwt.dart';

abstract interface class JwtAuthProvider() {
  Future<Session> authenticateJwt(Jwt auth);
}

class const JwtAuthMiddleware({
  super.matcher,
  final Find<JwtAuthProvider> provider = const Find<JwtAuthProvider>(),
  final Config<String> prefix = const Config(
    'jwtAuth.prefix',
    defaultValue: 'Bearer ',
  ),
  final Config<String?> issuer = const Config('jwtAuth.issuer'),
  final Config<String?> audience = const Config('jwtAuth.audience'),
  required super.routes,
  final bool verify = true,
  super.catchRequests = false,
  super.requireSession = true,
}) extends AuthenticationMiddleware {
  @override
  Future<Session?> authenticate(ApiRequest request) async {
    final auth = Jwt.fromRequest(request.headers, prefix: prefix.read());
    if (auth != null) {
      if (verify) {
        await auth.verify(audience: audience.read(), issuer: issuer.read());
      }
      return await provider.find().authenticateJwt(auth);
    } else {
      return null;
    }
  }
}
