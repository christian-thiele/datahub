import 'package:boost/boost.dart';
import 'package:datahub/api.dart';
import 'package:datahub/http.dart';
import 'package:pointycastle/pointycastle.dart';

class JWTAuthProvider extends AuthProvider {
  final String? issuer;
  final String? audience;
  final RSAPublicKey? publicKey;
  final String prefix;

  JWTAuthProvider(
    super.internal, {
    this.prefix = 'Bearer ',
    this.issuer,
    this.audience,
    this.publicKey,
    super.requireAuthorization = true,
  });

  @override
  Future<Session?> authorizeRequest(ApiRequest request) async {
    final token = request.headers[HttpHeaders.authorization]?.firstOrNull;
    if (token != null) {
      final jwt = JWT(token, prefix: prefix);
      await jwt.verify(
        issuer: issuer,
        audience: audience,
        publicKey: publicKey,
      );

      return JWTSession(jwt);
    }

    return null;
  }
}
