import 'package:datahub/api.dart';
import 'package:datahub/config.dart';
import 'package:datahub/scaffold.dart';

import 'authentication_middleware.dart';
import 'jwt/jwt.dart';

abstract interface class JwtAuthProvider {
  Future<Session> authenticateJwt(Jwt auth);
}

class JwtAuthMiddleware extends AuthenticationMiddleware {
  final Find<JwtAuthProvider> provider;
  final Config<String> prefix;
  final Config<String?> issuer;
  final Config<String?> audience;
  final bool verify;

  const JwtAuthMiddleware({
    super.matcher,
    this.provider = const Find<JwtAuthProvider>(),
    this.prefix = const Config('jwtAuth.prefix', defaultValue: 'Bearer '),
    this.issuer = const Config('jwtAuth.issuer'),
    this.audience = const Config('jwtAuth.audience'),
    required super.routes,
    this.verify = true,
    super.catchRequests = false,
    super.requireSession = true,
  });

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
